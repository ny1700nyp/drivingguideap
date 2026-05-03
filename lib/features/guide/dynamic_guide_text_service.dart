import '../../models/guide_content.dart';

class DynamicGuideTextService {
  const DynamicGuideTextService();

  /// Uses full LLM intro for speech and Live tab (same as stored history).
  String selectText({required GuideContent guide}) {
    return guide.fullText;
  }
}
