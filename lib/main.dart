import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'features/audio/tts_audio_guide_service.dart';
import 'features/guide/contextual_guide_service.dart';
import 'features/guide/dynamic_guide_text_service.dart';
import 'features/location/region_location_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/guide_content.dart';
import 'models/region_snapshot.dart';
import 'models/tts_voice.dart';

void main() {
  runApp(const DrivingGuideApp());
}

class DrivingGuideApp extends StatelessWidget {
  const DrivingGuideApp({super.key});

  static const Color twinglMint = Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6D5DF6);
    const deepPurple = Color(0xFF3B2A8F);
    const mint = Color(0xFF55D6BE);
    const orange = Color(0xFFFF9F43);
    const background = Color(0xFFF8F6FF);
    const darkBackground = Color(0xFF111827);
    const darkSurface = Color(0xFF1F2937);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          secondary: mint,
          tertiary: orange,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: deepPurple,
          onTertiary: deepPurple,
        ),
        scaffoldBackgroundColor: background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: deepPurple,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: purple.withValues(alpha: 0.10)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: deepPurple,
            side: BorderSide(color: purple.withValues(alpha: 0.32)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: mint.withValues(alpha: 0.18),
          selectedColor: purple.withValues(alpha: 0.16),
          side: BorderSide(color: mint.withValues(alpha: 0.35)),
          labelStyle: const TextStyle(color: deepPurple),
          iconTheme: const IconThemeData(color: purple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: purple, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: purple.withValues(alpha: 0.18)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
          primary: mint,
          secondary: purple,
          tertiary: orange,
          surface: darkSurface,
          onPrimary: darkBackground,
          onSecondary: Colors.white,
          onTertiary: darkBackground,
        ),
        scaffoldBackgroundColor: darkBackground,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: mint.withValues(alpha: 0.18)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: mint,
            foregroundColor: darkBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: mint,
            side: BorderSide(color: mint.withValues(alpha: 0.42)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: mint.withValues(alpha: 0.16),
          selectedColor: purple.withValues(alpha: 0.28),
          side: BorderSide(color: mint.withValues(alpha: 0.32)),
          labelStyle: const TextStyle(color: Colors.white),
          iconTheme: const IconThemeData(color: mint),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: mint, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: mint.withValues(alpha: 0.20)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkSurface,
          indicatorColor: purple.withValues(alpha: 0.32),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? mint
                  : Colors.white70,
            );
          }),
        ),
      ),
      home: const DrivingGuideHomePage(),
    );
  }
}

class DrivingGuideHomePage extends StatefulWidget {
  const DrivingGuideHomePage({super.key});

  @override
  State<DrivingGuideHomePage> createState() => _DrivingGuideHomePageState();
}

class _DrivingGuideHomePageState extends State<DrivingGuideHomePage> {
  static const _narrativeStylePreferenceKey = 'narrative_style';
  static const _voicePreferenceKey = 'tts_voice_id';
  static const _systemVoicePreferenceValue = 'system-default';

  static const _sacramentoToSeattleRoute = [
    'Sacramento, California',
    'Woodland, California',
    'Redding, California',
    'Mount Shasta, California',
    'Ashland, Oregon',
    'Medford, Oregon',
    'Roseburg, Oregon',
    'Eugene, Oregon',
    'Salem, Oregon',
    'Portland, Oregon',
    'Vancouver, Washington',
    'Olympia, Washington',
    'Tacoma, Washington',
    'Seattle, Washington',
  ];

  final _locationService = RegionLocationService();
  final _contextualGuideService = ContextualGuideService();
  final _dynamicTextService = const DynamicGuideTextService();
  final _ttsService = TtsAudioGuideService();

  StreamSubscription<RegionSnapshot>? _regionSubscription;
  StreamSubscription<SpeakingRange?>? _speakingRangeSubscription;
  RegionSnapshot? _currentRegion;
  List<TtsVoice> _voices = const [];
  TtsVoice? _selectedVoice;
  String _voiceStatus = '';
  String _firstLlmInput = '';
  String _secondLlmResult = '';
  String _preparedTtsText = '';
  SpeakingRange? _currentSpeakingRange;
  String _narrativeStyle = 'Cinematic storyteller';
  String? _loadedVoiceLocalePrefix;
  List<GuideLink> _guideLinks = const [];
  String? _currentTestStop;
  bool _isMonitoring = false;
  bool _isTestRouteRunning = false;
  bool _isTestRouteSpeaking = false;
  bool _isPlaybackPaused = false;
  bool _isPlaybackCompleted = false;
  bool _isAiThinking = false;
  bool _showTestRouteControls = false;
  bool _showFirstLlmDebug = false;
  int _selectedTabIndex = 0;
  int _liveGuideTapCount = 0;
  int _moreTapCount = 0;
  int _testRouteIndex = 0;
  int _testRouteRunId = 0;
  int _playbackRunId = 0;
  int _resumeSpeakingIndex = 0;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  String _llmOutputLanguage() {
    final languageCode = Localizations.localeOf(context).languageCode;
    return switch (languageCode) {
      'ko' => 'Korean',
      'ja' => 'Japanese',
      'zh' => 'Chinese',
      'es' => 'Spanish',
      'de' => 'German',
      'fr' => 'French',
      _ => 'English',
    };
  }

  @override
  void initState() {
    super.initState();
    _regionSubscription = _locationService.regionChanges.listen(
      (region) => unawaited(_handleRegionChange(region)),
      onError: (Object error) => debugPrint('Location error: $error'),
    );
    _speakingRangeSubscription = _ttsService.speakingRanges.listen((range) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentSpeakingRange = range;
        if (range != null) {
          _resumeSpeakingIndex = range.start;
        }
      });
    });
    unawaited(_loadSavedSettings());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localePrefix = _voiceLocalePrefix();
    if (_loadedVoiceLocalePrefix == localePrefix) {
      return;
    }
    _loadedVoiceLocalePrefix = localePrefix;
    unawaited(_loadVoices(localePrefix: localePrefix));
  }

  String _voiceLocalePrefix() {
    final languageCode = Localizations.localeOf(context).languageCode;
    return switch (languageCode) {
      'ko' => 'ko-',
      'ja' => 'ja-',
      'zh' => 'zh-',
      'es' => 'es-',
      'de' => 'de-',
      'fr' => 'fr-',
      _ => 'en-',
    };
  }

  String _ttsLanguage() {
    final languageCode = Localizations.localeOf(context).languageCode;
    return switch (languageCode) {
      'ko' => 'ko-KR',
      'ja' => 'ja-JP',
      'zh' => 'zh-CN',
      'es' => 'es-ES',
      'de' => 'de-DE',
      'fr' => 'fr-FR',
      _ => 'en-US',
    };
  }

  String _voicePreferenceKeyForLocale(String localePrefix) {
    return '${_voicePreferenceKey}_$localePrefix';
  }

  Future<void> _loadSavedSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final savedNarrativeStyle = preferences.getString(
      _narrativeStylePreferenceKey,
    );
    if (!mounted || savedNarrativeStyle == null) {
      return;
    }

    const supportedStyles = {
      'Cinematic storyteller',
      'Local historian',
      'Friendly road companion',
    };
    if (!supportedStyles.contains(savedNarrativeStyle)) {
      return;
    }

    setState(() {
      _narrativeStyle = savedNarrativeStyle;
    });
  }

  Future<void> _loadVoices({required String localePrefix}) async {
    try {
      final ttsLanguage = _ttsLanguage();
      await _ttsService.setDefaultLanguage(ttsLanguage);
      final preferences = await SharedPreferences.getInstance();
      final savedVoiceId = preferences.getString(
        _voicePreferenceKeyForLocale(localePrefix),
      );
      final voices = await _ttsService.availableVoices(
        localePrefix: localePrefix,
      );
      final savedVoice = savedVoiceId == null ||
              savedVoiceId == _systemVoicePreferenceValue
          ? null
          : voices.where((voice) => voice.id == savedVoiceId).firstOrNull;
      final selectedVoice = savedVoiceId == _systemVoicePreferenceValue
          ? null
          : savedVoice ?? (voices.isEmpty ? null : voices.first);
      if (!mounted) {
        return;
      }
      setState(() {
        _voices = voices;
        _selectedVoice = selectedVoice;
        _voiceStatus = voices.isEmpty || selectedVoice == null
            ? _l10n.systemDefaultEnglishVoice
            : _l10n.voiceAvailabilityStatus(
                voices.length,
                selectedVoice.qualityLabel,
              );
      });
      await _ttsService.selectVoice(selectedVoice);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _voiceStatus = _l10n.voiceLoadError('$error');
      });
    }
  }

  Future<void> _saveNarrativeStyle(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_narrativeStylePreferenceKey, value);
  }

  Future<void> _saveSelectedVoice(TtsVoice? voice) async {
    final localePrefix = _voiceLocalePrefix();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _voicePreferenceKeyForLocale(localePrefix),
      voice?.id ?? _systemVoicePreferenceValue,
    );
  }

  Future<void> _startMonitoring() async {
    if (_isMonitoring) {
      return;
    }

    try {
      await _stopTestRoute();
      await _ttsService.configure();
      setState(() {
        _isMonitoring = true;
        _isAiThinking = true;
        _preparedTtsText = '';
        _currentSpeakingRange = null;
        _isPlaybackPaused = false;
        _isPlaybackCompleted = false;
        _resumeSpeakingIndex = 0;
      });
      await _locationService.start();
    } catch (error) {
      if (mounted) {
        setState(() {
          _isMonitoring = false;
          _isAiThinking = false;
        });
      }
      debugPrint('Could not start monitoring: $error');
    }
  }

  Future<void> _confirmStartGuiding(BuildContext context) async {
    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.startGuidingDialogTitle),
          content: Text(l10n.startGuidingDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (shouldStart == true) {
      await _startMonitoring();
    }
  }

  Future<void> _stopMonitoring() async {
    _playbackRunId++;
    await _locationService.stop();
    await _ttsService.stop();
    setState(() {
      _isMonitoring = false;
      _isAiThinking = false;
      _preparedTtsText = '';
      _currentSpeakingRange = null;
      _isPlaybackPaused = false;
      _isPlaybackCompleted = false;
      _resumeSpeakingIndex = 0;
    });
  }

  Future<void> _checkThisTown() async {
    if (_isTestRouteRunning) {
      return;
    }

    _playbackRunId++;
    await _ttsService.stop();
    try {
      await _ttsService.configure();
      setState(() {
        _firstLlmInput = '';
        _secondLlmResult = '';
        _preparedTtsText = '';
        _currentSpeakingRange = null;
        _guideLinks = const [];
        _isAiThinking = true;
        _isPlaybackPaused = false;
        _isPlaybackCompleted = false;
        _resumeSpeakingIndex = 0;
      });
      final region = await _locationService.currentRegionSnapshot();
      await _handleRegionChange(region);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isAiThinking = false;
      });
      debugPrint('Could not check this town: $error');
    }
  }

  Future<void> _startTestRoute() async {
    if (_isTestRouteRunning) {
      return;
    }

    if (_isMonitoring) {
      await _locationService.stop();
    }

    setState(() {
      _isMonitoring = false;
      _isTestRouteRunning = true;
      _testRouteIndex = 0;
      _currentRegion = null;
      _currentTestStop = null;
      _firstLlmInput = '';
      _secondLlmResult = '';
      _preparedTtsText = '';
      _currentSpeakingRange = null;
      _guideLinks = const [];
      _isAiThinking = false;
      _isPlaybackPaused = false;
      _isPlaybackCompleted = false;
    });

    await _runNextTestRouteStop();
  }

  Future<void> _stopTestRoute() async {
    if (!mounted) {
      return;
    }
    _testRouteRunId++;
    _playbackRunId++;
    await _ttsService.stop();
    setState(() {
      _isTestRouteRunning = false;
      _isTestRouteSpeaking = false;
      _isAiThinking = false;
      _isPlaybackPaused = false;
      _isPlaybackCompleted = false;
    });
  }

  Future<void> _runNextTestRouteStop() async {
    if (!_isTestRouteRunning ||
        _testRouteIndex >= _sacramentoToSeattleRoute.length) {
      return;
    }

    await _runTestRouteStopAt(_testRouteIndex);
  }

  Future<void> _runPreviousTestRouteStop() async {
    if (!_isTestRouteRunning || _testRouteIndex <= 1) {
      return;
    }

    final currentIndex = (_testRouteIndex - 1).clamp(
      0,
      _sacramentoToSeattleRoute.length - 1,
    );
    final previousIndex = (currentIndex - 1).clamp(
      0,
      _sacramentoToSeattleRoute.length - 1,
    );
    await _runTestRouteStopAt(previousIndex);
  }

  Future<void> _runTestRouteStopAt(int index) async {
    if (!_isTestRouteRunning ||
        index < 0 ||
        index >= _sacramentoToSeattleRoute.length) {
      return;
    }

    final runId = ++_testRouteRunId;
    _playbackRunId++;
    await _ttsService.stop();
    final stop = _sacramentoToSeattleRoute[index];
    _testRouteIndex = index + 1;

    setState(() {
      _currentTestStop = stop;
      _firstLlmInput = '';
      _secondLlmResult = '';
      _preparedTtsText = '';
      _currentSpeakingRange = null;
      _guideLinks = const [];
      _isAiThinking = false;
      _isPlaybackPaused = false;
      _isPlaybackCompleted = false;
      _isTestRouteSpeaking = true;
    });

    try {
      final guide = await _contextualGuideService.buildGuideForRegionName(
        regionName: stop,
        speedMph: 35,
        narrativeStyle: _narrativeStyle,
        outputLanguage: _llmOutputLanguage(),
        onPipelineEvent: _handlePipelineEvent,
      );
      if (!mounted || runId != _testRouteRunId) {
        return;
      }
      final text = _dynamicTextService.selectText(guide: guide, speedMph: 35);
      _setGuideOutput(text: text, links: guide.links);
      final playbackRunId = _beginPlayback();
      await _ttsService.speak(text);
      _completePlayback(playbackRunId);
    } finally {
      if (mounted && runId == _testRouteRunId) {
        setState(() {
          _isTestRouteSpeaking = false;
        });
      }
    }
  }

  Future<void> _handleRegionChange(RegionSnapshot region) async {
    setState(() {
      _currentRegion = region;
      _firstLlmInput = '';
      _secondLlmResult = '';
      _preparedTtsText = '';
      _currentSpeakingRange = null;
      _guideLinks = const [];
      _isAiThinking = false;
    });

    final guide = await _contextualGuideService.buildGuide(
      region,
      narrativeStyle: _narrativeStyle,
      outputLanguage: _llmOutputLanguage(),
      onPipelineEvent: _handlePipelineEvent,
    );
    final text = _dynamicTextService.selectText(
      guide: guide,
      speedMph: region.speedMph,
    );
    _setGuideOutput(text: text, links: guide.links);

    final playbackRunId = _beginPlayback();
    await _ttsService.speak(text);
    _completePlayback(playbackRunId);
  }

  Future<void> _selectVoice(TtsVoice? voice) async {
    setState(() {
      _selectedVoice = voice;
      _voiceStatus = voice == null
          ? _l10n.systemDefaultEnglishVoice
          : _l10n.usingVoice(voice.displayName);
    });
    await _saveSelectedVoice(voice);
    await _ttsService.selectVoice(voice);
  }

  void _setGuideOutput({
    required String text,
    required List<GuideLink> links,
  }) {
    setState(() {
      _preparedTtsText = text;
      _currentSpeakingRange = null;
      _guideLinks = links;
      _isPlaybackPaused = false;
      _isPlaybackCompleted = false;
      _resumeSpeakingIndex = 0;
      _isAiThinking = false;
    });

  }

  int _beginPlayback() {
    final playbackRunId = ++_playbackRunId;
    setState(() {
      _isPlaybackPaused = false;
      _isPlaybackCompleted = false;
    });
    return playbackRunId;
  }

  void _completePlayback(int playbackRunId) {
    if (!mounted || playbackRunId != _playbackRunId || _isPlaybackPaused) {
      return;
    }
    setState(() {
      _isPlaybackCompleted = true;
      _isPlaybackPaused = false;
      _currentSpeakingRange = null;
      _resumeSpeakingIndex = 0;
    });
  }

  Future<void> _replayNarrative() async {
    if (_preparedTtsText.trim().isEmpty) {
      return;
    }
    final playbackRunId = _beginPlayback();
    _resumeSpeakingIndex = 0;
    await _ttsService.speak(_preparedTtsText);
    _completePlayback(playbackRunId);
  }

  Future<void> _togglePlayback() async {
    if (_isPlaybackPaused) {
      final resumeIndex = _resumeSpeakingIndex;
      final playbackRunId = _beginPlayback();
      await _ttsService.speakFrom(_preparedTtsText, resumeIndex);
      _completePlayback(playbackRunId);
      return;
    }

    if (_isPlaybackCompleted) {
      await _replayNarrative();
      return;
    }

    final currentRange = _currentSpeakingRange;
    if (currentRange != null) {
      _resumeSpeakingIndex = currentRange.start;
    }
    _playbackRunId++;
    await _ttsService.stop();
    setState(() {
      _isPlaybackPaused = true;
      _isPlaybackCompleted = false;
    });
  }

  void _handlePipelineEvent(GuidePipelineEvent event) {
    if (event.payload == null || !mounted) {
      return;
    }

    if (event.message == 'First LLM city intro prompt is ready.') {
      setState(() {
        _firstLlmInput = event.payload!;
        _isAiThinking = true;
      });
    } else if (event.message == 'Proper noun extraction received.') {
      setState(() {
        _secondLlmResult = event.payload!;
        _isAiThinking = false;
      });
    }
  }

  Future<void> _openGuideLink(GuideLink link) async {
    if (Platform.isIOS && link.kind == GuideLinkKind.map) {
      final appleMapsQuery = Uri.encodeQueryComponent(link.label);
      final appleMapsUri = Uri.parse(
        'https://maps.apple.com/?q=$appleMapsQuery',
      );
      if (await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    }

    final uri = Uri.parse(link.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open link: ${link.url}');
    }
  }

  Future<void> _openSearchOrMap({
    required String label,
    required bool map,
  }) async {
    final areaName = _currentAreaName();
    final query = map ? '$label $areaName' : '$label $areaName';
    final encodedQuery = Uri.encodeQueryComponent(query);
    final url = map
        ? 'https://www.google.com/maps/search/?api=1&query=$encodedQuery'
        : 'https://www.google.com/search?q=$encodedQuery';
    await _openGuideLink(
      GuideLink(
        label: label,
        url: url,
        kind: map ? GuideLinkKind.map : GuideLinkKind.search,
      ),
    );
  }

  Future<void> _showExpandedNarrative(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = _l10n;
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.fullNarrative,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<SpeakingRange?>(
                      stream: _ttsService.speakingRanges,
                      initialData: _currentSpeakingRange,
                      builder: (context, snapshot) {
                        return SingleChildScrollView(
                          child: _SynchronizedNarrativeText(
                            text: _preparedTtsText,
                            speakingRange: snapshot.data,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.55,
                              fontSize: 18,
                            ),
                            fallbackColor: colorScheme.onSurface,
                            expanded: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _currentAreaName() {
    final testStop = _currentTestStop;
    if (testStop != null) {
      return testStop.split(',').first.trim();
    }

    final region = _currentRegion;
    if (region == null) {
      return _l10n.noLocationYet;
    }

    final name = region.city ?? region.town ?? region.displayName.split(',').first;
    return name.trim().isEmpty ? _l10n.currentArea : name.trim();
  }

  bool _hasCurrentArea() {
    return _currentTestStop != null || _currentRegion != null;
  }

  Widget _buildLiveGuideTab(BuildContext context) {
    final areaName = _currentAreaName();
    final l10n = _l10n;
    final hasNarrative = _preparedTtsText.trim().isNotEmpty;
    final backgroundUrl =
        'https://source.unsplash.com/1200x900/?${Uri.encodeComponent('$areaName city landscape road')}';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroGuideCard(
          areaName: areaName,
          imageUrl: backgroundUrl,
          narrative: hasNarrative
              ? _preparedTtsText
              : l10n.startAreaMonitoringPlaceholder,
          speakingRange: _currentSpeakingRange,
          isThinking: _isAiThinking,
          isSpeaking:
              _isTestRouteSpeaking || _currentSpeakingRange != null,
          isMonitoring: _isMonitoring || _isTestRouteRunning,
          isPaused: _isPlaybackPaused,
          isCompleted: _isPlaybackCompleted,
          onTogglePlayback: hasNarrative ? _togglePlayback : null,
          onReplay: hasNarrative ? _replayNarrative : null,
          onExpand: hasNarrative
              ? () => _showExpandedNarrative(context)
              : null,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isMonitoring || _isTestRouteRunning
              ? null
              : () => _confirmStartGuiding(context),
          icon: const Icon(Icons.navigation),
          label: Text(l10n.startGuiding),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isMonitoring ? _stopMonitoring : null,
          icon: const Icon(Icons.stop),
          label: Text(l10n.pauseGuide),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: _isTestRouteRunning || _isAiThinking ? null : _checkThisTown,
          icon: const Icon(Icons.my_location),
          label: Text(l10n.checkThisTown),
        ),
        if (_showTestRouteControls) ...[
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: _isTestRouteRunning ? null : _startTestRoute,
            icon: const Icon(Icons.route),
            label: Text(l10n.startTestRoute),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isTestRouteRunning ? _stopTestRoute : null,
            icon: const Icon(Icons.pause_circle),
            label: Text(l10n.stopTestRoute),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTestRouteRunning && _testRouteIndex > 1
                      ? _runPreviousTestRouteStop
                      : null,
                  icon: const Icon(Icons.skip_previous),
                  label: Text(l10n.prevStop),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTestRouteRunning &&
                          _testRouteIndex < _sacramentoToSeattleRoute.length
                      ? _runNextTestRouteStop
                      : null,
                  icon: const Icon(Icons.skip_next),
                  label: Text(l10n.nextStop),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    final areaName = _currentAreaName();
    final l10n = _l10n;
    final cards = [
      _DetailCardData(
        title: l10n.heritage,
        icon: Icons.account_balance,
        body: l10n.heritageBody(areaName),
        query: '$areaName history name origin',
        opensMap: false,
      ),
      _DetailCardData(
        title: l10n.icons,
        icon: Icons.stars,
        body: l10n.iconsBody,
        query: '$areaName famous people',
        opensMap: false,
      ),
      _DetailCardData(
        title: l10n.views,
        icon: Icons.landscape,
        body: l10n.viewsBody,
        query: '$areaName scenic viewpoint',
        opensMap: true,
      ),
      _DetailCardData(
        title: l10n.bites,
        icon: Icons.restaurant,
        body: l10n.bitesBody,
        query: '$areaName best local food signature menu',
        opensMap: true,
      ),
      _DetailCardData(
        title: l10n.goods,
        icon: Icons.local_florist,
        body: l10n.goodsBody,
        query: '$areaName local products wine beer seafood agriculture',
        opensMap: false,
      ),
      _DetailCardData(
        title: l10n.trivia,
        icon: Icons.movie,
        body: l10n.triviaBody,
        query: '$areaName trivia film location festival event',
        opensMap: false,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.digitalMagazine, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.detailsIntro(areaName),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return _DetailCategoryCard(
              data: card,
              onTap: () => _openSearchOrMap(
                label: card.query,
                map: card.opensMap,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _StatusCard(
          title: l10n.relatedLinks,
          child: _GuideLinks(links: _guideLinks, onOpen: _openGuideLink),
        ),
      ],
    );
  }

  Widget _buildMoreTab(BuildContext context) {
    final l10n = _l10n;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StatusCard(
          title: l10n.personaSettings,
          child: DropdownButtonFormField<String>(
            initialValue: _narrativeStyle,
            decoration: InputDecoration(labelText: l10n.narrativeStyle),
            items: [
              DropdownMenuItem(
                value: 'Cinematic storyteller',
                child: Text(l10n.cinematicStoryteller),
              ),
              DropdownMenuItem(
                value: 'Local historian',
                child: Text(l10n.localHistorian),
              ),
              DropdownMenuItem(
                value: 'Friendly road companion',
                child: Text(l10n.friendlyRoadCompanion),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _narrativeStyle = value);
              unawaited(_saveNarrativeStyle(value));
            },
          ),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          title: l10n.voiceSettings,
          child: _VoiceSelector(
            voices: _voices,
            selectedVoice: _selectedVoice,
            status: _voiceStatus,
            onChanged: _selectVoice,
          ),
        ),
        if (_showFirstLlmDebug) ...[
          const SizedBox(height: 12),
          _StatusCard(
            title: l10n.firstLlmPrompt,
            child: SelectableText(
              _firstLlmInput.trim().isEmpty
                  ? l10n.noFirstLlmPrompt
                  : _firstLlmInput,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _regionSubscription?.cancel();
    _speakingRangeSubscription?.cancel();
    unawaited(_locationService.dispose());
    unawaited(_contextualGuideService.dispose());
    unawaited(_ttsService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canOpenDetails = _hasCurrentArea();
    final disabledColor = Theme.of(context).disabledColor;
    final l10n = _l10n;

    return Scaffold(
      appBar: AppBar(
        title: _AppTitle(
          currentAreaName: _currentAreaName(),
          hasCurrentArea: canOpenDetails,
          onAreaTap: () => _openSearchOrMap(
            label: _currentAreaName(),
            map: true,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildLiveGuideTab(context),
          _buildDetailsTab(context),
          _buildMoreTab(context),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          if (index == 1 && !canOpenDetails) {
            _liveGuideTapCount = 0;
            _moreTapCount = 0;
            return;
          }

          if (index == 0) {
            _liveGuideTapCount++;
            _moreTapCount = 0;
            if (_liveGuideTapCount >= 10) {
              _liveGuideTapCount = 0;
              setState(() {
                _showTestRouteControls = !_showTestRouteControls;
                _selectedTabIndex = index;
              });
              return;
            }
          } else if (index == 2) {
            _moreTapCount++;
            _liveGuideTapCount = 0;
            if (_moreTapCount >= 10) {
              _moreTapCount = 0;
              setState(() {
                _showFirstLlmDebug = !_showFirstLlmDebug;
                _selectedTabIndex = index;
              });
              return;
            }
          } else {
            _liveGuideTapCount = 0;
            _moreTapCount = 0;
          }
          setState(() => _selectedTabIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.graphic_eq),
            label: l10n.liveGuide,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.auto_stories_outlined,
              color: canOpenDetails ? null : disabledColor,
            ),
            label: l10n.details,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _HeroGuideCard extends StatelessWidget {
  const _HeroGuideCard({
    required this.areaName,
    required this.imageUrl,
    required this.narrative,
    required this.speakingRange,
    required this.isThinking,
    required this.isSpeaking,
    required this.isMonitoring,
    required this.isPaused,
    required this.isCompleted,
    required this.onTogglePlayback,
    required this.onReplay,
    required this.onExpand,
  });

  final String areaName;
  final String imageUrl;
  final String narrative;
  final SpeakingRange? speakingRange;
  final bool isThinking;
  final bool isSpeaking;
  final bool isMonitoring;
  final bool isPaused;
  final bool isCompleted;
  final VoidCallback? onTogglePlayback;
  final VoidCallback? onReplay;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return _GlowingGuideFrame(
      active: isMonitoring || isSpeaking,
      borderRadius: 32,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                      colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.68),
                    Colors.black.withValues(alpha: 0.34),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCompleted) ...[
                  Text(
                    l10n.cruisingTowardsNextDiscovery,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.liveNarrative,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onExpand,
                      color: Colors.white,
                      tooltip: l10n.expandNarrative,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isThinking)
                  const _ThinkingNarrativeText()
                else
                  _NarrativeWindow(
                    text: narrative,
                    speakingRange: speakingRange,
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                    fallbackColor: Colors.white,
                  ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: isCompleted
                            ? OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.pause),
                                label: Text(l10n.pause),
                                style: OutlinedButton.styleFrom(
                                  disabledForegroundColor: Colors.white54,
                                  side: const BorderSide(color: Colors.white38),
                                ),
                              )
                            : FilledButton.icon(
                                onPressed: onTogglePlayback,
                                icon: Icon(
                                  isPaused ? Icons.play_arrow : Icons.pause,
                                ),
                                label: Text(isPaused ? l10n.resume : l10n.pause),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: isCompleted
                            ? FilledButton.icon(
                                onPressed: onReplay,
                                icon: const Icon(Icons.replay),
                                label: Text(l10n.replay),
                              )
                            : OutlinedButton.icon(
                                onPressed: onReplay,
                                icon: const Icon(Icons.replay),
                                label: Text(l10n.replay),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _GlowingGuideFrame extends StatefulWidget {
  const _GlowingGuideFrame({
    required this.active,
    required this.borderRadius,
    required this.child,
  });

  final bool active;
  final double borderRadius;
  final Widget child;

  @override
  State<_GlowingGuideFrame> createState() => _GlowingGuideFrameState();
}

class _GlowingGuideFrameState extends State<_GlowingGuideFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _GlowingGuideFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) {
      return;
    }
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const softOrange = Color(0xFFFFB86B);
    const softPink = Color(0xFFFF8CC6);
    const softMint = Color(0xFF7FE7D4);
    return AnimatedBuilder(
      animation: _pulse,
      child: widget.child,
      builder: (context, child) {
        final phase = _pulse.value;
        final glowColor = phase < 1 / 3
            ? Color.lerp(softPink, softMint, phase * 3)!
            : phase < 2 / 3
            ? Color.lerp(softMint, softOrange, (phase - 1 / 3) * 3)!
            : Color.lerp(softOrange, softMint, (phase - 2 / 3) * 3)!;
        final secondaryGlowColor = phase < 1 / 3
            ? softOrange
            : phase < 2 / 3
            ? softPink
            : softMint;
        final intensity = widget.active ? 0.42 + (_pulse.value * 0.34) : 0.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.active
                  ? glowColor.withValues(alpha: 0.78)
                  : Colors.transparent,
              width: widget.active ? 1.8 + (_pulse.value * 1.4) : 0,
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: intensity),
                      blurRadius: 8,
                      spreadRadius: 0.8 + (_pulse.value * 4.2),
                    ),
                    BoxShadow(
                      color: secondaryGlowColor.withValues(alpha: intensity * 0.34),
                      blurRadius: 8,
                      spreadRadius: 0.4 + (_pulse.value * 2.2),
                    ),
                  ]
                : const [],
          ),
          child: child,
        );
      },
    );
  }
}

class _ThinkingNarrativeText extends StatefulWidget {
  const _ThinkingNarrativeText();

  @override
  State<_ThinkingNarrativeText> createState() => _ThinkingNarrativeTextState();
}

class _ThinkingNarrativeTextState extends State<_ThinkingNarrativeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 86,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final dotCount = (_controller.value * 3).floor() + 1;
          final dots = '.' * dotCount.clamp(1, 3);
          return Row(
            children: [
              Text(
                '${l10n.thinking}$dots',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NarrativeWindow extends StatefulWidget {
  const _NarrativeWindow({
    required this.text,
    required this.speakingRange,
    required this.textStyle,
    required this.fallbackColor,
  });

  final String text;
  final SpeakingRange? speakingRange;
  final TextStyle? textStyle;
  final Color fallbackColor;

  @override
  State<_NarrativeWindow> createState() => _NarrativeWindowState();
}

class _NarrativeWindowState extends State<_NarrativeWindow> {
  final _scrollController = ScrollController();
  double? _lastCenteredLineTop;

  @override
  void didUpdateWidget(covariant _NarrativeWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _lastCenteredLineTop = null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerCurrentLine({
    required SpeakingRange range,
    required TextStyle style,
    required double maxWidth,
    required double viewportHeight,
  }) {
    if (widget.text.isEmpty || maxWidth <= 0) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || !mounted) {
        return;
      }

      final safeStart = range.start.clamp(0, widget.text.length).toInt();
      final safeEnd = range.end.clamp(safeStart, widget.text.length).toInt();
      final textPainter = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(baseOffset: safeStart, extentOffset: safeEnd),
      );
      if (boxes.isEmpty) {
        return;
      }

      final lineBox = boxes.first;
      if (_lastCenteredLineTop != null &&
          (lineBox.top - _lastCenteredLineTop!).abs() < 1) {
        return;
      }
      _lastCenteredLineTop = lineBox.top;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final lineHeight = lineBox.bottom - lineBox.top;
      final target = (lineBox.top - ((viewportHeight - lineHeight) / 2))
          .clamp(0.0, maxScroll);
      _scrollController.jumpTo(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.textStyle ?? DefaultTextStyle.of(context).style;
    final height = (style.fontSize ?? 20) * (style.height ?? 1.35) * 3.2;
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final range = widget.speakingRange;
          if (range != null &&
              range.start >= 0 &&
              range.start < widget.text.length) {
            _centerCurrentLine(
              range: range,
              style: style,
              maxWidth: constraints.maxWidth,
              viewportHeight: height,
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                physics: const NeverScrollableScrollPhysics(),
                child: _SynchronizedNarrativeText(
                  text: widget.text,
                  speakingRange: widget.speakingRange,
                  style: style,
                  fallbackColor: widget.fallbackColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SynchronizedNarrativeText extends StatelessWidget {
  const _SynchronizedNarrativeText({
    required this.text,
    required this.speakingRange,
    this.style,
    this.fallbackColor,
    this.expanded = false,
  });

  final String text;
  final SpeakingRange? speakingRange;
  final TextStyle? style;
  final Color? fallbackColor;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyLarge;
    final defaultColor = fallbackColor ?? effectiveStyle?.color;
    final range = speakingRange;
    if (range == null ||
        range.start < 0 ||
        range.end <= range.start ||
        range.start >= text.length) {
      return Text(text, style: effectiveStyle);
    }

    final safeEnd = range.end.clamp(range.start, text.length).toInt();
    return RichText(
      text: TextSpan(
        style: effectiveStyle?.copyWith(color: defaultColor),
        children: [
          TextSpan(text: text.substring(0, range.start)),
          TextSpan(
            text: text.substring(range.start, safeEnd),
            style: effectiveStyle?.copyWith(
              color: defaultColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.substring(safeEnd)),
        ],
      ),
    );
  }
}

class _DetailCardData {
  const _DetailCardData({
    required this.title,
    required this.icon,
    required this.body,
    required this.query,
    required this.opensMap,
  });

  final String title;
  final IconData icon;
  final String body;
  final String query;
  final bool opensMap;
}

class _DetailCategoryCard extends StatelessWidget {
  const _DetailCategoryCard({
    required this.data,
    required this.onTap,
  });

  final _DetailCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.secondary.withValues(alpha: 0.18),
                foregroundColor: colorScheme.primary,
                child: Icon(data.icon),
              ),
              const Spacer(),
              Text(
                data.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle({
    required this.currentAreaName,
    required this.hasCurrentArea,
    required this.onAreaTap,
  });

  final String currentAreaName;
  final bool hasCurrentArea;
  final VoidCallback onAreaTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Twingl',
          style: TextStyle(
            fontFamily: 'Arial Rounded MT Bold',
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: DrivingGuideApp.twinglMint,
          ),
        ),
        const Text(
          ' Road',
          style: TextStyle(
            fontFamily: 'Arial Rounded MT Bold',
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: DrivingGuideApp.twinglMint,
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(999),
              onTap: hasCurrentArea ? onAreaTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    currentAreaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideLinks extends StatelessWidget {
  const _GuideLinks({
    required this.links,
    required this.onOpen,
  });

  final List<GuideLink> links;
  final ValueChanged<GuideLink> onOpen;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return Text(AppLocalizations.of(context).noRelatedLinks);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final link in links)
          ActionChip(
            avatar: Icon(
              link.kind == GuideLinkKind.map
                  ? Icons.map_outlined
                  : Icons.search,
              size: 18,
            ),
            label: Text(link.label),
            onPressed: () => onOpen(link),
          ),
      ],
    );
  }
}

class _VoiceSelector extends StatelessWidget {
  const _VoiceSelector({
    required this.voices,
    required this.selectedVoice,
    required this.status,
    required this.onChanged,
  });

  final List<TtsVoice> voices;
  final TtsVoice? selectedVoice;
  final String status;
  final ValueChanged<TtsVoice?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedVoice?.id,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.voice,
          ),
          items: [
            DropdownMenuItem(
              value: 'system-default',
              child: Text(l10n.systemDefault),
            ),
            for (final voice in voices)
              DropdownMenuItem(value: voice.id, child: Text(voice.displayName)),
          ],
          onChanged: (value) {
            if (value == 'system-default') {
              onChanged(null);
              return;
            }
            onChanged(voices.where((voice) => voice.id == value).firstOrNull);
          },
        ),
        const SizedBox(height: 8),
        Text(
          status.isEmpty ? l10n.loadingVoices : status,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.moreVoice,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.moreVoiceDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
