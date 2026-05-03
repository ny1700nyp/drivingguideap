import 'dart:convert';

import 'package:http/http.dart' as http;

/// Free tier, no API key — https://open-meteo.com/
abstract final class OpenMeteoWeatherService {
  OpenMeteoWeatherService._();

  /// Spoken-friendly clause in [outputLanguage], or null if unavailable.
  static String _normalizeLang(String outputLanguage) {
    switch (outputLanguage.trim().toLowerCase()) {
      case 'korean':
        return 'korean';
      case 'japanese':
        return 'japanese';
      case 'chinese':
        return 'chinese';
      case 'spanish':
        return 'spanish';
      case 'german':
        return 'german';
      case 'french':
        return 'french';
      default:
        return 'english';
    }
  }

  /// Spoken-friendly clause in [outputLanguage], or null if unavailable.
  static Future<String?> fetchCurrentBrief({
    required double latitude,
    required double longitude,
    required bool imperial,
    required String outputLanguage,
  }) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current': 'temperature_2m,weather_code',
        'temperature_unit': imperial ? 'fahrenheit' : 'celsius',
      });
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final current = decoded['current'];
      if (current is! Map<String, dynamic>) return null;
      final temp = current['temperature_2m'];
      final code = current['weather_code'];
      if (temp is! num || code is! num) return null;
      final sym = imperial ? '°F' : '°C';
      final lang = _normalizeLang(outputLanguage);
      final t = temp.round();
      final desc = _describeWeatherCode(code.round(), lang);
      return _formatTemperatureLine(lang, t, sym, desc);
    } catch (_) {
      return null;
    }
  }

  static String _formatTemperatureLine(
    String lang,
    int tempRounded,
    String degreeSym,
    String description,
  ) {
    return switch (lang) {
      'korean' => '약 $tempRounded$degreeSym, $description',
      'japanese' => 'おおよそ$tempRounded$degreeSym、$description',
      'chinese' => '大约 $tempRounded$degreeSym，$description',
      'spanish' => 'unos $tempRounded$degreeSym, con $description',
      'german' => 'etwa $tempRounded$degreeSym, $description',
      'french' => 'environ $tempRounded$degreeSym, avec $description',
      _ => 'about $tempRounded$degreeSym with $description',
    };
  }

  /// WMO Weather interpretation codes (Open-Meteo documentation).
  static String _describeWeatherCode(int code, String lang) {
    final i = _weatherPhraseIndex(code);
    return switch (lang) {
      'korean' => _koPhrases[i],
      'japanese' => _jaPhrases[i],
      'chinese' => _zhPhrases[i],
      'spanish' => _esPhrases[i],
      'german' => _dePhrases[i],
      'french' => _frPhrases[i],
      _ => _enPhrases[i],
    };
  }

  /// Maps code bucket to phrase table index 0..9.
  static int _weatherPhraseIndex(int code) {
    if (code == 0) return 0;
    if (code <= 3) return 1;
    if (code <= 48) return 2;
    if (code <= 57) return 3;
    if (code <= 67) return 4;
    if (code <= 77) return 5;
    if (code <= 82) return 6;
    if (code <= 86) return 7;
    if (code <= 99) return 8;
    return 9;
  }

  static const _enPhrases = [
    'clear skies',
    'mixed clouds',
    'fog or haze',
    'light drizzle',
    'rain',
    'snow',
    'rain showers',
    'snow showers',
    'stormy conditions',
    'changing skies',
  ];

  static const _koPhrases = [
    '맑은 하늘',
    '구름이 낀 하늘',
    '안개나 연무',
    '가벼운 이슬비',
    '비',
    '눈',
    '소나기',
    '눈 소나기',
    '천둥번개나 폭우',
    '변하기 쉬운 하늘',
  ];

  static const _jaPhrases = [
    '快晴',
    'くもりがち',
    '霧やかすみ',
    '小雨',
    '雨',
    '雪',
    'にわか雨',
    '雪のにわか',
    '嵐の様相',
    '変わりやすい空模様',
  ];

  static const _zhPhrases = [
    '晴朗',
    '多云',
    '雾或霾',
    '小毛毛雨',
    '雨',
    '雪',
    '阵雨',
    '阵雪',
    '雷雨天气',
    '阴晴多变',
  ];

  static const _esPhrases = [
    'cielo despejado',
    'nubes dispersas',
    'niebla o calima',
    'llovizna ligera',
    'lluvia',
    'nieve',
    'chubascos de lluvia',
    'chubascos de nieve',
    'tormenta',
    'cielo cambiante',
  ];

  static const _dePhrases = [
    'klarer Himmel',
    'wechselnde Bewölkung',
    'Nebel oder Dunst',
    'leichter Nieselregen',
    'Regen',
    'Schnee',
    'Regenschauer',
    'Schneeschauer',
    'stürmisch',
    'wechselhafter Himmel',
  ];

  static const _frPhrases = [
    'ciel dégagé',
    'nuages variables',
    'brouillard ou brume',
    'bruine légère',
    'pluie',
    'neige',
    'averses de pluie',
    'averses de neige',
    'conditions orageuses',
    'ciel changeant',
  ];
}
