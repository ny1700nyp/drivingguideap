import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/region_snapshot.dart';

class RegionLocationService {
  RegionLocationService({this.pollInterval = const Duration(minutes: 1)});

  final Duration pollInterval;
  final _regionChanges = StreamController<RegionSnapshot>.broadcast();

  Timer? _timer;
  RegionSnapshot? _lastRegion;

  Stream<RegionSnapshot> get regionChanges => _regionChanges.stream;
  RegionSnapshot? get lastRegion => _lastRegion;

  Future<void> start() async {
    await _ensureLocationReady();
    await checkNow();
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => checkNow());
  }

  Future<void> checkNow() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
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
      recordedAt: DateTime.now(),
    );

    if (_lastRegion?.regionKey == snapshot.regionKey) {
      _lastRegion = snapshot;
      return;
    }

    _lastRegion = snapshot;
    _regionChanges.add(snapshot);
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
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

    if (permission == LocationPermission.denied) {
      throw PermissionDeniedException('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Location permission is permanently denied. Enable it in Settings.',
      );
    }
  }
}
