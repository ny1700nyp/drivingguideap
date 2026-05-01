import 'dart:convert';

import 'package:flutter/services.dart';

enum InferenceEngineState { unloaded, loading, ready, generating, standby }

class LlmModelInfo {
  const LlmModelInfo({
    required this.provider,
    required this.modelName,
    required this.availability,
    required this.usesFallback,
  });

  factory LlmModelInfo.fromMap(Map<dynamic, dynamic> map) {
    return LlmModelInfo(
      provider: '${map['provider'] ?? 'Unknown'}',
      modelName: '${map['modelName'] ?? 'Unknown'}',
      availability: '${map['availability'] ?? 'Unknown'}',
      usesFallback: map['usesFallback'] == true,
    );
  }

  static const fallback = LlmModelInfo(
    provider: 'Dart fallback',
    modelName: 'Template fallback generator',
    availability: 'Native model unavailable',
    usesFallback: true,
  );

  final String provider;
  final String modelName;
  final String availability;
  final bool usesFallback;
}

class InferenceEngine {
  InferenceEngine({MethodChannel? methodChannel})
    : _methodChannel =
          methodChannel ?? const MethodChannel('drivingguide/local_llm');

  final MethodChannel _methodChannel;
  InferenceEngineState _state = InferenceEngineState.unloaded;

  InferenceEngineState get state => _state;
  bool get isLoaded =>
      _state == InferenceEngineState.ready ||
      _state == InferenceEngineState.standby;

  Future<LlmModelInfo> getModelInfo() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getModelInfo',
      );
      if (result == null) {
        return LlmModelInfo.fallback;
      }
      return LlmModelInfo.fromMap(result);
    } on MissingPluginException {
      return LlmModelInfo.fallback;
    } on PlatformException {
      return LlmModelInfo.fallback;
    }
  }

  Future<void> loadModel({String modelId = 'apple-foundation-models'}) async {
    if (isLoaded || _state == InferenceEngineState.loading) {
      return;
    }

    _state = InferenceEngineState.loading;
    try {
      await _methodChannel.invokeMethod<void>('loadModel', {
        'modelId': modelId,
      });
      _state = InferenceEngineState.ready;
    } on MissingPluginException {
      _state = InferenceEngineState.ready;
    } on PlatformException {
      _state = InferenceEngineState.ready;
    }
  }

  Future<String> generateText(String prompt) async {
    if (!isLoaded) {
      await loadModel();
    }

    _state = InferenceEngineState.generating;
    try {
      final result = await _methodChannel.invokeMethod<String>('generateText', {
        'prompt': prompt,
      });
      if (result == null || _looksLikeAssistantChatter(result)) {
        return _fallbackGeneration(prompt);
      }
      return result;
    } on MissingPluginException {
      return _fallbackGeneration(prompt);
    } on PlatformException {
      return _fallbackGeneration(prompt);
    } finally {
      _state = InferenceEngineState.ready;
    }
  }

  Future<void> enterStandby() async {
    if (_state == InferenceEngineState.unloaded) {
      return;
    }

    try {
      await _methodChannel.invokeMethod<void>('enterStandby');
    } on MissingPluginException {
      // The Dart fallback has no resident model weights to park.
    } on PlatformException {
      // Unsupported devices can keep using the Dart fallback path.
    }
    _state = InferenceEngineState.unloaded;
  }

  Future<void> unloadModel() async {
    try {
      await _methodChannel.invokeMethod<void>('unloadModel');
    } on MissingPluginException {
      // Native Core ML/MLC integration will release weights here later.
    } on PlatformException {
      // Unsupported devices can keep using the Dart fallback path.
    }
    _state = InferenceEngineState.unloaded;
  }

  String _fallbackGeneration(String prompt) {
    final narration = RegExp(
      r'Narration:\n([\s\S]*)',
    ).firstMatch(prompt)?.group(1);
    if (narration != null && narration.trim().isNotEmpty) {
      return jsonEncode(_fallbackEntities(narration));
    }

    final rawSourceNotes = RegExp(
      r'Raw source notes:\n([\s\S]*?)\n\nOutput format:',
    ).firstMatch(prompt)?.group(1);
    if (rawSourceNotes != null && rawSourceNotes.trim().isNotEmpty) {
      final facts = _cleanFactLines(rawSourceNotes)
          .take(12)
          .join('\n');
      return facts;
    }

    final facts = RegExp(r'Facts:\n([\s\S]*)').firstMatch(prompt)?.group(1);
    if (facts != null && facts.trim().isNotEmpty) {
      final factLines = _cleanFactLines(facts).take(5).toList();
      final cityName =
          RegExp(r'(?:City/Town|Place):\s*(.+)')
              .firstMatch(facts)
              ?.group(1)
              ?.trim() ??
          'this city';
      if (factLines.isEmpty) {
        return 'As you pass through $cityName, notice the local landmarks, food stops, and practical places that shape this stop on the route.';
      }
      return 'As you pass through $cityName, here is the quick local story. '
          '${factLines.join(' ')}';
    }

    final cityIntroMatch = RegExp(
      r'traveling through ([^\.\n]+)',
      caseSensitive: false,
    ).firstMatch(prompt);
    final cityName = cityIntroMatch?.group(1)?.trim();
    if (cityName != null && cityName.isNotEmpty) {
      return 'As you travel through $cityName, let the city open like a brief roadside documentary: its streets, older landmarks, and surrounding landscape all hint at the people who shaped it and the stories still moving through it today.';
    }

    final apiContext = RegExp(
      r'Current area context:\n([\s\S]*?)\n\nRecent travel history:',
    ).firstMatch(prompt)?.group(1);
    if (apiContext == null || apiContext.trim().isEmpty) {
      return 'Here is a quick local note for the road ahead. I will keep it short and avoid repeating earlier stops.';
    }

    final lines = apiContext
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.endsWith('available.'))
        .map((line) => line.replaceFirst(RegExp(r'^-\s*'), ''))
        .take(5)
        .join(' ');
    return lines;
  }

  List<Map<String, String>> _fallbackEntities(String narration) {
    final matches = RegExp(
      r'\b(?:[A-Z][a-z]+|[A-Z]{2,})(?:\s+(?:of|the|and|[A-Z][a-z]+|[A-Z]{2,})){0,4}\b',
    ).allMatches(narration);
    const ignored = {
      'As',
      'The',
      'This',
      'Here',
      'Its',
      'It',
      'You',
      'Your',
      'Their',
      'From',
      'Beyond',
      'Under',
    };
    final seen = <String>{};
    final entities = <Map<String, String>>[];

    for (final match in matches) {
      final label = match.group(0)?.trim();
      if (label == null || ignored.contains(label)) {
        continue;
      }
      final normalized = label.toLowerCase();
      if (!seen.add(normalized)) {
        continue;
      }
      entities.add({
        'label': label,
        'kind': _fallbackLooksLikePlace(label) ? 'place' : 'nonPlace',
      });
      if (entities.length >= 8) {
        break;
      }
    }
    return entities;
  }

  bool _fallbackLooksLikePlace(String label) {
    final normalized = label.toLowerCase();
    const placeTerms = [
      'park',
      'museum',
      'bridge',
      'mount',
      'mountain',
      'river',
      'lake',
      'bay',
      'beach',
      'trail',
      'peak',
      'valley',
      'square',
      'station',
      'theater',
      'theatre',
      'university',
      'downtown',
      'district',
      'historic',
      'landmark',
      'memorial',
      'center',
    ];
    return placeTerms.any(normalized.contains);
  }

  Iterable<String> _cleanFactLines(String text) {
    const labels = {
      'the roots',
      'the roots history & origin',
      'the icons',
      'the icons landmarks',
      'the canvas',
      'the canvas scenic viewpoints',
      'the legends',
      'the legends famous figures',
      'facts',
      'raw source notes',
    };

    return text
        .split('\n')
        .map((line) => line.trim().replaceFirst(RegExp(r'^-\s*'), ''))
        .where((line) => line.isNotEmpty)
        .where((line) => !line.endsWith('None found.'))
        .where((line) {
          final normalized = line
              .replaceAll(':', '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim()
              .toLowerCase();
          if (normalized.startsWith('city/town') ||
              normalized.startsWith('place')) {
            return false;
          }
          return !labels.contains(normalized);
        })
        .map(
          (line) => line.replaceFirst(
            RegExp(r'^current dining angle:\s*', caseSensitive: false),
            '',
          ),
        )
        .where((line) => line.trim().isNotEmpty);
  }

  bool _looksLikeAssistantChatter(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('how may i help') ||
        normalized.contains('how can i help') ||
        normalized.contains('i am here to help') ||
        normalized.contains("i'm here to help") ||
        normalized.contains('as an ai');
  }
}
