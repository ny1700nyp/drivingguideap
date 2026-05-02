// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Twingl Road';

  @override
  String get loadingVoices => 'Chargement des voix...';

  @override
  String get systemDefaultEnglishVoice =>
      'Utilisation de la voix par défaut du système.';

  @override
  String voiceLoadError(Object error) {
    return 'Impossible de charger les voix : $error';
  }

  @override
  String voiceAvailabilityStatus(int count, Object quality) {
    return '$count voix premium/améliorée(s) disponible(s). Sélection : $quality.';
  }

  @override
  String usingVoice(Object voiceName) {
    return 'Utilisation de $voiceName.';
  }

  @override
  String get startGuidingDialogTitle => 'Démarrer le guidage ?';

  @override
  String get startGuidingDialogMessage =>
      'Le guidage sera activé. Je présenterai automatiquement l\'histoire, les monuments et les saveurs locales de chaque nouvelle ville où vous entrez.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get fullNarrative => 'Narration complète';

  @override
  String get noLocationYet => 'Aucune position pour le moment';

  @override
  String get currentArea => 'Zone actuelle';

  @override
  String get startAreaMonitoringPlaceholder => 'Démarrez le guide de la zone.';

  @override
  String get startGuiding => 'Démarrer le guide';

  @override
  String get pauseGuide => 'Mettre le guide en pause';

  @override
  String get checkThisTown => 'Explorer cette ville';

  @override
  String get startTestRoute => 'Démarrer l\'itinéraire test Sacramento-Seattle';

  @override
  String get stopTestRoute => 'Arrêter l\'itinéraire test';

  @override
  String get prevStop => 'Étape précédente';

  @override
  String get nextStop => 'Étape suivante';

  @override
  String get heritage => 'Patrimoine';

  @override
  String heritageBody(Object areaName) {
    return 'L\'origine du nom et l\'histoire qui a façonné $areaName.';
  }

  @override
  String get icons => 'Icônes';

  @override
  String get iconsBody =>
      'Personnes célèbres et épisodes locaux liés à ce lieu.';

  @override
  String get views => 'Vues';

  @override
  String get viewsBody => 'Points de vue et beaux petits détours à proximité.';

  @override
  String get bites => 'Saveurs';

  @override
  String get bitesBody => 'Une spécialité ou boisson locale à retenir.';

  @override
  String get goods => 'Produits';

  @override
  String get goodsBody =>
      'Produits de saison, vin, bière, fruits de mer ou agriculture.';

  @override
  String get trivia => 'Anecdotes';

  @override
  String get triviaBody =>
      'Lieux de tournage, festivals, événements et petites surprises locales.';

  @override
  String get digitalMagazine => 'Magazine numérique';

  @override
  String detailsIntro(Object areaName) {
    return 'Arrêtez-vous un instant pour explorer l\'histoire plus profonde de $areaName.';
  }

  @override
  String get relatedLinks => 'Liens associés';

  @override
  String get personaSettings => 'Paramètres de persona';

  @override
  String get narrativeStyle => 'Style de narration';

  @override
  String get cinematicStoryteller => 'Conteur cinématographique';

  @override
  String get localHistorian => 'Historien local';

  @override
  String get friendlyRoadCompanion => 'Compagnon de route chaleureux';

  @override
  String get voiceSettings => 'Paramètres de voix';

  @override
  String get firstLlmPrompt => 'Premier prompt LLM';

  @override
  String get noFirstLlmPrompt =>
      'Aucun premier prompt LLM n\'a encore été généré.';

  @override
  String get liveGuide => 'Guide en direct';

  @override
  String get details => 'Détails';

  @override
  String get more => 'Plus';

  @override
  String get cruisingTowardsNextDiscovery =>
      'En route vers la prochaine découverte.';

  @override
  String get liveNarrative => 'Narration en direct';

  @override
  String get expandNarrative => 'Développer la narration';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get replay => 'Réécouter';

  @override
  String get thinking => 'Réflexion';

  @override
  String get noRelatedLinks => 'Aucun lien associé n\'est encore prêt.';

  @override
  String get voice => 'Voix';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get moreVoice => 'Plus de voix ?';

  @override
  String get moreVoiceDescription =>
      'Vous pouvez ajouter de nouvelles voix dans Réglages > Accessibilité > Contenu énoncé > Voix.';
}
