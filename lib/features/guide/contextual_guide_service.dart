import 'dart:convert';

import '../../models/guide_content.dart';
import '../../models/region_snapshot.dart';
import '../llm/inference_engine.dart';
import '../llm/llm_resource_policy.dart';
import 'prompt_builder.dart';

enum GuidePipelineStage { api, prompt, llm, tts }

class GuidePipelineEvent {
  const GuidePipelineEvent({
    required this.stage,
    required this.message,
    required this.occurredAt,
    this.payload,
  });

  final GuidePipelineStage stage;
  final String message;
  final DateTime occurredAt;
  final String? payload;

  String get label {
    switch (stage) {
      case GuidePipelineStage.api:
        return 'API';
      case GuidePipelineStage.prompt:
        return 'Prompt';
      case GuidePipelineStage.llm:
        return 'LLM';
      case GuidePipelineStage.tts:
        return 'TTS';
    }
  }
}

typedef GuidePipelineListener = void Function(GuidePipelineEvent event);

class _ExtractedEntity {
  const _ExtractedEntity({
    required this.label,
    required this.kind,
  });

  final String label;
  final GuideLinkKind kind;
}

class ContextualGuideService {
  ContextualGuideService({
    InferenceEngine? inferenceEngine,
    PromptBuilder? promptBuilder,
    LlmResourcePolicy? resourcePolicy,
  }) : _inferenceEngine = inferenceEngine ?? InferenceEngine(),
       _promptBuilder = promptBuilder ?? const PromptBuilder(),
       _resourcePolicy = resourcePolicy ?? const LlmResourcePolicy();

  final InferenceEngine _inferenceEngine;
  final PromptBuilder _promptBuilder;
  final LlmResourcePolicy _resourcePolicy;

  Future<LlmModelInfo> getModelInfo() {
    return _inferenceEngine.getModelInfo();
  }

  Future<GuideContent> buildGuide(
    RegionSnapshot region, {
    GuidePipelineListener? onPipelineEvent,
  }) async {
    return buildGuideForRegionName(
      regionName: region.displayName,
      speedMph: region.speedMph,
      latitude: region.position.latitude,
      longitude: region.position.longitude,
      onPipelineEvent: onPipelineEvent,
    );
  }

  Future<GuideContent> buildGuideForRegionName({
    required String regionName,
    required double speedMph,
    double? latitude,
    double? longitude,
    GuidePipelineListener? onPipelineEvent,
  }) async {
    _emit(
      onPipelineEvent,
      GuidePipelineStage.api,
      'Using current city name only: $regionName.',
    );
    final baseGuide = _buildBaseGuide(regionName);

    if (!_resourcePolicy.shouldGenerate(
      speedMph: speedMph,
      regionChanged: true,
    )) {
      _emit(
        onPipelineEvent,
        GuidePipelineStage.llm,
        'Skipped LLM because the vehicle appears stopped or barely moving.',
      );
      await _inferenceEngine.enterStandby();
      return baseGuide;
    }

    _emit(
      onPipelineEvent,
      GuidePipelineStage.prompt,
      'Building city-only travel intro prompt.',
    );
    final introPrompt = _promptBuilder.buildTravelingCityIntroPrompt(
      cityName: regionName,
    );
    _emit(
      onPipelineEvent,
      GuidePipelineStage.prompt,
      'First LLM city intro prompt is ready.',
      payload: introPrompt,
    );
    _emit(
      onPipelineEvent,
      GuidePipelineStage.llm,
      'Generating city intro narration.',
    );
    final generatedText = await _inferenceEngine.generateText(introPrompt);
    _emit(
      onPipelineEvent,
      GuidePipelineStage.llm,
      'City intro narration received.',
      payload: generatedText,
    );
    final entityPrompt = _promptBuilder.buildProperNounExtractionPrompt(
      narration: generatedText,
    );
    _emit(
      onPipelineEvent,
      GuidePipelineStage.prompt,
      'Second LLM proper noun extraction prompt is ready.',
      payload: entityPrompt,
    );
    _emit(
      onPipelineEvent,
      GuidePipelineStage.llm,
      'Extracting proper nouns for related links.',
    );
    final entityResponse = await _inferenceEngine.generateText(entityPrompt);
    _emit(
      onPipelineEvent,
      GuidePipelineStage.llm,
      'Proper noun extraction received.',
      payload: entityResponse,
    );
    final links = _buildLinksFromEntityResponse(entityResponse, regionName);
    final refinedGuide = baseGuide.copyWith(
      fullText: generatedText,
      shortText: _summarize(generatedText),
      links: links,
      generatedAt: DateTime.now(),
    );

    if (_resourcePolicy.shouldStandbyAfterGeneration()) {
      await _inferenceEngine.unloadModel();
    }

    return refinedGuide;
  }

  Future<void> dispose() async {
    await _inferenceEngine.unloadModel();
  }

  String _summarize(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 120) {
      return normalized;
    }
    return '${normalized.substring(0, 120).trimRight()}...';
  }

  GuideContent _buildBaseGuide(String regionName) {
    return GuideContent(
      regionName: regionName,
      fullText: 'Entering $regionName.',
      shortText: '$regionName ahead.',
      generatedAt: DateTime.now(),
    );
  }

  List<GuideLink> _buildLinksFromEntityResponse(
    String entityResponse,
    String regionName,
  ) {
    final entities = _parseEntityResponse(entityResponse);
    final seen = <String>{};
    final links = <GuideLink>[];

    for (final entity in entities) {
      final label = entity.label.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (label.length < 3) {
        continue;
      }
      final normalized = label.toLowerCase();
      if (!seen.add(normalized)) {
        continue;
      }

      final kind = entity.kind == GuideLinkKind.map
          ? GuideLinkKind.map
          : GuideLinkKind.search;
      final query = kind == GuideLinkKind.map ? '$label $regionName' : label;
      final encodedQuery = Uri.encodeQueryComponent(query);
      links.add(
        GuideLink(
          label: label,
          kind: kind,
          url: kind == GuideLinkKind.map
              ? 'https://www.google.com/maps/search/?api=1&query=$encodedQuery'
              : 'https://www.google.com/search?q=$encodedQuery',
        ),
      );
    }

    return links;
  }

  List<_ExtractedEntity> _parseEntityResponse(String entityResponse) {
    final jsonText = _extractJsonArray(entityResponse);
    if (jsonText == null) {
      return _recoverMalformedEntities(entityResponse);
    }

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! List) {
        return const [];
      }
      final parsedEntities = decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((item) {
            final label = item['name'] ?? item['label'];
            final kind = item['kind'];
            if (label is! String ||
                label.trim().isEmpty ||
                label.trim().toLowerCase() == 'proper noun') {
              return null;
            }
            return _ExtractedEntity(
              label: label,
              kind: kind == 'place' ? GuideLinkKind.map : GuideLinkKind.search,
            );
          })
          .whereType<_ExtractedEntity>()
          .toList();
      if (parsedEntities.isNotEmpty) {
        return parsedEntities;
      }
      return _recoverMalformedEntities(entityResponse);
    } catch (_) {
      return _recoverMalformedEntities(entityResponse);
    }
  }

  List<_ExtractedEntity> _recoverMalformedEntities(String entityResponse) {
    final entities = <_ExtractedEntity>[];
    final placeBlock = _extractMalformedKindBlock(entityResponse, 'place');
    final nonPlaceBlock = _extractMalformedKindBlock(entityResponse, 'nonPlace');

    for (final name in _extractNameValues(placeBlock)) {
      entities.add(_ExtractedEntity(label: name, kind: GuideLinkKind.map));
    }
    for (final name in _extractNameValues(nonPlaceBlock)) {
      entities.add(_ExtractedEntity(label: name, kind: GuideLinkKind.search));
    }

    return entities;
  }

  String _extractMalformedKindBlock(String value, String kind) {
    final match = RegExp(
      '"kind"\\s*:\\s*"$kind"\\s*:\\s*\\{([\\s\\S]*?)\\}\\s*\\}',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1) ?? '';
  }

  Iterable<String> _extractNameValues(String value) {
    return RegExp(r'"name"\s*:\s*"([^"]+)"')
        .allMatches(value)
        .map((match) => match.group(1)?.trim())
        .whereType<String>()
        .where((name) => name.isNotEmpty);
  }

  String? _extractJsonArray(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      return trimmed;
    }

    final fencedMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (fencedMatch != null) {
      final fenced = fencedMatch.group(1)?.trim();
      if (fenced != null && fenced.startsWith('[') && fenced.endsWith(']')) {
        return fenced;
      }
    }

    final start = trimmed.indexOf('[');
    final end = trimmed.lastIndexOf(']');
    if (start >= 0 && end > start) {
      return trimmed.substring(start, end + 1);
    }
    return null;
  }

  void _emit(
    GuidePipelineListener? listener,
    GuidePipelineStage stage,
    String message, {
    String? payload,
  }) {
    listener?.call(
      GuidePipelineEvent(
        stage: stage,
        message: message,
        occurredAt: DateTime.now(),
        payload: payload,
      ),
    );
  }
}
