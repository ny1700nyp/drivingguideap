class GuideContent {
  const GuideContent({
    required this.regionName,
    required this.fullText,
    required this.shortText,
    required this.generatedAt,
    this.origin,
    this.seasonalSpecialty,
    this.marketEvent,
  });

  final String regionName;
  final String fullText;
  final String shortText;
  final DateTime generatedAt;
  final String? origin;
  final String? seasonalSpecialty;
  final String? marketEvent;

  Map<String, dynamic> toJson() {
    return {
      'regionName': regionName,
      'origin': origin,
      'seasonalSpecialty': seasonalSpecialty,
      'marketEvent': marketEvent,
      'fullText': fullText,
      'shortText': shortText,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
