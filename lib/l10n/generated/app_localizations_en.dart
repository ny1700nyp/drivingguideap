// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Twingl Road';

  @override
  String get introductionTitle => 'Introduction';

  @override
  String get introductionButton => 'Introduction';

  @override
  String get introductionSummary =>
      'Live Guide layout, automatic guiding, Magazine links, and More settings—how they work together.';

  @override
  String get introductionBodyMain =>
      'Twingl Road is an audio-first travel guide for the road. As you pass through cities and towns, it introduces local history, landmarks, scenery, food, festivals, and notable people in a cinematic documentary style.\n\nWhen you open the app, guiding starts automatically so new towns can be introduced as you drive. On the Live Guide tab, the Live Narrative card fills the space from under the app title down to the tab bar: the area and narration appear over a full-width photo. Along the bottom of that card, icon-only controls run left to right—start guiding if needed, pause or resume playback, replay the narration, then pause guiding to stop continuous monitoring and location use for that session.\n\nThe Magazine tab gives you related links for the current area. Place links open in Maps, while people, events, and cultural references open in browser search.';

  @override
  String get introductionMoreAndroid =>
      'In More, you can choose the narration persona, check the current system language and voice.';

  @override
  String get introductionMoreIos =>
      'In More, you can choose the narration persona, check the current system language, and select a premium or enhanced TTS voice. On iOS, matching Settings > Apple Intelligence & Siri > Language with the app language can help local AI narration work more naturally.';

  @override
  String get loadingVoices => 'Loading voices...';

  @override
  String get systemDefaultEnglishVoice => 'Using the system default voice.';

  @override
  String voiceLoadError(Object error) {
    return 'Could not load voices: $error';
  }

  @override
  String voiceAvailabilityStatus(int count, Object quality) {
    return '$count premium/enhanced voice(s) available. Selected: $quality.';
  }

  @override
  String usingVoice(Object voiceName) {
    return 'Using $voiceName.';
  }

  @override
  String get startGuidingDialogTitle => 'Start Guiding?';

  @override
  String get startGuidingDialogMessage =>
      'Guiding active. I\'ll automatically introduce each new town\'s history, landmarks, and local flavors as you enter.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get fullNarrative => 'Full Narrative';

  @override
  String characterCount(int count) {
    return '$count characters';
  }

  @override
  String wordCount(int count) {
    return '$count words';
  }

  @override
  String get noLocationYet => 'No location yet';

  @override
  String get currentArea => 'Current area';

  @override
  String get startGuiding => 'Start Guiding';

  @override
  String get pauseGuide => 'Pause Guide';

  @override
  String get checkThisTown => 'Check This Town';

  @override
  String get startTestRoute => 'Start Sacramento to Seattle Test Route';

  @override
  String get stopTestRoute => 'Stop Test Route';

  @override
  String get prevStop => 'Prev Stop';

  @override
  String get nextStop => 'Next Stop';

  @override
  String get heritage => 'Heritage';

  @override
  String heritageBody(Object areaName) {
    return 'Name origin and the story that shaped $areaName.';
  }

  @override
  String get icons => 'Icons';

  @override
  String get iconsBody =>
      'Famous people and local episodes connected to this place.';

  @override
  String get views => 'Views';

  @override
  String get viewsBody =>
      'Scenic viewpoints and beautiful short detours nearby.';

  @override
  String get bites => 'Bites';

  @override
  String get bitesBody => 'A local food or drink stop worth remembering.';

  @override
  String get goods => 'Goods';

  @override
  String get goodsBody =>
      'Seasonal products, wine, beer, seafood, or agriculture.';

  @override
  String get trivia => 'Trivia';

  @override
  String get triviaBody =>
      'Film locations, festivals, events, and small local surprises.';

  @override
  String get digitalMagazine => 'Digital Magazine';

  @override
  String detailsIntro(Object areaName) {
    return 'Pull over and explore the deeper story behind $areaName.';
  }

  @override
  String get relatedLinks => 'Related Links';

  @override
  String get personaSettings => 'Persona Settings';

  @override
  String get narrativeStyle => 'Narrative style';

  @override
  String get cinematicStoryteller => 'Storyteller';

  @override
  String get localHistorian => 'Local historian';

  @override
  String get friendlyRoadCompanion => 'Friendly road companion';

  @override
  String get energeticTownWit => 'Energetic Town Wit';

  @override
  String get customPersonasSectionTitle => 'Your personas';

  @override
  String get customPersonaHint =>
      'Tone, role, attitude, and speaking style details for the narrator.';

  @override
  String get customPersonaTitleLabel => 'Title';

  @override
  String get customPersonaTitleHint => 'Short label shown in menus';

  @override
  String get customPersonaDescriptionLabel => 'Description';

  @override
  String get addCustomPersona => 'Add persona';

  @override
  String get removeCustomPersona => 'Remove persona';

  @override
  String get customPersonasMaxHint => 'You can save up to 24 custom personas.';

  @override
  String get routeHistoryTitle => 'Places you\'ve passed through';

  @override
  String get routeHistoryEmpty =>
      'After you hear a guided town intro for a place, it will appear here.';

  @override
  String get routeHistoryToday => 'Today';

  @override
  String get routeHistoryYesterday => 'Yesterday';

  @override
  String get routeHistoryDayBeforeYesterday => 'Day before yesterday';

  @override
  String get routeHistoryEarlier => 'Earlier trips';

  @override
  String get routeHistoryNoEntriesThatDay => 'No places saved for this day.';

  @override
  String get cityNarration => 'City narration';

  @override
  String get clearRouteHistoryTitle => 'Route history';

  @override
  String get clearRouteHistoryDescription =>
      'Remove all entries saved under Places you\'ve passed through.';

  @override
  String get clearRouteHistoryButton => 'Clear history';

  @override
  String get clearRouteHistoryConfirmTitle => 'Clear all route history?';

  @override
  String get clearRouteHistoryConfirmBody =>
      'Every saved town will be removed from this device. This can\'t be undone.';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String currentLanguage(Object languageName) {
    return 'Current System Language: $languageName';
  }

  @override
  String get appleIntelligenceSiriLanguageNotice =>
      'For the best local AI narration on iOS, match this language in Settings > Apple Intelligence & Siri > Language.';

  @override
  String get voiceSettings => 'Voice Settings';

  @override
  String get firstLlmPrompt => 'First LLM Prompt';

  @override
  String get noFirstLlmPrompt => 'No first LLM prompt generated yet.';

  @override
  String get liveGuide => 'Live Guide';

  @override
  String get details => 'Magazine';

  @override
  String get more => 'More';

  @override
  String get cruisingTowardsNextDiscovery =>
      'Cruising towards the next discovery.';

  @override
  String get liveNarrative => 'Live Narrative';

  @override
  String get expandNarrative => 'Expand narrative';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get replay => 'Replay';

  @override
  String get thinking => 'Thinking';

  @override
  String get noRelatedLinks => 'No related links prepared yet.';

  @override
  String get voice => 'Voice';

  @override
  String get systemDefault => 'System default';

  @override
  String get moreVoice => 'More voice?';

  @override
  String get moreVoiceDescription =>
      'You can add new voices in Settings > Accessibility > Read & Speak > Voices.';

  @override
  String get onDeviceNarrationNotice =>
      'On-device AI is not active. Please check system settings. Also confirm whether this device supports on-device AI.';
}
