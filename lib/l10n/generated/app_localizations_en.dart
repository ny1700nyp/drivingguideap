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
  String get fullNarrative => 'Full Narrative';

  @override
  String get noLocationYet => 'No location yet';

  @override
  String get currentArea => 'Current area';

  @override
  String get startAreaMonitoringPlaceholder => 'Start area monitoring.';

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
  String get cinematicStoryteller => 'Cinematic storyteller';

  @override
  String get localHistorian => 'Local historian';

  @override
  String get friendlyRoadCompanion => 'Friendly road companion';

  @override
  String get voiceSettings => 'Voice Settings';

  @override
  String get firstLlmPrompt => 'First LLM Prompt';

  @override
  String get noFirstLlmPrompt => 'No first LLM prompt generated yet.';

  @override
  String get liveGuide => 'Live Guide';

  @override
  String get details => 'Details';

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
}
