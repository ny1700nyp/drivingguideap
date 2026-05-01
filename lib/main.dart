import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'features/audio/tts_audio_guide_service.dart';
import 'features/guide/contextual_guide_service.dart';
import 'features/guide/dynamic_guide_text_service.dart';
import 'features/location/region_location_service.dart';
import 'models/guide_content.dart';
import 'models/region_snapshot.dart';
import 'models/tts_voice.dart';

void main() {
  runApp(const DrivingGuideApp());
}

class DrivingGuideApp extends StatelessWidget {
  const DrivingGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving Guide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
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
  RegionSnapshot? _currentRegion;
  List<TtsVoice> _voices = const [];
  TtsVoice? _selectedVoice;
  String _voiceStatus = 'Loading voices...';
  String _firstLlmInput = '';
  String _secondLlmResult = '';
  String _preparedTtsText = '';
  List<GuideLink> _guideLinks = const [];
  String? _currentTestStop;
  bool _isMonitoring = false;
  bool _isTestRouteRunning = false;
  bool _isTestRouteSpeaking = false;
  int _testRouteIndex = 0;
  int _testRouteRunId = 0;

  @override
  void initState() {
    super.initState();
    _regionSubscription = _locationService.regionChanges.listen(
      (region) => unawaited(_handleRegionChange(region)),
      onError: (Object error) => debugPrint('Location error: $error'),
    );
    unawaited(_loadVoices());
  }

  Future<void> _loadVoices() async {
    try {
      final voices = await _ttsService.availableVoices(localePrefix: 'en-');
      final selectedVoice = voices.isEmpty ? null : voices.first;
      if (!mounted) {
        return;
      }
      setState(() {
        _voices = voices;
        _selectedVoice = selectedVoice;
        _voiceStatus = voices.isEmpty
            ? 'No premium or enhanced English voice found. Using system default.'
            : '${voices.length} premium/enhanced English voice(s) available. Default: ${selectedVoice?.qualityLabel}.';
      });
      await _ttsService.selectVoice(selectedVoice);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _voiceStatus = 'Could not load voices: $error';
      });
    }
  }

  Future<void> _startMonitoring() async {
    if (_isMonitoring) {
      return;
    }

    try {
      await _stopTestRoute();
      await _ttsService.configure();
      await _locationService.start();
      setState(() {
        _isMonitoring = true;
      });
    } catch (error) {
      debugPrint('Could not start monitoring: $error');
    }
  }

  Future<void> _stopMonitoring() async {
    await _locationService.stop();
    await _ttsService.stop();
    setState(() {
      _isMonitoring = false;
    });
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
      _guideLinks = const [];
    });

    await _runNextTestRouteStop();
  }

  Future<void> _stopTestRoute() async {
    if (!mounted) {
      return;
    }
    _testRouteRunId++;
    await _ttsService.stop();
    setState(() {
      _isTestRouteRunning = false;
      _isTestRouteSpeaking = false;
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
    await _ttsService.stop();
    final stop = _sacramentoToSeattleRoute[index];
    _testRouteIndex = index + 1;

    setState(() {
      _currentTestStop = stop;
      _firstLlmInput = '';
      _secondLlmResult = '';
      _preparedTtsText = '';
      _guideLinks = const [];
      _isTestRouteSpeaking = true;
    });

    try {
      final guide = await _contextualGuideService.buildGuideForRegionName(
        regionName: stop,
        speedMph: 35,
        onPipelineEvent: _handlePipelineEvent,
      );
      if (!mounted || runId != _testRouteRunId) {
        return;
      }
      final text = _dynamicTextService.selectText(guide: guide, speedMph: 35);
      setState(() {
        _preparedTtsText = text;
        _guideLinks = guide.links;
      });
      await _ttsService.speak(text);
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
      _guideLinks = const [];
    });

    final guide = await _contextualGuideService.buildGuide(
      region,
      onPipelineEvent: _handlePipelineEvent,
    );
    final text = _dynamicTextService.selectText(
      guide: guide,
      speedMph: region.speedMph,
    );
    setState(() {
      _preparedTtsText = text;
      _guideLinks = guide.links;
    });

    await _ttsService.speak(text);
  }

  Future<void> _playSampleGuide() async {
    setState(() {
      _firstLlmInput = '';
      _secondLlmResult = '';
      _preparedTtsText = '';
      _guideLinks = const [];
    });

    final guide = await _contextualGuideService.buildGuideForRegionName(
      regionName: 'Sonoma County, California',
      speedMph: 35,
      onPipelineEvent: _handlePipelineEvent,
    );
    final text = _dynamicTextService.selectText(guide: guide, speedMph: 35);
    setState(() {
      _preparedTtsText = text;
      _guideLinks = guide.links;
    });
    await _ttsService.speak(text);
  }

  Future<void> _selectVoice(TtsVoice? voice) async {
    setState(() {
      _selectedVoice = voice;
      _voiceStatus = voice == null
          ? 'Using the system default English voice.'
          : 'Using ${voice.displayName}.';
    });
    await _ttsService.selectVoice(voice);
  }

  void _handlePipelineEvent(GuidePipelineEvent event) {
    if (event.payload == null || !mounted) {
      return;
    }

    if (event.message == 'First LLM city intro prompt is ready.') {
      setState(() {
        _firstLlmInput = event.payload!;
      });
    } else if (event.message == 'Proper noun extraction received.') {
      setState(() {
        _secondLlmResult = event.payload!;
      });
    }
  }

  Future<void> _openGuideLink(GuideLink link) async {
    final uri = Uri.parse(link.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open link: ${link.url}');
    }
  }

  @override
  void dispose() {
    _regionSubscription?.cancel();
    unawaited(_locationService.dispose());
    unawaited(_contextualGuideService.dispose());
    unawaited(_ttsService.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final region = _currentRegion;
    final currentAreaText = _currentTestStop != null
        ? 'Test route: $_currentTestStop'
        : region == null
        ? 'No location yet.'
        : '${region.displayName} · ${region.speedMph.toStringAsFixed(1)} mph';

    return Scaffold(
      appBar: AppBar(title: const Text('Driving Guide')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Real-Time Roadside Audio Guide',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Detects city and county changes as you drive, then reads cinematic local history, landmarks, scenic viewpoints, and famous-figure stories aloud.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _StatusCard(title: 'Current Area', child: Text(currentAreaText)),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'TTS Voice',
            child: _VoiceSelector(
              voices: _voices,
              selectedVoice: _selectedVoice,
              status: _voiceStatus,
              onChanged: _selectVoice,
            ),
          ),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'First LLM Input',
            child: SelectableText(
              _firstLlmInput.isEmpty
                  ? 'No first LLM input prepared yet.'
                  : _firstLlmInput,
            ),
          ),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'Prepared TTS Text',
            child: SelectableText(
              _preparedTtsText.isEmpty
                  ? 'No TTS text prepared yet.'
                  : _preparedTtsText,
            ),
          ),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'Second LLM Result',
            child: SelectableText(
              _secondLlmResult.isEmpty
                  ? 'No second LLM result received yet.'
                  : _secondLlmResult,
            ),
          ),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'Related Links',
            child: _GuideLinks(
              links: _guideLinks,
              onOpen: _openGuideLink,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isMonitoring || _isTestRouteRunning
                ? null
                : _startMonitoring,
            icon: const Icon(Icons.navigation),
            label: const Text('Start Area Monitoring'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isMonitoring ? _stopMonitoring : null,
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _isTestRouteRunning ? null : _startTestRoute,
            icon: const Icon(Icons.route),
            label: const Text('Start Sacramento to Seattle Test Route'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isTestRouteRunning ? _stopTestRoute : null,
            icon: const Icon(Icons.pause_circle),
            label: const Text('Stop Test Route'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTestRouteRunning &&
                          _testRouteIndex > 1
                      ? _runPreviousTestRouteStop
                      : null,
                  icon: const Icon(Icons.skip_previous),
                  label: const Text('Prev Stop'),
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
                  label: const Text('Next Stop'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isTestRouteRunning ? null : _playSampleGuide,
            icon: const Icon(Icons.volume_up),
            label: const Text('Play Sample Guide'),
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
      return const Text('No related links prepared yet.');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedVoice?.id,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Voice',
          ),
          items: [
            const DropdownMenuItem(
              value: 'system-default',
              child: Text('System default'),
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
        Text(status, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
