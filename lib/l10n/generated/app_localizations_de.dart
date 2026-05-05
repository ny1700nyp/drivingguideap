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
  String get introductionTitle => 'Einführung';

  @override
  String get introductionButton => 'Introduction';

  @override
  String get introductionSummary =>
      'Live Guide-Ansicht, automatischer Start, Magazin-Links und More-Einstellungen im Überblick.';

  @override
  String get introductionBodyMain =>
      'Twingl Road ist ein audiobasierter Reiseführer für die Straße. Während du durch Städte und Orte fährst, erzählt die App lokale Geschichte, Wahrzeichen, Landschaften, Essen, Festivals und bekannte Persönlichkeiten im Stil einer filmischen Dokumentation.\n\nBeim Öffnen der App startet die Führung automatisch, sodass neue Orte beim Einfahren vorgestellt werden können. Auf dem Tab „Live Guide“ füllt die Karte „Live Narrative“ den Bereich von unter der App-Leiste bis knapp über die untere Navigationsleiste: über ein Foto in voller Breite erscheinen Ortsname und Erzähltext. Unten an der Karte stehen nur Symbole in einer Reihe—bei Bedarf Führung starten, Wiedergabe pausieren oder fortsetzen, Erzählung erneut abspielen und die Führung pausieren, um das kontinuierliche Monitoring und die Standortnutzung für diese Sitzung zu beenden.\n\nDer Magazin-Tab zeigt passende Links zum aktuellen Gebiet. Orte werden in Karten geöffnet, Personen, Ereignisse und kulturelle Begriffe in der Browsersuche.';

  @override
  String get introductionMoreAndroid =>
      'Unter More kannst du die Erzähl-Persona, die aktuelle Systemsprache und die Stimme auswählen.';

  @override
  String get introductionMoreIos =>
      'Unter More kannst du die Erzähl-Persona, die aktuelle Systemsprache und eine Premium- oder erweiterte TTS-Stimme auswählen. Unter iOS kann es helfen, Settings > Apple Intelligence & Siri > Language an die App-Sprache anzupassen, damit lokale KI-Erzählungen natürlicher funktionieren.';

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
  String get save => 'Speichern';

  @override
  String get fullNarrative => 'Vollständige Erzählung';

  @override
  String characterCount(int count) {
    return '$count Zeichen';
  }

  @override
  String wordCount(int count) {
    return '$count Wörter';
  }

  @override
  String get noLocationYet => 'Noch kein Standort';

  @override
  String get currentArea => 'Aktueller Bereich';

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
  String get cinematicStoryteller => 'Erzähler';

  @override
  String get localHistorian => 'Lokaler Historiker';

  @override
  String get friendlyRoadCompanion => 'Freundlicher Reisebegleiter';

  @override
  String get energeticTownWit => 'Energiegeladener Ortswitz';

  @override
  String get customPersonasSectionTitle => 'Eigene Personas';

  @override
  String get customPersonaHint =>
      'Tonfall, Rolle, Haltung und konkrete Sprechweise des Erzählers.';

  @override
  String get customPersonaTitleLabel => 'Titel';

  @override
  String get customPersonaTitleHint => 'Kurzer Name in den Menüs';

  @override
  String get customPersonaDescriptionLabel => 'Beschreibung';

  @override
  String get addCustomPersona => 'Persona hinzufügen';

  @override
  String get removeCustomPersona => 'Entfernen';

  @override
  String get customPersonasMaxHint =>
      'Du kannst bis zu 24 eigene Personas speichern.';

  @override
  String get routeHistoryTitle => 'Orte auf deiner Route';

  @override
  String get routeHistoryEmpty =>
      'Nach einer Stadtführung erscheint der Ort hier.';

  @override
  String get routeHistoryToday => 'Heute';

  @override
  String get routeHistoryYesterday => 'Gestern';

  @override
  String get routeHistoryDayBeforeYesterday => 'Vorgestern';

  @override
  String get routeHistoryEarlier => 'Frühere Fahrten';

  @override
  String get routeHistoryNoEntriesThatDay =>
      'Für diesen Tag sind keine Orte gespeichert.';

  @override
  String get cityNarration => 'Stadterzählung';

  @override
  String get clearRouteHistoryTitle => 'Routen-Verlauf';

  @override
  String get clearRouteHistoryDescription =>
      'Entfernt alle unter „Orte auf deiner Route“ gespeicherten Einträge.';

  @override
  String get clearRouteHistoryButton => 'Verlauf löschen';

  @override
  String get clearRouteHistoryConfirmTitle =>
      'Gesamten Routen-Verlauf löschen?';

  @override
  String get clearRouteHistoryConfirmBody =>
      'Alle gespeicherten Orte werden von diesem Gerät entfernt. Das lässt sich nicht rückgängig machen.';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String currentLanguage(Object languageName) {
    return 'Aktuelle Systemsprache: $languageName';
  }

  @override
  String get appleIntelligenceSiriLanguageNotice =>
      'Für bessere lokale KI-Erzählungen unter iOS stelle dieselbe Sprache unter Einstellungen > Apple Intelligence & Siri > Sprache ein.';

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
  String get details => 'Magazin';

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

  @override
  String get onDeviceNarrationNotice =>
      'On-device-KI ist nicht aktiv. Bitte die Systemeinstellungen prüfen. Prüfen Sie außerdem, ob dieses Gerät On-device-KI unterstützt.';

  @override
  String get idlePauseNotificationBody =>
      'Pause. Weck mich für die nächste Geschichte.';

  @override
  String get supportSectionTitle => 'Support';

  @override
  String get helpAndSupport => 'Hilfe und Support';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicyMenu => 'Datenschutzerklärung';

  @override
  String get supportDocumentLoadError =>
      'Dieses Dokument konnte nicht geladen werden. Prüfen Sie Ihre Verbindung und versuchen Sie es erneut.';
}
