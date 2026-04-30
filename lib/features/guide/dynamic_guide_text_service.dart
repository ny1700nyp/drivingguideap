import '../../models/guide_content.dart';

class DynamicGuideTextService {
  const DynamicGuideTextService({this.fastDrivingThresholdMph = 40});

  final double fastDrivingThresholdMph;

  String selectText({required GuideContent guide, required double speedMph}) {
    if (speedMph >= fastDrivingThresholdMph) {
      return _limitLength(guide.shortText, 55);
    }
    return guide.fullText;
  }

  String _limitLength(String text, int maxCharacters) {
    if (text.length <= maxCharacters) {
      return text;
    }
    return '${text.substring(0, maxCharacters).trimRight()}...';
  }
}
