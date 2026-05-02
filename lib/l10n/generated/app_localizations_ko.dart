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
  String get fullNarrative => '전체 내레이션';

  @override
  String get noLocationYet => '아직 위치 없음';

  @override
  String get currentArea => '현재 지역';

  @override
  String get startAreaMonitoringPlaceholder => '지역 가이드를 시작하세요.';

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
  String get cinematicStoryteller => '시네마틱 스토리텔러';

  @override
  String get localHistorian => '로컬 역사가';

  @override
  String get friendlyRoadCompanion => '친근한 로드 동반자';

  @override
  String get voiceSettings => '보이스 설정';

  @override
  String get firstLlmPrompt => '1차 LLM 프롬프트';

  @override
  String get noFirstLlmPrompt => '아직 생성된 1차 LLM 프롬프트가 없습니다.';

  @override
  String get liveGuide => '라이브 가이드';

  @override
  String get details => '상세';

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
}
