import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'features/audio/tts_audio_guide_service.dart';
import 'features/guide/dynamic_guide_text_service.dart';
import 'features/location/region_location_service.dart';
import 'features/public_data/public_data_guide_repository.dart';
import 'models/guide_content.dart';
import 'models/region_snapshot.dart';

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
  final _locationService = RegionLocationService();
  final _guideRepository = PublicDataGuideRepository();
  final _dynamicTextService = const DynamicGuideTextService();
  final _ttsService = TtsAudioGuideService();

  StreamSubscription<RegionSnapshot>? _regionSubscription;
  RegionSnapshot? _currentRegion;
  GuideContent? _lastGuide;
  String _status = 'Idle';
  String _lastSpokenText = '';
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _regionSubscription = _locationService.regionChanges.listen(
      (region) => unawaited(_handleRegionChange(region)),
      onError: (Object error) => _setStatus('Location error: $error'),
    );
  }

  Future<void> _startMonitoring() async {
    if (_isMonitoring) {
      return;
    }

    setState(() {
      _status = 'Checking location permission and current area.';
    });

    try {
      await _ttsService.configure();
      await _locationService.start();
      setState(() {
        _isMonitoring = true;
        _status = 'Monitoring city/county changes every minute.';
      });
    } catch (error) {
      _setStatus('Could not start: $error');
    }
  }

  Future<void> _stopMonitoring() async {
    await _locationService.stop();
    await _ttsService.stop();
    setState(() {
      _isMonitoring = false;
      _status = 'Stopped';
    });
  }

  Future<void> _handleRegionChange(RegionSnapshot region) async {
    setState(() {
      _currentRegion = region;
      _status = 'Building guide for ${region.displayName}.';
    });

    final guide = await _guideRepository.fetchGuideForRegion(
      region.displayName,
    );
    final text = _dynamicTextService.selectText(
      guide: guide,
      speedMph: region.speedMph,
    );

    setState(() {
      _lastGuide = guide;
      _lastSpokenText = text;
      _status = 'Playing guide for ${region.displayName}.';
    });

    await _ttsService.speak(text);
    _setStatus('Waiting for the next area change.');
  }

  Future<void> _playSampleGuide() async {
    final guide = await _guideRepository.fetchGuideForRegion(
      'Sonoma County, California',
    );
    final text = _dynamicTextService.selectText(guide: guide, speedMph: 35);
    setState(() {
      _lastGuide = guide;
      _lastSpokenText = text;
      _status = 'Playing sample guide.';
    });
    await _ttsService.speak(text);
    _setStatus('Sample guide complete.');
  }

  void _setStatus(String status) {
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
    });
  }

  @override
  void dispose() {
    _regionSubscription?.cancel();
    _locationService.dispose();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final region = _currentRegion;
    final guide = _lastGuide;

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
            'Detects city and county changes as you drive, then reads concise local context, seasonal produce, and market notes aloud.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _StatusCard(title: 'Status', child: Text(_status)),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'Current Area',
            child: Text(
              region == null
                  ? 'No location yet.'
                  : '${region.displayName} · ${region.speedMph.toStringAsFixed(1)} mph',
            ),
          ),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'Last Spoken Guide',
            child: Text(_lastSpokenText.isEmpty ? 'None' : _lastSpokenText),
          ),
          const SizedBox(height: 12),
          _StatusCard(
            title: 'Guide JSON',
            child: Text(
              guide == null
                  ? 'None'
                  : const JsonEncoder.withIndent('  ').convert(guide.toJson()),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isMonitoring ? null : _startMonitoring,
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
          TextButton.icon(
            onPressed: _playSampleGuide,
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
