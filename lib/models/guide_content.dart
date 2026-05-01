class GuideContent {
  const GuideContent({
    required this.regionName,
    required this.fullText,
    required this.shortText,
    required this.generatedAt,
    this.links = const [],
    this.origin,
    this.localStoryOrNews,
    this.famousLocalFigure,
  });

  final String regionName;
  final String fullText;
  final String shortText;
  final DateTime generatedAt;
  final List<GuideLink> links;
  final String? origin;
  final String? localStoryOrNews;
  final String? famousLocalFigure;

  GuideContent copyWith({
    String? regionName,
    String? fullText,
    String? shortText,
    DateTime? generatedAt,
    List<GuideLink>? links,
    String? origin,
    String? localStoryOrNews,
    String? famousLocalFigure,
  }) {
    return GuideContent(
      regionName: regionName ?? this.regionName,
      fullText: fullText ?? this.fullText,
      shortText: shortText ?? this.shortText,
      generatedAt: generatedAt ?? this.generatedAt,
      links: links ?? this.links,
      origin: origin ?? this.origin,
      localStoryOrNews: localStoryOrNews ?? this.localStoryOrNews,
      famousLocalFigure: famousLocalFigure ?? this.famousLocalFigure,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionName': regionName,
      'origin': origin,
      'localStoryOrNews': localStoryOrNews,
      'famousLocalFigure': famousLocalFigure,
      'fullText': fullText,
      'shortText': shortText,
      'generatedAt': generatedAt.toIso8601String(),
      'links': links.map((link) => link.toJson()).toList(),
    };
  }
}

enum GuideLinkKind { map, search }

class GuideLink {
  const GuideLink({
    required this.label,
    required this.url,
    required this.kind,
  });

  final String label;
  final String url;
  final GuideLinkKind kind;

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'url': url,
      'kind': kind.name,
    };
  }
}
