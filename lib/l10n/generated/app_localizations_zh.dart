// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Twingl Road';

  @override
  String get loadingVoices => '正在加载语音...';

  @override
  String get systemDefaultEnglishVoice => '正在使用系统默认语音。';

  @override
  String voiceLoadError(Object error) {
    return '无法加载语音: $error';
  }

  @override
  String voiceAvailabilityStatus(int count, Object quality) {
    return '可用的高级/增强语音有 $count 个。当前选择: $quality。';
  }

  @override
  String usingVoice(Object voiceName) {
    return '正在使用 $voiceName。';
  }

  @override
  String get startGuidingDialogTitle => '开始导览？';

  @override
  String get startGuidingDialogMessage => '导览将启用。当你进入新的城镇时，我会自动介绍当地的历史、地标和风味。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get fullNarrative => '完整旁白';

  @override
  String get noLocationYet => '尚无位置信息';

  @override
  String get currentArea => '当前位置';

  @override
  String get startAreaMonitoringPlaceholder => '开始区域导览。';

  @override
  String get startGuiding => '开始导览';

  @override
  String get pauseGuide => '暂停导览';

  @override
  String get checkThisTown => '查看此城镇';

  @override
  String get startTestRoute => '开始 Sacramento 到 Seattle 测试路线';

  @override
  String get stopTestRoute => '停止测试路线';

  @override
  String get prevStop => '上一站';

  @override
  String get nextStop => '下一站';

  @override
  String get heritage => '历史';

  @override
  String heritageBody(Object areaName) {
    return '$areaName名称由来与塑造它的故事。';
  }

  @override
  String get icons => '地标';

  @override
  String get iconsBody => '与此地相关的名人和本地故事。';

  @override
  String get views => '景观';

  @override
  String get viewsBody => '附近美丽的观景点和短途绕行路线。';

  @override
  String get bites => '风味';

  @override
  String get bitesBody => '值得记住的本地食物或饮品。';

  @override
  String get goods => '特产';

  @override
  String get goodsBody => '季节性产品、葡萄酒、啤酒、海鲜或农业。';

  @override
  String get trivia => '趣闻';

  @override
  String get triviaBody => '电影取景地、节庆活动和本地小惊喜。';

  @override
  String get digitalMagazine => '数字杂志';

  @override
  String detailsIntro(Object areaName) {
    return '停下来探索 $areaName 背后更深的故事。';
  }

  @override
  String get relatedLinks => '相关链接';

  @override
  String get personaSettings => '人设设置';

  @override
  String get narrativeStyle => '旁白风格';

  @override
  String get cinematicStoryteller => '电影感讲述者';

  @override
  String get localHistorian => '本地历史学者';

  @override
  String get friendlyRoadCompanion => '友好的旅途伙伴';

  @override
  String get voiceSettings => '语音设置';

  @override
  String get firstLlmPrompt => '第一阶段 LLM 提示词';

  @override
  String get noFirstLlmPrompt => '尚未生成第一阶段 LLM 提示词。';

  @override
  String get liveGuide => '实时导览';

  @override
  String get details => '详情';

  @override
  String get more => '更多';

  @override
  String get cruisingTowardsNextDiscovery => '正在驶向下一段发现。';

  @override
  String get liveNarrative => '实时旁白';

  @override
  String get expandNarrative => '展开旁白';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get replay => '重播';

  @override
  String get thinking => '思考中';

  @override
  String get noRelatedLinks => '尚未准备相关链接。';

  @override
  String get voice => '语音';

  @override
  String get systemDefault => '系统默认';

  @override
  String get moreVoice => '更多语音？';

  @override
  String get moreVoiceDescription => '你可以在“设置 > 辅助功能 > 朗读内容 > 声音”中添加新语音。';
}
