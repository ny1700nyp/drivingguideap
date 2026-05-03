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
  String get introductionTitle => 'Introduction';

  @override
  String get introductionButton => 'Introduction';

  @override
  String get introductionSummary =>
      'Découvrez ce que fait Twingl Road et comment l\'utiliser sur la route.';

  @override
  String get introductionBody =>
      'Twingl Road est un guide de voyage pensé d\'abord pour l\'audio. Lorsque vous traversez des villes et villages, il présente l\'histoire locale, les monuments, les paysages, la cuisine, les festivals et les personnalités marquantes dans un style de documentaire cinématographique.\n\nUtilisez Start Guiding si vous voulez que l\'app présente automatiquement chaque nouvelle ville lorsque vous y entrez. Utilisez Check This Town si vous voulez écouter une seule fois le guide de votre position actuelle, sans surveillance continue.\n\nL\'onglet Magazine propose des liens liés à la zone actuelle. Les lieux s\'ouvrent dans Plans, tandis que les personnes, événements et références culturelles s\'ouvrent dans une recherche navigateur.\n\nDans More, vous pouvez choisir la persona de narration, vérifier la langue système actuelle et sélectionner une voix TTS premium ou améliorée. Sur iOS, faire correspondre Settings > Apple Intelligence & Siri > Language avec la langue de l\'app peut aider la narration IA locale à fonctionner plus naturellement.';

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
  String get save => 'Enregistrer';

  @override
  String get fullNarrative => 'Narration complète';

  @override
  String characterCount(int count) {
    return '$count caractères';
  }

  @override
  String wordCount(int count) {
    return '$count mots';
  }

  @override
  String get noLocationYet => 'Aucune position pour le moment';

  @override
  String get currentArea => 'Zone actuelle';

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
  String get cinematicStoryteller => 'Conteur';

  @override
  String get localHistorian => 'Historien local';

  @override
  String get friendlyRoadCompanion => 'Compagnon de route chaleureux';

  @override
  String get energeticTownWit => 'Esprit local énergique';

  @override
  String get customPersonasSectionTitle => 'Vos personas';

  @override
  String get customPersonaHint =>
      'Ton, rôle, attitude et style oral détaillés du narrateur.';

  @override
  String get customPersonaTitleLabel => 'Titre';

  @override
  String get customPersonaTitleHint => 'Nom court affiché dans les menus';

  @override
  String get customPersonaDescriptionLabel => 'Description';

  @override
  String get addCustomPersona => 'Ajouter une persona';

  @override
  String get removeCustomPersona => 'Supprimer';

  @override
  String get customPersonasMaxHint =>
      'Vous pouvez enregistrer jusqu’à 24 personas personnalisées.';

  @override
  String get routeHistoryTitle => 'Lieux traversés';

  @override
  String get routeHistoryEmpty =>
      'Après une présentation guidée d’une ville, elle apparaît ici.';

  @override
  String get cityNarration => 'Récit de la ville';

  @override
  String get clearRouteHistoryTitle => 'Historique de route';

  @override
  String get clearRouteHistoryDescription =>
      'Supprime toutes les entrées enregistrées sous Lieux traversés.';

  @override
  String get clearRouteHistoryButton => 'Effacer l\'historique';

  @override
  String get clearRouteHistoryConfirmTitle => 'Effacer tout l\'historique ?';

  @override
  String get clearRouteHistoryConfirmBody =>
      'Toutes les villes enregistrées seront supprimées de cet appareil. Action irréversible.';

  @override
  String get languageSettings => 'Paramètres de langue';

  @override
  String currentLanguage(Object languageName) {
    return 'Langue système actuelle : $languageName';
  }

  @override
  String get appleIntelligenceSiriLanguageNotice =>
      'Pour une meilleure narration IA locale sur iOS, faites correspondre cette langue dans Réglages > Apple Intelligence et Siri > Langue.';

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
  String get details => 'Magazine';

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
