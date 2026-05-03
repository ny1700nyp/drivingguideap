import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/region_snapshot.dart';
import 'offline_city_lookup.dart';

class RegionLocationService {
  RegionLocationService({this.pollInterval = const Duration(minutes: 2)});

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

  Future<RegionSnapshot> currentRegionSnapshot() async {
    await _ensureLocationReady();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    final now = DateTime.now();
    return _snapshotForPosition(position, now);
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
    final snapshot = await _snapshotForPosition(position, now);

    if (_lastRegion?.regionKey == snapshot.regionKey) {
      _lastRegion = snapshot;
      return;
    }

    _lastRegion = snapshot;
    _regionChanges.add(snapshot);
  }

  /// When connectivity suggests a network link, tries OS reverse geocoding
  /// first. Otherwise skips it. If there is still no place name, tries
  /// [OfflineCityLookup]. Final fallback: empty labels (no "Current area").
  Future<RegionSnapshot> _snapshotForPosition(
    Position position,
    DateTime now,
  ) async {
    final online = await _appearsToHaveNetworkInterface();
    if (online) {
      List<Placemark> placemarks;
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (e, stackTrace) {
        debugPrint('placemarkFromCoordinates failed: $e\n$stackTrace');
        placemarks = const [];
      }

      if (placemarks.isNotEmpty) {
        return RegionSnapshot.fromPlacemark(
          placemark: placemarks.first,
          position: position,
          recordedAt: now,
        );
      }
    }

    final offline = await _offlinePlaceFromBundle(position, now);
    if (offline != null) {
      return offline;
    }

    return RegionSnapshot.fromCoordinatesUnresolved(
      position: position,
      recordedAt: now,
    );
  }

  Future<bool> _appearsToHaveNetworkInterface() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (e, stackTrace) {
      debugPrint('Connectivity check failed: $e\n$stackTrace');
      return true;
    }
  }

  Future<RegionSnapshot?> _offlinePlaceFromBundle(
    Position position,
    DateTime now,
  ) async {
    final hit = await OfflineCityLookup.instance.nearest(
      position.latitude,
      position.longitude,
    );
    if (hit == null) {
      return null;
    }
    return RegionSnapshot.fromOfflinePlace(
      position: position,
      recordedAt: now,
      placeName: hit.placeName,
      countryCode: hit.countryCode,
      admin1Name: hit.admin1Name.isEmpty ? null : hit.admin1Name,
      countyName: hit.countyName.isEmpty ? null : hit.countyName,
      offlineNearestDistanceMiles: hit.distanceMiles,
    );
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastGeocodeAt = null;
    _lastRegion = null;
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
          notificationTitle: 'Twingl Road is active',
          notificationText:
              'Listening for city and county changes during your drive.',
          notificationChannelName: 'Twingl Road Location',
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
