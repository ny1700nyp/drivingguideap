class TtsVoice {
  const TtsVoice({
    required this.name,
    required this.locale,
    required this.quality,
  });

  factory TtsVoice.fromMap(Map<dynamic, dynamic> map) {
    return TtsVoice(
      name: '${map['name'] ?? ''}',
      locale: '${map['locale'] ?? ''}',
      quality: '${map['quality'] ?? ''}',
    );
  }

  final String name;
  final String locale;
  final String quality;

  String get id => '$locale::$name';
  String get qualityLabel {
    final normalized = quality.trim();
    return normalized.isEmpty ? 'default' : normalized.toLowerCase();
  }

  String get displayName => name;
  bool get isPremium => quality.toLowerCase() == 'premium';
  bool get isEnhanced => quality.toLowerCase() == 'enhanced';
  bool get isPreferredQuality => isPremium || isEnhanced;
  int get qualityRank {
    if (isPremium) {
      return 0;
    }
    if (isEnhanced) {
      return 1;
    }
    return 2;
  }

  Map<String, String> toFlutterTtsVoice() {
    return {'name': name, 'locale': locale};
  }
}
