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
  String get introductionTitle => '介绍';

  @override
  String get introductionButton => 'Introduction';

  @override
  String get introductionSummary => '了解 Twingl Road 的用途，以及如何在路上使用它。';

  @override
  String get introductionBody =>
      'Twingl Road 是一款以音频为中心的公路旅行导览应用。当你经过城市和小镇时，它会以电影纪录片般的方式介绍当地历史、地标、风景、食物、节庆和知名人物。\n\n当你希望应用在进入每个新城镇时自动介绍当地故事，可以使用 Start Guiding。若只想在当前位置听一次导览，而不进行持续位置监测，可以使用 Check This Town。\n\n杂志标签页会显示当前区域的相关链接。地点会打开地图应用，人物、活动和文化关键词会打开浏览器搜索。\n\n在 More 中，你可以选择旁白人设、查看当前系统语言，并选择高级或增强 TTS 语音。在 iOS 上，将 Settings > Apple Intelligence & Siri > Language 与应用语言保持一致，有助于本地 AI 旁白更自然地工作。';

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
  String get save => '保存';

  @override
  String get fullNarrative => '完整旁白';

  @override
  String characterCount(int count) {
    return '$count字';
  }

  @override
  String wordCount(int count) {
    return '$count词';
  }

  @override
  String get noLocationYet => '尚无位置信息';

  @override
  String get currentArea => '当前位置';

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
  String get cinematicStoryteller => '讲述者';

  @override
  String get localHistorian => '本地历史学者';

  @override
  String get friendlyRoadCompanion => '友好的旅途伙伴';

  @override
  String get energeticTownWit => '活力城镇妙语者';

  @override
  String get customPersonasSectionTitle => '我的人设';

  @override
  String get customPersonaHint => '讲述者的语气、角色、态度和说话方式的详细说明。';

  @override
  String get customPersonaTitleLabel => '标题';

  @override
  String get customPersonaTitleHint => '菜单中显示的简短名称';

  @override
  String get customPersonaDescriptionLabel => '描述';

  @override
  String get addCustomPersona => '添加人设';

  @override
  String get removeCustomPersona => '删除';

  @override
  String get customPersonasMaxHint => '最多可保存 24 个自定义人设。';

  @override
  String get routeHistoryTitle => '经过的地点';

  @override
  String get routeHistoryEmpty => '听完城镇导览后，对应城市的记录会显示在这里。';

  @override
  String get cityNarration => '城市解说';

  @override
  String get clearRouteHistoryTitle => '路线记录';

  @override
  String get clearRouteHistoryDescription => '删除「经过的地点」下保存的所有条目。';

  @override
  String get clearRouteHistoryButton => '清除记录';

  @override
  String get clearRouteHistoryConfirmTitle => '清除全部路线记录？';

  @override
  String get clearRouteHistoryConfirmBody => '所有已保存的城市记录将从本设备移除，且无法撤销。';

  @override
  String get languageSettings => '语言设置';

  @override
  String currentLanguage(Object languageName) {
    return '当前系统语言: $languageName';
  }

  @override
  String get appleIntelligenceSiriLanguageNotice =>
      '为了在 iOS 上获得更好的本地 AI 旁白，请在“设置 > Apple Intelligence 与 Siri > 语言”中也选择相同语言。';

  @override
  String get voiceSettings => '语音设置';

  @override
  String get firstLlmPrompt => '第一阶段 LLM 提示词';

  @override
  String get noFirstLlmPrompt => '尚未生成第一阶段 LLM 提示词。';

  @override
  String get liveGuide => '实时导览';

  @override
  String get details => '杂志';

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

  @override
  String get onDeviceNarrationNotice => '设备端 AI 未启用。请检查系统设置，并确认本设备是否支持设备端 AI。';
}
