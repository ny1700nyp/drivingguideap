import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// When guiding is active, periodically checks whether the device stays within
/// [stationaryRadiusMeters] of an anchor point for [stationaryDuration].
/// If so, invokes [onIdleTimeout] once until [stop] / [start].
class StationaryPauseMonitor {
  StationaryPauseMonitor({
    this.stationaryRadiusMeters = 1609.34,
    this.stationaryDuration = const Duration(minutes: 30),
    this.pollInterval = const Duration(minutes: 1),
  });

  /// About one statute mile.
  final double stationaryRadiusMeters;
  final Duration stationaryDuration;
  final Duration pollInterval;

  Timer? _timer;
  Position? _anchor;
  DateTime? _stationarySince;
  bool _armed = false;
  bool _fired = false;

  void start({required Future<void> Function() onIdleTimeout}) {
    stop();
    _armed = true;
    _fired = false;
    _anchor = null;
    _stationarySince = null;
    unawaited(_tick(onIdleTimeout));
    _timer = Timer.periodic(pollInterval, (_) {
      unawaited(_tick(onIdleTimeout));
    });
  }

  Future<void> _tick(Future<void> Function() onIdleTimeout) async {
    if (!_armed || _fired) {
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 30),
        ),
      );
      if (!_armed || _fired) {
        return;
      }
      _evaluatePosition(pos, onIdleTimeout);
    } catch (e, st) {
      debugPrint('StationaryPauseMonitor: $e\n$st');
    }
  }

  void _evaluatePosition(
    Position pos,
    Future<void> Function() onIdleTimeout,
  ) {
    if (!_armed || _fired) {
      return;
    }
    final anchor = _anchor;
    if (anchor == null) {
      _anchor = pos;
      _stationarySince = DateTime.now();
      return;
    }
    final d = Geolocator.distanceBetween(
      anchor.latitude,
      anchor.longitude,
      pos.latitude,
      pos.longitude,
    );
    if (d > stationaryRadiusMeters) {
      _anchor = pos;
      _stationarySince = DateTime.now();
      return;
    }
    final since = _stationarySince;
    if (since != null &&
        DateTime.now().difference(since) >= stationaryDuration) {
      _fired = true;
      unawaited(onIdleTimeout());
    }
  }

  void stop() {
    _armed = false;
    _timer?.cancel();
    _timer = null;
    _anchor = null;
    _stationarySince = null;
    _fired = false;
  }
}
