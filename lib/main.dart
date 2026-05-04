import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'features/audio/tts_audio_guide_service.dart';
import 'features/guide/contextual_guide_service.dart';
import 'features/guide/prompt_builder.dart';
import 'features/guide/dynamic_guide_text_service.dart';
import 'features/location/offline_city_lookup.dart';
import 'features/location/region_location_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/guide_content.dart';
import 'models/region_snapshot.dart';
import 'models/tts_voice.dart';

void main() {
  runApp(const DrivingGuideApp());
}

class _CustomPersona {
  const _CustomPersona({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  static const _maxTitleLen = 120;
  static const _maxDescriptionLen = 600;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
      };

  static final _idPattern = RegExp(r'^[a-z0-9]{8,64}$');

  static String _clamp(String s, int max) =>
      s.length > max ? s.substring(0, max) : s;

  static String _legacyTitle(String text) {
    final line = text.split(RegExp(r'\r?\n')).first.trim();
    if (line.isEmpty) return 'Persona';
    const cap = 80;
    return line.length > cap ? '${line.substring(0, cap)}…' : line;
  }

  static _CustomPersona? tryParse(Map<String, dynamic> map) {
    final id = map['id'];
    if (id is! String) return null;
    final idTrim = id.trim();
    if (!_idPattern.hasMatch(idTrim)) return null;

    final titleRaw = map['title'];
    final descRaw = map['description'];
    if (titleRaw is String && descRaw is String) {
      final ti = titleRaw.trim();
      final de = descRaw.trim();
      if (ti.isEmpty || de.isEmpty) return null;
      return _CustomPersona(
        id: idTrim,
        title: _clamp(ti, _maxTitleLen),
        description: _clamp(de, _maxDescriptionLen),
      );
    }

    final legacyText = map['text'];
    if (legacyText is! String) return null;
    final legacy = legacyText.trim();
    if (legacy.isEmpty) return null;
    final description = _clamp(legacy, _maxDescriptionLen);
    return _CustomPersona(
      id: idTrim,
      title: _clamp(_legacyTitle(description), _maxTitleLen),
      description: description,
    );
  }
}

class _GuideHistoryEntry {
  const _GuideHistoryEntry({
    required this.cityName,
    required this.firstLlmResult,
    required this.secondLlmResult,
    required this.recordedAt,
    this.links = const [],
  });

  final String cityName;
  final String firstLlmResult;
  final String secondLlmResult;
  final DateTime recordedAt;
  final List<GuideLink> links;

  String get selectionKey =>
      '${recordedAt.toUtc().toIso8601String()}|$cityName';

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'firstLlmResult': firstLlmResult,
        'secondLlmResult': secondLlmResult,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
        'links': links.map((l) => l.toJson()).toList(),
      };

  static List<GuideLink> _decodeLinks(dynamic raw) {
    if (raw is! List) return [];
    final out = <GuideLink>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        final gl = GuideLink.tryParse(item);
        if (gl != null) out.add(gl);
      } else if (item is Map) {
        final gl = GuideLink.tryParse(Map<String, dynamic>.from(item));
        if (gl != null) out.add(gl);
      }
    }
    return out;
  }

  static _GuideHistoryEntry? tryParse(Map<String, dynamic> map) {
    final city = map['cityName'];
    final first = map['firstLlmResult'];
    final at = map['recordedAt'];
    if (city is! String || first is! String || at is! String) {
      return null;
    }
    final secondStr =
        map['secondLlmResult'] is String ? map['secondLlmResult'] as String : '';
    final parsedTime = DateTime.tryParse(at);
    if (parsedTime == null) return null;
    final cn = city.trim();
    if (cn.isEmpty) return null;
    return _GuideHistoryEntry(
      cityName: cn,
      firstLlmResult: first,
      secondLlmResult: secondStr,
      recordedAt: parsedTime.toLocal(),
      links: _decodeLinks(map['links']),
    );
  }
}

DateTime _calendarDateOnly(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day);

class _AddCustomPersonaEditorPage extends StatefulWidget {
  const _AddCustomPersonaEditorPage({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_AddCustomPersonaEditorPage> createState() =>
      _AddCustomPersonaEditorPageState();
}

class _AddCustomPersonaEditorPageState extends State<_AddCustomPersonaEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    void refresh() => setState(() {});
    _titleController.addListener(refresh);
    _descriptionController.addListener(refresh);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave {
    final t = _titleController.text.trim();
    final d = _descriptionController.text.trim();
    return t.isNotEmpty && d.isNotEmpty;
  }

  void _submit() {
    if (!_canSave) return;
    Navigator.of(context).pop((
      _titleController.text.trim(),
      _descriptionController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.addCustomPersona),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _canSave ? _submit : null,
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                maxLength: _CustomPersona._maxTitleLen,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.customPersonaTitleLabel,
                  hintText: l10n.customPersonaTitleHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                maxLength: _CustomPersona._maxDescriptionLen,
                minLines: 12,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.customPersonaDescriptionLabel,
                  hintText: l10n.customPersonaHint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  static const _customPersonasPreferenceKey = 'custom_personas_v1';
  static const _maxCustomPersonas = 24;
  static const _guideHistoryPreferenceKey = 'guide_route_history_v1';
  static const _maxGuideHistoryEntries = 100;
  static const _voicePreferenceKey = 'tts_voice_id';
  static const _systemVoicePreferenceValue = 'system-default';

  final _locationService = RegionLocationService();
  final _contextualGuideService = ContextualGuideService();
  final _dynamicTextService = const DynamicGuideTextService();
  final _ttsService = TtsAudioGuideService();

  StreamSubscription<RegionSnapshot>? _regionSubscription;
  StreamSubscription<SpeakingRange?>? _speakingRangeSubscription;
  RegionSnapshot? _currentRegion;
  /// Last non-empty place label from a resolved [RegionSnapshot]; kept when a later snapshot has no name.
  String? _lastResolvedAreaLabel;
  List<TtsVoice> _voices = const [];
  TtsVoice? _selectedVoice;
  String _voiceStatus = '';
  String _preparedTtsText = '';
  SpeakingRange? _currentSpeakingRange;
  String _narrativeStyle = 'Storyteller';
  List<_CustomPersona> _customPersonas = const [];
  List<_GuideHistoryEntry> _guideHistory = const [];
  String? _magazineHistorySelectionKey;
  /// Calendar day (local, date-only) for "Earlier" route history; null until user picks.
  DateTime? _routeHistoryOlderCalendarDay;
  String? _loadedVoiceLocalePrefix;
  List<GuideLink> _guideLinks = const [];
  bool _isMonitoring = false;
  bool _isPlaybackPaused = false;
  bool _isPlaybackCompleted = false;
  bool _isAiThinking = false;
  bool _showOnDeviceNarrationNotice = false;
  /// Before first [ContextualGuideService.getModelInfo], prefer full [RegionSnapshot.displayName].
  /// When true (native on-device LLM unavailable), prompts and UI use primary city label only.
  bool? _compactPlaceLabelsForDevice;
  bool _isIntroductionExpanded = false;
  int _selectedTabIndex = 0;
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
    unawaited(_refreshCompactPlaceLabelsFlag());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_autoStartGuidingOnAppLaunch());
    });
  }

  /// Cold start: begin guiding without the confirmation dialog (OS may still
  /// prompt for location and other permissions).
  Future<void> _autoStartGuidingOnAppLaunch() async {
    if (!mounted || _isMonitoring) return;
    await _startMonitoring();
  }

  Future<void> _refreshCompactPlaceLabelsFlag() async {
    try {
      final info = await _contextualGuideService.getModelInfo();
      if (!mounted) return;
      setState(() {
        _compactPlaceLabelsForDevice = info.usesFallback;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _compactPlaceLabelsForDevice = true;
      });
    }
  }

  /// First locality segment (city/town), omitting county/state/country suffixes from [displayName].
  String _primaryCityPlaceLabel(RegionSnapshot region) {
    final direct = region.city ?? region.town;
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.trim().split(',').first.trim();
    }
    final dn = region.displayName.trim();
    if (dn.isEmpty) return '';
    return dn.split(',').first.trim();
  }

  String? _regionNameOverrideForGuide(RegionSnapshot region) {
    if (_compactPlaceLabelsForDevice != true) return null;
    final p = _primaryCityPlaceLabel(region);
    return p.isEmpty ? null : p;
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

  String _currentLanguageName() {
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

  List<_CustomPersona> _decodeCustomPersonas(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final out = <_CustomPersona>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final p = _CustomPersona.tryParse(item);
          if (p != null) out.add(p);
        } else if (item is Map) {
          final p = _CustomPersona.tryParse(Map<String, dynamic>.from(item));
          if (p != null) out.add(p);
        }
      }
      return out.length > _maxCustomPersonas
          ? out.take(_maxCustomPersonas).toList()
          : out;
    } catch (_) {
      return [];
    }
  }

  bool _isAllowedNarrativeStyle(String style, List<_CustomPersona> customs) {
    const predefined = {
      'Storyteller',
      'Local historian',
      'Friendly road companion',
      'Energetic Town Wit',
    };
    if (predefined.contains(style)) return true;
    final prefix = PromptBuilder.customPersonaValuePrefix;
    if (style.startsWith(prefix)) {
      final id = style.substring(prefix.length);
      return customs.any((c) => c.id == id);
    }
    return false;
  }

  Map<String, CustomPersonaPromptContent> _customPersonasForPrompt() {
    return {
      for (final p in _customPersonas)
        p.id: CustomPersonaPromptContent(
          title: p.title,
          description: p.description,
        ),
    };
  }

  String _truncatePersonaMenuLabel(String text) {
    final t = text.trim();
    if (t.length <= 72) return t;
    return '${t.substring(0, 69)}…';
  }

  String _generatePersonaId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    for (var attempt = 0; attempt < 12; attempt++) {
      final id = List.generate(16, (_) => chars[r.nextInt(chars.length)]).join();
      if (!_customPersonas.any((p) => p.id == id)) {
        return id;
      }
    }
    return '${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _saveCustomPersonas() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _customPersonasPreferenceKey,
      jsonEncode(_customPersonas.map((p) => p.toJson()).toList()),
    );
  }

  List<_GuideHistoryEntry> _decodeGuideHistory(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final out = <_GuideHistoryEntry>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final e = _GuideHistoryEntry.tryParse(item);
          if (e != null) out.add(e);
        } else if (item is Map) {
          final e = _GuideHistoryEntry.tryParse(
            Map<String, dynamic>.from(item),
          );
          if (e != null) out.add(e);
        }
      }
      out.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      return out.length > _maxGuideHistoryEntries
          ? out.take(_maxGuideHistoryEntries).toList()
          : out;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveGuideHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _guideHistoryPreferenceKey,
      jsonEncode(_guideHistory.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _clearGuideHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_guideHistoryPreferenceKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _guideHistory = const [];
      _magazineHistorySelectionKey = null;
      _routeHistoryOlderCalendarDay = null;
    });
  }

  Future<void> _confirmClearGuideHistory() async {
    final l10n = _l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearRouteHistoryConfirmTitle),
        content: Text(l10n.clearRouteHistoryConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _clearGuideHistory();
    }
  }

  _GuideHistoryEntry? _historyEntryFromGuide(GuideContent? guide) {
    if (guide?.secondLlmRaw == null) return null;
    final first = guide!.fullText.trim();
    if (first.isEmpty) return null;
    final city = guide.regionName.trim();
    if (city.isEmpty) return null;
    return _GuideHistoryEntry(
      cityName: city,
      firstLlmResult: first,
      secondLlmResult: guide.secondLlmRaw!.trim(),
      recordedAt: guide.generatedAt.toLocal(),
      links: guide.links,
    );
  }

  Future<void> _openAddCustomPersonaEditor() async {
    if (_customPersonas.length >= _maxCustomPersonas || !mounted) {
      return;
    }
    final l10n = _l10n;
    final result = await Navigator.of(context).push<(String, String)?>(
      MaterialPageRoute<(String, String)?>(
        fullscreenDialog: true,
        builder: (ctx) => _AddCustomPersonaEditorPage(l10n: l10n),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    final title = result.$1.trim();
    final description = result.$2.trim();
    if (title.isEmpty || description.isEmpty) {
      return;
    }
    _commitCustomPersona(title, description);
  }

  void _commitCustomPersona(String title, String description) {
    final ti = title.trim();
    final de = description.trim();
    if (ti.isEmpty ||
        de.isEmpty ||
        _customPersonas.length >= _maxCustomPersonas) {
      return;
    }
    final persona = _CustomPersona(
      id: _generatePersonaId(),
      title: ti.length > _CustomPersona._maxTitleLen
          ? ti.substring(0, _CustomPersona._maxTitleLen)
          : ti,
      description: de.length > _CustomPersona._maxDescriptionLen
          ? de.substring(0, _CustomPersona._maxDescriptionLen)
          : de,
    );
    final styleValue =
        '${PromptBuilder.customPersonaValuePrefix}${persona.id}';
    setState(() {
      _customPersonas = [..._customPersonas, persona];
      _narrativeStyle = styleValue;
    });
    unawaited(_saveCustomPersonas());
    unawaited(_saveNarrativeStyle(styleValue));
  }

  void _removeCustomPersona(String id) {
    final prefix = PromptBuilder.customPersonaValuePrefix;
    setState(() {
      _customPersonas = _customPersonas.where((p) => p.id != id).toList();
      if (_narrativeStyle == '$prefix$id') {
        _narrativeStyle = 'Storyteller';
        unawaited(_saveNarrativeStyle(_narrativeStyle));
      }
    });
    unawaited(_saveCustomPersonas());
  }

  Future<void> _loadSavedSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final customs = _decodeCustomPersonas(
      preferences.getString(_customPersonasPreferenceKey),
    );
    final history = _decodeGuideHistory(
      preferences.getString(_guideHistoryPreferenceKey),
    );
    final savedNarrativeStyle = preferences.getString(
      _narrativeStylePreferenceKey,
    );
    if (!mounted) {
      return;
    }

    final normalizedStyle = savedNarrativeStyle == 'Cinematic storyteller'
        ? 'Storyteller'
        : savedNarrativeStyle;

    setState(() {
      _customPersonas = customs;
      _guideHistory = history;
    });

    final candidate = normalizedStyle;
    if (candidate != null && _isAllowedNarrativeStyle(candidate, customs)) {
      setState(() => _narrativeStyle = candidate);
    } else if (candidate != null) {
      setState(() => _narrativeStyle = 'Storyteller');
      unawaited(_saveNarrativeStyle('Storyteller'));
    }

    if (savedNarrativeStyle == 'Cinematic storyteller') {
      unawaited(_saveNarrativeStyle('Storyteller'));
    }
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
      await _ttsService.configure();
      unawaited(OfflineCityLookup.instance.preload());
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

  Future<void> _handleRegionChange(RegionSnapshot region) async {
    if (_compactPlaceLabelsForDevice == null) {
      try {
        final info = await _contextualGuideService.getModelInfo();
        _compactPlaceLabelsForDevice = info.usesFallback;
      } catch (_) {
        _compactPlaceLabelsForDevice = true;
      }
      if (!mounted) return;
    }

    final label = _areaLabelFromRegion(region);
    setState(() {
      _currentRegion = region;
      if (label != null && label.isNotEmpty) {
        _lastResolvedAreaLabel = label;
      }
      _preparedTtsText = '';
      _currentSpeakingRange = null;
      _guideLinks = const [];
      _isAiThinking = false;
    });

    final weatherUsesImperialUnits = _localeUsesMiles(context);

    try {
      final guide = await _contextualGuideService.buildGuide(
        region,
        narrativeStyle: _narrativeStyle,
        outputLanguage: _llmOutputLanguage(),
        weatherUsesImperialUnits: weatherUsesImperialUnits,
        regionNameOverride: _regionNameOverrideForGuide(region),
        customPersonasById: _customPersonasForPrompt(),
        onPipelineEvent: _handlePipelineEvent,
      );
      final text = _dynamicTextService.selectText(guide: guide);
      _setGuideOutput(
        text: text,
        links: guide.links,
        guideForHistory: guide,
      );

      final playbackRunId = _beginPlayback();
      await _ttsService.speak(text);
      _completePlayback(playbackRunId);
    } catch (error, stackTrace) {
      debugPrint('Guide pipeline failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _isAiThinking = false;
      });
    }
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
    GuideContent? guideForHistory,
  }) {
    final historyEntry = _historyEntryFromGuide(guideForHistory);
    setState(() {
      _preparedTtsText = text;
      _currentSpeakingRange = null;
      _guideLinks = links;
      _isPlaybackPaused = false;
      _isPlaybackCompleted = false;
      _resumeSpeakingIndex = 0;
      _isAiThinking = false;
      _magazineHistorySelectionKey = null;
      _showOnDeviceNarrationNotice =
          guideForHistory?.showOnDeviceUnavailableNotice ?? false;
      if (historyEntry != null) {
        _guideHistory = [
          historyEntry,
          ..._guideHistory,
        ];
        if (_guideHistory.length > _maxGuideHistoryEntries) {
          _guideHistory =
              _guideHistory.take(_maxGuideHistoryEntries).toList();
        }
      }
    });
    if (historyEntry != null) {
      unawaited(_saveGuideHistory());
    }
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

    if (_ttsService.isUtteranceActive) {
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
    if (!mounted) {
      return;
    }

    if (event.message == 'First LLM city intro prompt is ready.') {
      setState(() {
        _isAiThinking = true;
      });
    } else if (event.message == 'Proper noun extraction received.') {
      setState(() {
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
    final areaName = _magazineDetailQuerySuffix();
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

  /// Place label from [region] only when city/town/displayName yield usable text.
  String? _areaLabelFromRegion(RegionSnapshot region) {
    if (_compactPlaceLabelsForDevice == true) {
      final p = _primaryCityPlaceLabel(region);
      if (p.isNotEmpty) return p;
    }
    final direct = region.city ?? region.town;
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.trim();
    }
    final dn = region.displayName.trim();
    if (dn.isNotEmpty) {
      return dn.split(',').first.trim();
    }
    return null;
  }

  String _currentAreaName() {
    final region = _currentRegion;
    if (region == null) {
      return _lastResolvedAreaLabel ?? _l10n.noLocationYet;
    }

    final fromRegion = _areaLabelFromRegion(region);
    if (fromRegion != null && fromRegion.isNotEmpty) {
      return fromRegion;
    }

    return _lastResolvedAreaLabel ?? _l10n.noLocationYet;
  }

  /// App [supportedLocales] uses plain [Locale('en')] without a region, so
  /// [Localizations.localeOf] often has no [countryCode]. Use the OS locale
  /// (e.g. iOS English (US) → `en_US`) when deciding miles vs km and °F vs °C.
  static bool _localeUsesMiles(BuildContext context) {
    bool enUnitedStates(Locale l) {
      if (l.languageCode != 'en') return false;
      final cc = l.countryCode;
      return cc != null &&
          cc.isNotEmpty &&
          cc.toUpperCase() == 'US';
    }

    if (enUnitedStates(Localizations.localeOf(context))) return true;
    if (enUnitedStates(WidgetsBinding.instance.platformDispatcher.locale)) {
      return true;
    }

    if (kIsWeb) return false;
    try {
      final normalized =
          Platform.localeName.toLowerCase().replaceAll('-', '_');
      return normalized.startsWith('en_us');
    } catch (_) {
      return false;
    }
  }

  String _formatNearestCityDistance(BuildContext context, double miles) {
    final locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
      locale: locale.toLanguageTag(),
      decimalDigits: 1,
    );
    if (_localeUsesMiles(context)) {
      return '${nf.format(miles)}\u00a0mi';
    }
    final km = miles * 1.609344;
    return '${nf.format(km)}\u00a0km';
  }

  /// [_currentAreaName] plus bundled nearest-city distance when the current
  /// snapshot came from offline GeoNames lookup.
  String _currentAreaDisplayLabel(BuildContext context) {
    final base = _currentAreaName();
    final miles = _currentRegion?.offlineNearestDistanceMiles;
    if (miles == null) {
      return base;
    }
    return '$base · ${_formatNearestCityDistance(context, miles)}';
  }

  Widget _buildOnDeviceNarrationNotice(
    BuildContext context, {
    bool onDarkBackdrop = false,
  }) {
    if (!_showOnDeviceNarrationNotice) {
      return const SizedBox.shrink();
    }
    final l10n = _l10n;
    final text = l10n.onDeviceNarrationNotice;
    final scheme = Theme.of(context).colorScheme;
    final fg = onDarkBackdrop ? Colors.white.withValues(alpha: 0.92) : scheme.onSecondaryContainer;
    final iconColor =
        onDarkBackdrop ? Colors.white.withValues(alpha: 0.85) : scheme.onSecondaryContainer;
    return Padding(
      padding: EdgeInsets.only(bottom: onDarkBackdrop ? 10 : 12, top: onDarkBackdrop ? 6 : 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onDarkBackdrop
              ? Colors.black.withValues(alpha: 0.42)
              : scheme.secondaryContainer.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: onDarkBackdrop ? Colors.white24 : scheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: iconColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: fg,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _GuideHistoryEntry? _resolvedMagazineHistoryEntry() {
    final key = _magazineHistorySelectionKey;
    if (key == null) return null;
    for (final e in _guideHistory) {
      if (e.selectionKey == key) return e;
    }
    return null;
  }

  String _magazineDetailShortTitle() {
    final e = _resolvedMagazineHistoryEntry();
    if (e != null) {
      final p = e.cityName.split(',').first.trim();
      if (p.isNotEmpty) return p;
    }
    return _currentAreaName();
  }

  String _magazineDetailQuerySuffix() {
    final e = _resolvedMagazineHistoryEntry();
    if (e != null && e.cityName.trim().isNotEmpty) {
      return e.cityName.trim();
    }
    final region = _currentRegion;
    if (region != null) {
      if (_compactPlaceLabelsForDevice == true) {
        final p = _primaryCityPlaceLabel(region);
        if (p.isNotEmpty) return p;
      }
      final d = region.displayName.trim();
      if (d.isNotEmpty) return d;
      return _currentAreaName();
    }
    return _currentAreaName();
  }

  List<GuideLink> _magazineRelatedLinks() {
    final e = _resolvedMagazineHistoryEntry();
    if (e != null && e.links.isNotEmpty) return e.links;
    return _guideLinks;
  }

  bool _hasCurrentArea() {
    return _currentRegion != null;
  }

  String _introductionExpandedBody(AppLocalizations l10n) {
    final more = !kIsWeb && Platform.isIOS
        ? l10n.introductionMoreIos
        : l10n.introductionMoreAndroid;
    return '${l10n.introductionBodyMain}\n\n$more';
  }

  Widget _buildLiveGuideTab(BuildContext context) {
    final areaTitle = _currentAreaDisplayLabel(context);
    final areaQuery = _currentAreaName();
    final l10n = _l10n;
    final hasNarrative = _preparedTtsText.trim().isNotEmpty;
    final backgroundUrl =
        'https://source.unsplash.com/1200x900/?${Uri.encodeComponent('$areaQuery city landscape road')}';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: _HeroGuideCard(
              narrationNotice: _buildOnDeviceNarrationNotice(
                context,
                onDarkBackdrop: true,
              ),
              areaName: areaTitle,
              imageUrl: backgroundUrl,
              narrative: hasNarrative
                  ? _preparedTtsText
                  : l10n.startGuiding,
              speakingRange: _currentSpeakingRange,
              isThinking: _isAiThinking,
              isSpeaking:
                  _currentSpeakingRange != null,
              isMonitoring: _isMonitoring,
              isPaused: _isPlaybackPaused,
              isCompleted: _isPlaybackCompleted,
              isTtsUtteranceActive: _ttsService.isUtteranceActive,
              onStartGuiding:
                  _isMonitoring ? null : () => _confirmStartGuiding(context),
              onTogglePlayback: hasNarrative ? _togglePlayback : null,
          onReplay: hasNarrative ? _replayNarrative : null,
          onPauseGuide: _isMonitoring ? _stopMonitoring : null,
        ),
          ),
        );
      },
    );
  }

  ({
    List<_GuideHistoryEntry> today,
    List<_GuideHistoryEntry> yesterday,
    List<_GuideHistoryEntry> dayBeforeYesterday,
    Map<DateTime, List<_GuideHistoryEntry>> olderByDay,
  }) _partitionGuideHistory() {
    final now = DateTime.now();
    final todayD = _calendarDateOnly(now);
    final yD = todayD.subtract(const Duration(days: 1));
    final byeD = todayD.subtract(const Duration(days: 2));

    final today = <_GuideHistoryEntry>[];
    final yesterday = <_GuideHistoryEntry>[];
    final dayBefore = <_GuideHistoryEntry>[];
    final older = <DateTime, List<_GuideHistoryEntry>>{};

    for (final e in _guideHistory) {
      final d = _calendarDateOnly(e.recordedAt);
      if (d == todayD) {
        today.add(e);
      } else if (d == yD) {
        yesterday.add(e);
      } else if (d == byeD) {
        dayBefore.add(e);
      } else {
        older.putIfAbsent(d, () => []).add(e);
      }
    }
    return (
      today: today,
      yesterday: yesterday,
      dayBeforeYesterday: dayBefore,
      olderByDay: older,
    );
  }

  DateTime _clampCalendarDay(DateTime d, DateTime first, DateTime last) {
    if (d.isBefore(first)) return first;
    if (d.isAfter(last)) return last;
    return d;
  }

  Widget _buildGuideHistoryExpansionTile(
    BuildContext context,
    AppLocalizations l10n,
    _GuideHistoryEntry entry,
  ) {
    final sel = _magazineHistorySelectionKey == entry.selectionKey;
    final tint = Theme.of(context)
        .colorScheme
        .primaryContainer
        .withValues(alpha: 0.28);
    return ExpansionTile(
      key: ValueKey(entry.selectionKey),
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      backgroundColor: sel ? tint : null,
      collapsedBackgroundColor: sel ? tint : null,
      onExpansionChanged: (expanded) {
        setState(() {
          if (expanded) {
            _magazineHistorySelectionKey = entry.selectionKey;
          } else if (_magazineHistorySelectionKey == entry.selectionKey) {
            _magazineHistorySelectionKey = null;
          }
        });
      },
      title: Text(
        entry.cityName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat.yMMMd().add_jm().format(entry.recordedAt),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cityNarration,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              SelectableText(
                entry.firstLlmResult,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _routeHistoryDividedTiles(
    BuildContext context,
    AppLocalizations l10n,
    List<_GuideHistoryEntry> entries,
  ) {
    final out = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) {
        out.add(const Divider(height: 1));
      }
      out.add(_buildGuideHistoryExpansionTile(context, l10n, entries[i]));
    }
    return out;
  }

  Widget _buildRouteHistoryDateGroupCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required String groupTitle,
    required List<_GuideHistoryEntry> entries,
  }) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            groupTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          children: _routeHistoryDividedTiles(context, l10n, entries),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    final titleShort = _magazineDetailShortTitle();
    final queryContext = _magazineDetailQuerySuffix();
    final relatedLinks = _magazineRelatedLinks();
    final l10n = _l10n;
    final cards = [
      _DetailCardData(
        title: l10n.heritage,
        icon: Icons.account_balance,
        body: l10n.heritageBody(titleShort),
        query: '$queryContext history name origin',
        opensMap: false,
      ),
      _DetailCardData(
        title: l10n.icons,
        icon: Icons.stars,
        body: l10n.iconsBody,
        query: '$queryContext famous people',
        opensMap: false,
      ),
      _DetailCardData(
        title: l10n.views,
        icon: Icons.landscape,
        body: l10n.viewsBody,
        query: '$queryContext scenic viewpoint',
        opensMap: true,
      ),
      _DetailCardData(
        title: l10n.bites,
        icon: Icons.restaurant,
        body: l10n.bitesBody,
        query: '$queryContext best local food signature menu',
        opensMap: true,
      ),
      _DetailCardData(
        title: l10n.goods,
        icon: Icons.local_florist,
        body: l10n.goodsBody,
        query: '$queryContext local products wine beer seafood agriculture',
        opensMap: false,
      ),
      _DetailCardData(
        title: l10n.trivia,
        icon: Icons.movie,
        body: l10n.triviaBody,
        query: '$queryContext trivia film location festival event',
        opensMap: false,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.digitalMagazine, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.detailsIntro(titleShort),
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
          child: _GuideLinks(links: relatedLinks, onOpen: _openGuideLink),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.routeHistoryTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (_guideHistory.isEmpty)
          Text(
            l10n.routeHistoryEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          )
        else
          Builder(
            builder: (context) {
              final partition = _partitionGuideHistory();
              final todayD = _calendarDateOnly(DateTime.now());
              final yD = todayD.subtract(const Duration(days: 1));
              final byeD = todayD.subtract(const Duration(days: 2));
              final lastCal = todayD.subtract(const Duration(days: 3));
              final older = partition.olderByDay;
              final olderDays = older.keys.toList()..sort();
              final firstCal = olderDays.isNotEmpty ? olderDays.first : lastCal;
              final pickerLast =
                  lastCal.isBefore(firstCal) ? firstCal : lastCal;
              final picked = _routeHistoryOlderCalendarDay;
              final selectedCal = olderDays.isEmpty
                  ? pickerLast
                  : picked != null
                      ? _clampCalendarDay(picked, firstCal, pickerLast)
                      : _clampCalendarDay(olderDays.last, firstCal, pickerLast);
              final selectedKey = _calendarDateOnly(selectedCal);
              final olderDayEntries = older[selectedKey] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (partition.today.isNotEmpty) ...[
                    Text(
                      l10n.routeHistoryToday,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: _routeHistoryDividedTiles(
                          context,
                          l10n,
                          partition.today,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildRouteHistoryDateGroupCard(
                    context: context,
                    l10n: l10n,
                    groupTitle:
                        '${l10n.routeHistoryYesterday} · ${DateFormat.yMMMd().format(yD)}',
                    entries: partition.yesterday,
                  ),
                  _buildRouteHistoryDateGroupCard(
                    context: context,
                    l10n: l10n,
                    groupTitle:
                        '${l10n.routeHistoryDayBeforeYesterday} · ${DateFormat.yMMMd().format(byeD)}',
                    entries: partition.dayBeforeYesterday,
                  ),
                  if (olderDays.isNotEmpty) ...[
                    Text(
                      l10n.routeHistoryEarlier,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CalendarDatePicker(
                            key: ValueKey<String>(
                              selectedCal.toIso8601String(),
                            ),
                            firstDate: firstCal,
                            lastDate: pickerLast,
                            initialDate: selectedCal,
                            onDateChanged: (d) {
                              setState(() {
                                _routeHistoryOlderCalendarDay =
                                    _calendarDateOnly(d);
                              });
                            },
                          ),
                          const Divider(height: 1),
                          if (olderDayEntries.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                l10n.routeHistoryNoEntriesThatDay,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                            )
                          else
                            Column(
                              children: _routeHistoryDividedTiles(
                                context,
                                l10n,
                                olderDayEntries,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildMoreTab(BuildContext context) {
    final l10n = _l10n;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _IntroductionCard(
          title: l10n.introductionTitle,
          summary: l10n.introductionSummary,
          body: _introductionExpandedBody(l10n),
          expanded: _isIntroductionExpanded,
          onTap: () {
            setState(() {
              _isIntroductionExpanded = !_isIntroductionExpanded;
            });
          },
        ),
        const SizedBox(height: 12),
        _StatusCard(
          title: l10n.personaSettings,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ExpandableChoiceField(
                label: l10n.narrativeStyle,
                selectedValue: _narrativeStyle,
                entries: [
                  (value: 'Storyteller', label: l10n.cinematicStoryteller),
                  (value: 'Local historian', label: l10n.localHistorian),
                  (
                    value: 'Friendly road companion',
                    label: l10n.friendlyRoadCompanion,
                  ),
                  (
                    value: 'Energetic Town Wit',
                    label: l10n.energeticTownWit,
                  ),
                  for (final p in _customPersonas)
                    (
                      value:
                          '${PromptBuilder.customPersonaValuePrefix}${p.id}',
                      label: _truncatePersonaMenuLabel(p.title),
                    ),
                ],
                onSelected: (value) {
                  setState(() => _narrativeStyle = value);
                  unawaited(_saveNarrativeStyle(value));
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.customPersonasSectionTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: _customPersonas.length >= _maxCustomPersonas
                      ? null
                      : () => _openAddCustomPersonaEditor(),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addCustomPersona),
                ),
              ),
              if (_customPersonas.length >= _maxCustomPersonas)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.customPersonasMaxHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (_customPersonas.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._customPersonas.map(
                  (p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: l10n.removeCustomPersona,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeCustomPersona(p.id),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          title: l10n.languageSettings,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.currentLanguage(_currentLanguageName())),
              if (Platform.isIOS) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.appleIntelligenceSiriLanguageNotice,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
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
        const SizedBox(height: 12),
        _StatusCard(
          title: l10n.clearRouteHistoryTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.clearRouteHistoryDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _guideHistory.isEmpty
                      ? null
                      : _confirmClearGuideHistory,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.clearRouteHistoryButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final canOpenMagazine =
        canOpenDetails || _guideHistory.isNotEmpty;
    final disabledColor = Theme.of(context).disabledColor;
    final l10n = _l10n;

    return Scaffold(
      appBar: AppBar(
        title: _AppTitle(
          currentAreaName: _currentAreaDisplayLabel(context),
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
          if (index == 1 && !canOpenMagazine) {
            return;
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
              color: canOpenMagazine ? null : disabledColor,
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

class _ExpandableChoiceField extends StatefulWidget {
  const _ExpandableChoiceField({
    required this.label,
    required this.selectedValue,
    required this.entries,
    required this.onSelected,
  });

  final String label;
  final String selectedValue;
  final List<({String value, String label})> entries;
  final ValueChanged<String> onSelected;

  @override
  State<_ExpandableChoiceField> createState() => _ExpandableChoiceFieldState();
}

class _ExpandableChoiceFieldState extends State<_ExpandableChoiceField> {
  bool _expanded = false;

  String _displayLabel() {
    for (final e in widget.entries) {
      if (e.value == widget.selectedValue) {
        return e.label;
      }
    }
    return widget.entries.isEmpty ? '' : widget.entries.first.label;
  }

  @override
  void didUpdateWidget(_ExpandableChoiceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() => _expanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => setState(() => _expanded = !_expanded),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _displayLabel(),
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 200),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: dividerColor.withValues(alpha: 0.45),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < widget.entries.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: dividerColor.withValues(alpha: 0.35),
                        ),
                      InkWell(
                        onTap: () {
                          widget.onSelected(widget.entries[i].value);
                          setState(() => _expanded = false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 26,
                                child: widget.entries[i].value ==
                                        widget.selectedValue
                                    ? Icon(
                                        Icons.check,
                                        size: 22,
                                        color: scheme.primary,
                                      )
                                    : const SizedBox(height: 22),
                              ),
                              Expanded(
                                child: Text(
                                  widget.entries[i].label,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroductionCard extends StatelessWidget {
  const _IntroductionCard({
    required this.title,
    required this.summary,
    required this.body,
    required this.expanded,
    required this.onTap,
  });

  static const _backgroundImageUrl =
      'https://source.unsplash.com/1200x900/?scenic road drive horizon';

  final String title;
  final String summary;
  final String body;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: Image.network(
              _backgroundImageUrl,
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          body,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    height: 1.45,
                                  ),
                        ),
                      ),
                      crossFadeState: expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 220),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroGuideCard extends StatelessWidget {
  const _HeroGuideCard({
    required this.narrationNotice,
    required this.areaName,
    required this.imageUrl,
    required this.narrative,
    required this.speakingRange,
    required this.isThinking,
    required this.isSpeaking,
    required this.isMonitoring,
    required this.isPaused,
    required this.isCompleted,
    required this.isTtsUtteranceActive,
    required this.onStartGuiding,
    required this.onTogglePlayback,
    required this.onReplay,
    required this.onPauseGuide,
  });

  final Widget narrationNotice;
  final String areaName;
  final String imageUrl;
  final String narrative;
  final SpeakingRange? speakingRange;
  final bool isThinking;
  final bool isSpeaking;
  final bool isMonitoring;
  final bool isPaused;
  final bool isCompleted;
  final bool isTtsUtteranceActive;
  final VoidCallback? onStartGuiding;
  final VoidCallback? onTogglePlayback;
  final VoidCallback? onReplay;
  final VoidCallback? onPauseGuide;

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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    areaName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  narrationNotice,
                  const SizedBox(height: 12),
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
                  Text(
                    l10n.liveNarrative,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: isThinking
                        ? const Align(
                            alignment: Alignment.topLeft,
                            child: _ThinkingNarrativeText(),
                          )
                        : _NarrativeWindow(
                            text: narrative,
                            speakingRange: speakingRange,
                            textStyle:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                    ),
                            fallbackColor: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          tooltip: l10n.startGuiding,
                          onPressed: onStartGuiding,
                          icon: const Icon(Icons.navigation),
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: isPaused ? l10n.resume : l10n.pause,
                          onPressed: (isCompleted &&
                                  !isPaused &&
                                  !isTtsUtteranceActive)
                              ? null
                              : onTogglePlayback,
                          icon: Icon(
                            isPaused ? Icons.play_arrow : Icons.pause,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: onReplay == null
                            ? IconButton(
                                tooltip: l10n.replay,
                                onPressed: null,
                                icon: const Icon(Icons.replay),
                                color: Colors.white54,
                              )
                            : IconButton(
                                tooltip: l10n.replay,
                                onPressed: onReplay,
                                icon: const Icon(Icons.replay),
                                color: Colors.white,
                              ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: l10n.pauseGuide,
                          onPressed: onPauseGuide,
                          icon: const Icon(Icons.stop),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        textDirection: Directionality.of(context),
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
    final fallbackHeight =
        (style.fontSize ?? 20) * (style.height ?? 1.35) * 3.2;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : fallbackHeight;

        final range = widget.speakingRange;
        if (range != null &&
            range.start >= 0 &&
            range.start < widget.text.length) {
          _centerCurrentLine(
            range: range,
            style: style,
            maxWidth: constraints.maxWidth,
            viewportHeight: viewportHeight,
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
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
    );
  }
}

class _SynchronizedNarrativeText extends StatelessWidget {
  const _SynchronizedNarrativeText({
    required this.text,
    required this.speakingRange,
    this.style,
    this.fallbackColor,
  });

  final String text;
  final SpeakingRange? speakingRange;
  final TextStyle? style;
  final Color? fallbackColor;

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
        _ExpandableChoiceField(
          label: l10n.voice,
          selectedValue: selectedVoice?.id ?? 'system-default',
          entries: [
            (value: 'system-default', label: l10n.systemDefault),
            for (final voice in voices)
              (value: voice.id, label: voice.displayName),
          ],
          onSelected: (value) {
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
