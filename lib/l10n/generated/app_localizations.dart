import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Twingl Road'**
  String get appTitle;

  /// No description provided for @introductionTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introductionTitle;

  /// No description provided for @introductionButton.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introductionButton;

  /// No description provided for @introductionSummary.
  ///
  /// In en, this message translates to:
  /// **'Learn what Twingl Road does and how to use it on the road.'**
  String get introductionSummary;

  /// No description provided for @introductionBody.
  ///
  /// In en, this message translates to:
  /// **'Twingl Road is an audio-first travel guide for the road. As you pass through cities and towns, it introduces local history, landmarks, scenery, food, festivals, and notable people in a cinematic documentary style.\n\nUse Start Guiding when you want the app to automatically introduce each new town as you enter it. Use Check This Town when you want a one-time guide for your current location without continuous monitoring.\n\nThe Magazine tab gives you related links for the current area. Place links open in Maps, while people, events, and cultural references open in browser search.\n\nIn More, you can choose the narration persona, check the current system language, and select a premium or enhanced TTS voice. On iOS, matching Settings > Apple Intelligence & Siri > Language with the app language can help local AI narration work more naturally.'**
  String get introductionBody;

  /// No description provided for @loadingVoices.
  ///
  /// In en, this message translates to:
  /// **'Loading voices...'**
  String get loadingVoices;

  /// No description provided for @systemDefaultEnglishVoice.
  ///
  /// In en, this message translates to:
  /// **'Using the system default voice.'**
  String get systemDefaultEnglishVoice;

  /// No description provided for @voiceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load voices: {error}'**
  String voiceLoadError(Object error);

  /// No description provided for @voiceAvailabilityStatus.
  ///
  /// In en, this message translates to:
  /// **'{count} premium/enhanced voice(s) available. Selected: {quality}.'**
  String voiceAvailabilityStatus(int count, Object quality);

  /// No description provided for @usingVoice.
  ///
  /// In en, this message translates to:
  /// **'Using {voiceName}.'**
  String usingVoice(Object voiceName);

  /// No description provided for @startGuidingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Guiding?'**
  String get startGuidingDialogTitle;

  /// No description provided for @startGuidingDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Guiding active. I\'ll automatically introduce each new town\'s history, landmarks, and local flavors as you enter.'**
  String get startGuidingDialogMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @fullNarrative.
  ///
  /// In en, this message translates to:
  /// **'Full Narrative'**
  String get fullNarrative;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String characterCount(int count);

  /// No description provided for @wordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String wordCount(int count);

  /// No description provided for @noLocationYet.
  ///
  /// In en, this message translates to:
  /// **'No location yet'**
  String get noLocationYet;

  /// No description provided for @currentArea.
  ///
  /// In en, this message translates to:
  /// **'Current area'**
  String get currentArea;

  /// No description provided for @startGuiding.
  ///
  /// In en, this message translates to:
  /// **'Start Guiding'**
  String get startGuiding;

  /// No description provided for @pauseGuide.
  ///
  /// In en, this message translates to:
  /// **'Pause Guide'**
  String get pauseGuide;

  /// No description provided for @checkThisTown.
  ///
  /// In en, this message translates to:
  /// **'Check This Town'**
  String get checkThisTown;

  /// No description provided for @startTestRoute.
  ///
  /// In en, this message translates to:
  /// **'Start Sacramento to Seattle Test Route'**
  String get startTestRoute;

  /// No description provided for @stopTestRoute.
  ///
  /// In en, this message translates to:
  /// **'Stop Test Route'**
  String get stopTestRoute;

  /// No description provided for @prevStop.
  ///
  /// In en, this message translates to:
  /// **'Prev Stop'**
  String get prevStop;

  /// No description provided for @nextStop.
  ///
  /// In en, this message translates to:
  /// **'Next Stop'**
  String get nextStop;

  /// No description provided for @heritage.
  ///
  /// In en, this message translates to:
  /// **'Heritage'**
  String get heritage;

  /// No description provided for @heritageBody.
  ///
  /// In en, this message translates to:
  /// **'Name origin and the story that shaped {areaName}.'**
  String heritageBody(Object areaName);

  /// No description provided for @icons.
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get icons;

  /// No description provided for @iconsBody.
  ///
  /// In en, this message translates to:
  /// **'Famous people and local episodes connected to this place.'**
  String get iconsBody;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @viewsBody.
  ///
  /// In en, this message translates to:
  /// **'Scenic viewpoints and beautiful short detours nearby.'**
  String get viewsBody;

  /// No description provided for @bites.
  ///
  /// In en, this message translates to:
  /// **'Bites'**
  String get bites;

  /// No description provided for @bitesBody.
  ///
  /// In en, this message translates to:
  /// **'A local food or drink stop worth remembering.'**
  String get bitesBody;

  /// No description provided for @goods.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get goods;

  /// No description provided for @goodsBody.
  ///
  /// In en, this message translates to:
  /// **'Seasonal products, wine, beer, seafood, or agriculture.'**
  String get goodsBody;

  /// No description provided for @trivia.
  ///
  /// In en, this message translates to:
  /// **'Trivia'**
  String get trivia;

  /// No description provided for @triviaBody.
  ///
  /// In en, this message translates to:
  /// **'Film locations, festivals, events, and small local surprises.'**
  String get triviaBody;

  /// No description provided for @digitalMagazine.
  ///
  /// In en, this message translates to:
  /// **'Digital Magazine'**
  String get digitalMagazine;

  /// No description provided for @detailsIntro.
  ///
  /// In en, this message translates to:
  /// **'Pull over and explore the deeper story behind {areaName}.'**
  String detailsIntro(Object areaName);

  /// No description provided for @relatedLinks.
  ///
  /// In en, this message translates to:
  /// **'Related Links'**
  String get relatedLinks;

  /// No description provided for @personaSettings.
  ///
  /// In en, this message translates to:
  /// **'Persona Settings'**
  String get personaSettings;

  /// No description provided for @narrativeStyle.
  ///
  /// In en, this message translates to:
  /// **'Narrative style'**
  String get narrativeStyle;

  /// No description provided for @cinematicStoryteller.
  ///
  /// In en, this message translates to:
  /// **'Storyteller'**
  String get cinematicStoryteller;

  /// No description provided for @localHistorian.
  ///
  /// In en, this message translates to:
  /// **'Local historian'**
  String get localHistorian;

  /// No description provided for @friendlyRoadCompanion.
  ///
  /// In en, this message translates to:
  /// **'Friendly road companion'**
  String get friendlyRoadCompanion;

  /// No description provided for @energeticTownWit.
  ///
  /// In en, this message translates to:
  /// **'Energetic Town Wit'**
  String get energeticTownWit;

  /// No description provided for @customPersonasSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your personas'**
  String get customPersonasSectionTitle;

  /// No description provided for @customPersonaHint.
  ///
  /// In en, this message translates to:
  /// **'Tone, role, attitude, and speaking style details for the narrator.'**
  String get customPersonaHint;

  /// No description provided for @customPersonaTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get customPersonaTitleLabel;

  /// No description provided for @customPersonaTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Short label shown in menus'**
  String get customPersonaTitleHint;

  /// No description provided for @customPersonaDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get customPersonaDescriptionLabel;

  /// No description provided for @addCustomPersona.
  ///
  /// In en, this message translates to:
  /// **'Add persona'**
  String get addCustomPersona;

  /// No description provided for @removeCustomPersona.
  ///
  /// In en, this message translates to:
  /// **'Remove persona'**
  String get removeCustomPersona;

  /// No description provided for @customPersonasMaxHint.
  ///
  /// In en, this message translates to:
  /// **'You can save up to 24 custom personas.'**
  String get customPersonasMaxHint;

  /// No description provided for @routeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Places you\'ve passed through'**
  String get routeHistoryTitle;

  /// No description provided for @routeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'After you hear a guided town intro for a place, it will appear here.'**
  String get routeHistoryEmpty;

  /// No description provided for @cityNarration.
  ///
  /// In en, this message translates to:
  /// **'City narration'**
  String get cityNarration;

  /// No description provided for @clearRouteHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Route history'**
  String get clearRouteHistoryTitle;

  /// No description provided for @clearRouteHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove all entries saved under Places you\'ve passed through.'**
  String get clearRouteHistoryDescription;

  /// No description provided for @clearRouteHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearRouteHistoryButton;

  /// No description provided for @clearRouteHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all route history?'**
  String get clearRouteHistoryConfirmTitle;

  /// No description provided for @clearRouteHistoryConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Every saved town will be removed from this device. This can\'t be undone.'**
  String get clearRouteHistoryConfirmBody;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current System Language: {languageName}'**
  String currentLanguage(Object languageName);

  /// No description provided for @appleIntelligenceSiriLanguageNotice.
  ///
  /// In en, this message translates to:
  /// **'For the best local AI narration on iOS, match this language in Settings > Apple Intelligence & Siri > Language.'**
  String get appleIntelligenceSiriLanguageNotice;

  /// No description provided for @voiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// No description provided for @firstLlmPrompt.
  ///
  /// In en, this message translates to:
  /// **'First LLM Prompt'**
  String get firstLlmPrompt;

  /// No description provided for @noFirstLlmPrompt.
  ///
  /// In en, this message translates to:
  /// **'No first LLM prompt generated yet.'**
  String get noFirstLlmPrompt;

  /// No description provided for @liveGuide.
  ///
  /// In en, this message translates to:
  /// **'Live Guide'**
  String get liveGuide;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Magazine'**
  String get details;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @cruisingTowardsNextDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Cruising towards the next discovery.'**
  String get cruisingTowardsNextDiscovery;

  /// No description provided for @liveNarrative.
  ///
  /// In en, this message translates to:
  /// **'Live Narrative'**
  String get liveNarrative;

  /// No description provided for @expandNarrative.
  ///
  /// In en, this message translates to:
  /// **'Expand narrative'**
  String get expandNarrative;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @noRelatedLinks.
  ///
  /// In en, this message translates to:
  /// **'No related links prepared yet.'**
  String get noRelatedLinks;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @moreVoice.
  ///
  /// In en, this message translates to:
  /// **'More voice?'**
  String get moreVoice;

  /// No description provided for @moreVoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'You can add new voices in Settings > Accessibility > Read & Speak > Voices.'**
  String get moreVoiceDescription;

  /// No description provided for @onDeviceNarrationNotice.
  ///
  /// In en, this message translates to:
  /// **'On-device AI is not active. Please check system settings. Also confirm whether this device supports on-device AI.'**
  String get onDeviceNarrationNotice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
