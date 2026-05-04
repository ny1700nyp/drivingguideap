// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Twingl Road';

  @override
  String get introductionTitle => '소개';

  @override
  String get introductionButton => 'Introduction';

  @override
  String get introductionSummary =>
      'Live Guide 화면 구성, 자동 가이드 시작, 매거진 링크, More 설정까지 한눈에 정리합니다.';

  @override
  String get introductionBodyMain =>
      'Twingl Road는 운전 중 지나가는 도시와 타운의 이야기를 오디오 중심으로 들려주는 여행 가이드 앱입니다. 새로운 지역을 지나갈 때마다 역사, 랜드마크, 자연 풍경, 지역 음식, 축제, 유명 인물 같은 이야기를 시네마틱 다큐멘터리처럼 소개합니다.\n\n앱을 열면 가이드가 자동으로 시작되어, 새로운 타운에 들어설 때 소개를 들을 수 있습니다. Live Guide 탭의 Live Narrative 카드는 앱 제목 아래부터 하단 탭 바로 위까지 세로로 꽉 차며, 가로 전체 사진 위에 지역 이름과 내레이션 텍스트가 보입니다. 카드 하단에는 텍스트 없이 아이콘만 있는 버튼이 왼쪽부터 차례로 배치됩니다—필요 시 가이드 시작, 재생 일시정지·재개, 다시 듣기, 그리고 연속 모니터링을 끝내는 가이드 일시정지(Pause Guide)입니다.\n\n매거진 탭에서는 현재 지역과 관련된 링크를 볼 수 있습니다. 장소는 지도 앱으로, 인물이나 이벤트, 문화적 키워드는 브라우저 검색으로 연결됩니다.';

  @override
  String get introductionMoreAndroid =>
      'More에서는 내레이션 페르소나, 현재 시스템 언어와 보이스를 설정할 수 있습니다.';

  @override
  String get introductionMoreIos =>
      'More에서는 내레이션 페르소나, 현재 시스템 언어, TTS 보이스를 설정할 수 있습니다. iOS에서는 Settings > Apple Intelligence & Siri > Language를 앱 언어와 맞추면 로컬 AI 내레이션이 더 자연스럽게 동작하는 데 도움이 됩니다.';

  @override
  String get loadingVoices => '보이스를 불러오는 중...';

  @override
  String get systemDefaultEnglishVoice => '시스템 기본 보이스를 사용합니다.';

  @override
  String voiceLoadError(Object error) {
    return '보이스를 불러올 수 없습니다: $error';
  }

  @override
  String voiceAvailabilityStatus(int count, Object quality) {
    return '프리미엄/향상된 보이스 $count개 사용 가능. 선택됨: $quality.';
  }

  @override
  String usingVoice(Object voiceName) {
    return '$voiceName 보이스를 사용합니다.';
  }

  @override
  String get startGuidingDialogTitle => '가이드를 시작할까요?';

  @override
  String get startGuidingDialogMessage =>
      '가이드가 활성화됩니다. 새로운 타운에 들어갈 때마다 역사, 랜드마크, 로컬 풍미를 자동으로 소개합니다.';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get save => '저장';

  @override
  String get fullNarrative => '전체 내레이션';

  @override
  String characterCount(int count) {
    return '$count자';
  }

  @override
  String wordCount(int count) {
    return '$count단어';
  }

  @override
  String get noLocationYet => '아직 위치 없음';

  @override
  String get currentArea => '현재 지역';

  @override
  String get startGuiding => '가이드 시작';

  @override
  String get pauseGuide => '가이드 일시정지';

  @override
  String get checkThisTown => '이 타운 확인';

  @override
  String get startTestRoute => 'Sacramento to Seattle 테스트 루트 시작';

  @override
  String get stopTestRoute => '테스트 루트 중지';

  @override
  String get prevStop => '이전 지점';

  @override
  String get nextStop => '다음 지점';

  @override
  String get heritage => '유산';

  @override
  String heritageBody(Object areaName) {
    return '$areaName을 만든 이름의 유래와 이야기.';
  }

  @override
  String get icons => '아이콘';

  @override
  String get iconsBody => '이 지역과 연결된 유명 인물과 로컬 에피소드.';

  @override
  String get views => '전망';

  @override
  String get viewsBody => '근처의 아름다운 전망지와 짧은 우회 코스.';

  @override
  String get bites => '맛';

  @override
  String get bitesBody => '기억할 만한 로컬 음식 또는 음료.';

  @override
  String get goods => '특산품';

  @override
  String get goodsBody => '계절 농산물, 와인, 맥주, 해산물 또는 농업 이야기.';

  @override
  String get trivia => '트리비아';

  @override
  String get triviaBody => '영화 촬영지, 축제, 이벤트, 작은 로컬 이야기.';

  @override
  String get digitalMagazine => '디지털 매거진';

  @override
  String detailsIntro(Object areaName) {
    return '잠시 멈춰 $areaName 뒤의 더 깊은 이야기를 살펴보세요.';
  }

  @override
  String get relatedLinks => '관련 링크';

  @override
  String get personaSettings => '페르소나 설정';

  @override
  String get narrativeStyle => '내레이션 스타일';

  @override
  String get cinematicStoryteller => '스토리텔러';

  @override
  String get localHistorian => '로컬 역사가';

  @override
  String get friendlyRoadCompanion => '친근한 로드 동반자';

  @override
  String get energeticTownWit => '활기찬 타운 재치꾼';

  @override
  String get customPersonasSectionTitle => '내 페르소나';

  @override
  String get customPersonaHint => '내레이터의 말투, 역할, 태도, 말하는 방식 등 구체적으로 적어 보세요.';

  @override
  String get customPersonaTitleLabel => '제목';

  @override
  String get customPersonaTitleHint => '메뉴에 표시되는 짧은 이름';

  @override
  String get customPersonaDescriptionLabel => '설명';

  @override
  String get addCustomPersona => '페르소나 추가';

  @override
  String get removeCustomPersona => '페르소나 삭제';

  @override
  String get customPersonasMaxHint => '사용자 페르소나는 최대 24개까지 저장할 수 있습니다.';

  @override
  String get routeHistoryTitle => '지나온 경로';

  @override
  String get routeHistoryEmpty => '타운 가이드를 들으면 해당 도시 기록이 여기에 쌓입니다.';

  @override
  String get routeHistoryToday => '오늘';

  @override
  String get routeHistoryYesterday => '어제';

  @override
  String get routeHistoryDayBeforeYesterday => '그저께';

  @override
  String get routeHistoryEarlier => '이전 기록';

  @override
  String get routeHistoryNoEntriesThatDay => '이 날짜에 저장된 경로가 없습니다.';

  @override
  String get cityNarration => '도시 내레이션';

  @override
  String get clearRouteHistoryTitle => '경로 기록';

  @override
  String get clearRouteHistoryDescription => '「지나온 경로」에 저장된 항목을 모두 삭제합니다.';

  @override
  String get clearRouteHistoryButton => '기록 지우기';

  @override
  String get clearRouteHistoryConfirmTitle => '경로 기록을 모두 지울까요?';

  @override
  String get clearRouteHistoryConfirmBody =>
      '저장된 모든 도시 기록이 이 기기에서 삭제됩니다. 되돌릴 수 없습니다.';

  @override
  String get languageSettings => '언어 설정';

  @override
  String currentLanguage(Object languageName) {
    return '현재 시스템 언어: $languageName';
  }

  @override
  String get appleIntelligenceSiriLanguageNotice =>
      'iOS에서 더 좋은 로컬 AI 내레이션을 위해 Settings > Apple Intelligence & Siri > Language의 언어도 이 언어와 일치시켜 주세요.';

  @override
  String get voiceSettings => '보이스 설정';

  @override
  String get firstLlmPrompt => '1차 LLM 프롬프트';

  @override
  String get noFirstLlmPrompt => '아직 생성된 1차 LLM 프롬프트가 없습니다.';

  @override
  String get liveGuide => '라이브 가이드';

  @override
  String get details => '매거진';

  @override
  String get more => '더보기';

  @override
  String get cruisingTowardsNextDiscovery => '다음 발견을 향해 이동 중입니다.';

  @override
  String get liveNarrative => '라이브 내레이션';

  @override
  String get expandNarrative => '내레이션 펼치기';

  @override
  String get pause => '일시정지';

  @override
  String get resume => '재개';

  @override
  String get replay => '다시 듣기';

  @override
  String get thinking => '생각 중';

  @override
  String get noRelatedLinks => '아직 준비된 관련 링크가 없습니다.';

  @override
  String get voice => '보이스';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get moreVoice => '더 많은 보이스?';

  @override
  String get moreVoiceDescription =>
      '새 보이스는 설정 > 손쉬운 사용 > 읽기 및 말하기 > 보이스에서 추가할 수 있습니다.';

  @override
  String get onDeviceNarrationNotice =>
      '온디바이스 AI가 활성화되어 있지 않습니다. 시스템 설정을 확인해 주세요. 이 기기가 온디바이스 AI를 지원하는지도 확인해 보세요.';
}
