import 'dart:async';
import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/region_snapshot.dart';

class RegionLocationService {
  RegionLocationService({this.pollInterval = const Duration(minutes: 1)});

  final Duration pollInterval;
  final _regionChanges = StreamController<RegionSnapshot>.broadcast();

  StreamSubscription<Position>? _positionSubscription;
  DateTime? _lastGeocodeAt;
  RegionSnapshot? _lastRegion;

  Stream<RegionSnapshot> get regionChanges => _regionChanges.stream;
  RegionSnapshot? get lastRegion => _lastRegion;

  Future<void> start() async {
    await _ensureLocationReady();
    await stop();
    await checkNow();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: _backgroundLocationSettings(),
        ).listen(
          (position) => unawaited(_handlePosition(position)),
          onError: _regionChanges.addError,
        );
  }

  Future<void> checkNow() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    await _handlePosition(position, force: true);
  }

  Future<void> _handlePosition(Position position, {bool force = false}) async {
    final now = DateTime.now();
    final lastGeocodeAt = _lastGeocodeAt;
    if (!force &&
        lastGeocodeAt != null &&
        now.difference(lastGeocodeAt) < pollInterval) {
      return;
    }

    _lastGeocodeAt = now;
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      return;
    }

    final snapshot = RegionSnapshot.fromPlacemark(
      placemark: placemarks.first,
      position: position,
      recordedAt: now,
    );

    if (_lastRegion?.regionKey == snapshot.regionKey) {
      _lastRegion = snapshot;
      return;
    }

    _lastRegion = snapshot;
    _regionChanges.add(snapshot);
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _regionChanges.close();
  }

  Future<void> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw PermissionDeniedException('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Location permission is permanently denied. Enable it in Settings.',
      );
    }
  }

  LocationSettings _backgroundLocationSettings() {
    if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 500,
        pauseLocationUpdatesAutomatically: false,
        activityType: ActivityType.automotiveNavigation,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }

    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 500,
        intervalDuration: pollInterval,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Driving Guide is active',
          notificationText:
              'Listening for city and county changes during your drive.',
          notificationChannelName: 'Driving Guide Location',
          setOngoing: true,
        ),
      );
    }

    return LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 500,
    );
  }
}
