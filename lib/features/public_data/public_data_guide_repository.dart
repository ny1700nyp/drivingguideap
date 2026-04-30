import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../models/guide_content.dart';

class PublicDataGuideRepository {
  PublicDataGuideRepository({
    http.Client? httpClient,
    String? npsApiKey,
    String? usdaApiKey,
  }) : _httpClient = httpClient ?? http.Client(),
       _npsApiKey = npsApiKey ?? const String.fromEnvironment('NPS_API_KEY'),
       _usdaApiKey = usdaApiKey ?? const String.fromEnvironment('USDA_API_KEY');

  final http.Client _httpClient;
  final String _npsApiKey;
  final String _usdaApiKey;

  Future<GuideContent> fetchGuideForRegion(String regionName) async {
    final now = DateTime.now();
    final origin = await _fetchRegionalContext(regionName);
    final specialty = await _fetchSeasonalSpecialty(regionName, now.month);
    final marketEvent = _marketMessageForToday(regionName, now);
    final specialtySentence = specialty == null
        ? null
        : 'This time of year, local produce to look for includes $specialty.';

    final fullText = [
      'Entering $regionName.',
      ?origin,
      ?specialtySentence,
      ?marketEvent,
    ].join(' ');

    final shortText = [
      '$regionName ahead.',
      if (specialty != null) 'Seasonal pick: $specialty.',
    ].join(' ');

    return GuideContent(
      regionName: regionName,
      origin: origin,
      seasonalSpecialty: specialty,
      marketEvent: marketEvent,
      fullText: fullText,
      shortText: shortText,
      generatedAt: now,
    );
  }

  Future<String?> _fetchRegionalContext(String regionName) async {
    if (_npsApiKey.isEmpty) {
      return _fallbackOrigin(regionName);
    }

    final uri = Uri.https('developer.nps.gov', '/api/v1/places', {
      'api_key': _npsApiKey,
      'q': regionName,
      'limit': '1',
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _fallbackOrigin(regionName);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final places = data['data'];
      if (places is! List || places.isEmpty) {
        return _fallbackOrigin(regionName);
      }

      final place = places.first as Map<String, dynamic>;
      final title = place['title'] as String?;
      final listingDescription = place['listingDescription'] as String?;
      final summary = place['description'] as String?;
      final description = listingDescription ?? summary;

      if (title == null && description == null) {
        return _fallbackOrigin(regionName);
      }

      return [
        if (title != null) 'Nearby point of interest: $title.',
        if (description != null) _trimSentence(description),
      ].join(' ');
    } catch (_) {
      return _fallbackOrigin(regionName);
    }
  }

  Future<String?> _fetchSeasonalSpecialty(String regionName, int month) async {
    if (_usdaApiKey.isEmpty) {
      return _fallbackSpecialty(month);
    }

    // TODO: Wire this to a selected USDA, state agriculture, or farmers market
    // dataset once the target coverage and fields are finalized.
    return _fallbackSpecialty(month);
  }

  String? _marketMessageForToday(String regionName, DateTime date) {
    final weekday = DateFormat('EEEE').format(date);

    // MVP placeholder until we connect a farmers market schedule dataset.
    if (weekday == 'Saturday' || weekday == 'Sunday') {
      return 'Weekend farmers markets may be open around $regionName today.';
    }
    return null;
  }

  String _fallbackOrigin(String regionName) {
    return '$regionName has its own mix of geography, local history, and roadside landmarks worth noticing as you pass through.';
  }

  String _fallbackSpecialty(int month) {
    const spring = 'asparagus, strawberries, and leafy greens';
    const summer = 'sweet corn, peaches, tomatoes, and berries';
    const autumn = 'apples, pumpkins, squash, and mushrooms';
    const winter = 'citrus, root vegetables, and winter greens';

    if (month >= 3 && month <= 5) {
      return spring;
    }
    if (month >= 6 && month <= 8) {
      return summer;
    }
    if (month >= 9 && month <= 11) {
      return autumn;
    }
    return winter;
  }

  String _trimSentence(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 180) {
      return normalized;
    }
    return '${normalized.substring(0, 180).trimRight()}...';
  }
}
