// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Twingl Road';

  @override
  String get loadingVoices => 'Stimmen werden geladen...';

  @override
  String get systemDefaultEnglishVoice => 'Die Systemstimme wird verwendet.';

  @override
  String voiceLoadError(Object error) {
    return 'Stimmen konnten nicht geladen werden: $error';
  }

  @override
  String voiceAvailabilityStatus(int count, Object quality) {
    return '$count Premium-/erweiterte Stimme(n) verfügbar. Ausgewählt: $quality.';
  }

  @override
  String usingVoice(Object voiceName) {
    return '$voiceName wird verwendet.';
  }

  @override
  String get startGuidingDialogTitle => 'Führung starten?';

  @override
  String get startGuidingDialogMessage =>
      'Die Führung wird aktiviert. Ich stelle automatisch die Geschichte, Wahrzeichen und lokalen Spezialitäten jeder neuen Stadt vor, in die du einfährst.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get fullNarrative => 'Vollständige Erzählung';

  @override
  String get noLocationYet => 'Noch kein Standort';

  @override
  String get currentArea => 'Aktueller Bereich';

  @override
  String get startAreaMonitoringPlaceholder => 'Starte die Gebietsführung.';

  @override
  String get startGuiding => 'Führung starten';

  @override
  String get pauseGuide => 'Führung pausieren';

  @override
  String get checkThisTown => 'Diesen Ort prüfen';

  @override
  String get startTestRoute => 'Teststrecke Sacramento nach Seattle starten';

  @override
  String get stopTestRoute => 'Teststrecke stoppen';

  @override
  String get prevStop => 'Vorheriger Halt';

  @override
  String get nextStop => 'Nächster Halt';

  @override
  String get heritage => 'Geschichte';

  @override
  String heritageBody(Object areaName) {
    return 'Namensursprung und die Geschichte, die $areaName geprägt hat.';
  }

  @override
  String get icons => 'Ikonen';

  @override
  String get iconsBody =>
      'Berühmte Personen und lokale Episoden, die mit diesem Ort verbunden sind.';

  @override
  String get views => 'Ausblicke';

  @override
  String get viewsBody =>
      'Schöne Aussichtspunkte und kurze lohnende Abstecher in der Nähe.';

  @override
  String get bites => 'Genuss';

  @override
  String get bitesBody =>
      'Ein lokales Essen oder Getränk, das in Erinnerung bleibt.';

  @override
  String get goods => 'Produkte';

  @override
  String get goodsBody =>
      'Saisonale Produkte, Wein, Bier, Meeresfrüchte oder Landwirtschaft.';

  @override
  String get trivia => 'Trivia';

  @override
  String get triviaBody =>
      'Drehorte, Festivals, Veranstaltungen und kleine lokale Überraschungen.';

  @override
  String get digitalMagazine => 'Digitales Magazin';

  @override
  String detailsIntro(Object areaName) {
    return 'Halte kurz an und entdecke die tiefere Geschichte hinter $areaName.';
  }

  @override
  String get relatedLinks => 'Verwandte Links';

  @override
  String get personaSettings => 'Persona-Einstellungen';

  @override
  String get narrativeStyle => 'Erzählstil';

  @override
  String get cinematicStoryteller => 'Filmischer Erzähler';

  @override
  String get localHistorian => 'Lokaler Historiker';

  @override
  String get friendlyRoadCompanion => 'Freundlicher Reisebegleiter';

  @override
  String get voiceSettings => 'Stimmeneinstellungen';

  @override
  String get firstLlmPrompt => 'Erster LLM-Prompt';

  @override
  String get noFirstLlmPrompt =>
      'Es wurde noch kein erster LLM-Prompt generiert.';

  @override
  String get liveGuide => 'Live-Guide';

  @override
  String get details => 'Details';

  @override
  String get more => 'Mehr';

  @override
  String get cruisingTowardsNextDiscovery => 'Weiter zur nächsten Entdeckung.';

  @override
  String get liveNarrative => 'Live-Erzählung';

  @override
  String get expandNarrative => 'Erzählung erweitern';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get replay => 'Erneut abspielen';

  @override
  String get thinking => 'Denke nach';

  @override
  String get noRelatedLinks => 'Noch keine verwandten Links vorbereitet.';

  @override
  String get voice => 'Stimme';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get moreVoice => 'Mehr Stimmen?';

  @override
  String get moreVoiceDescription =>
      'Neue Stimmen kannst du unter Einstellungen > Bedienungshilfen > Gesprochene Inhalte > Stimmen hinzufügen.';
}
