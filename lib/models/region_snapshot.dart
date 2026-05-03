import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class RegionSnapshot {
  const RegionSnapshot({
    required this.regionKey,
    required this.displayName,
    required this.position,
    required this.recordedAt,
    this.state,
    this.city,
    this.county,
    this.town,
    /// Straight-line distance to nearest bundled city when resolved via [fromOfflinePlace].
    this.offlineNearestDistanceMiles,
  });

  factory RegionSnapshot.fromPlacemark({
    required Placemark placemark,
    required Position position,
    required DateTime recordedAt,
  }) {
    final state = _firstNonEmpty([
      placemark.administrativeArea,
      placemark.country,
    ]);
    final city = _firstNonEmpty([placemark.locality, placemark.subLocality]);
    final county = _firstNonEmpty([placemark.subAdministrativeArea]);
    final town = _firstNonEmpty([
      placemark.subLocality,
      placemark.thoroughfare,
    ]);
    final regionKey = [
      state,
      county,
      city,
    ].where((part) => part != null && part.isNotEmpty).join('|');

    return RegionSnapshot(
      regionKey: regionKey.isEmpty
          ? '${position.latitude.toStringAsFixed(3)},${position.longitude.toStringAsFixed(3)}'
          : regionKey,
      displayName: _displayName(city: city, county: county, state: state),
      position: position,
      recordedAt: recordedAt,
      state: state,
      city: city,
      county: county,
      town: town,
      offlineNearestDistanceMiles: null,
    );
  }

  /// GeoNames offline resolution when platform reverse geocoding fails.
  factory RegionSnapshot.fromOfflinePlace({
    required Position position,
    required DateTime recordedAt,
    required String placeName,
    required String countryCode,
    String? admin1Name,
    String? countyName,
    double? offlineNearestDistanceMiles,
  }) {
    final name = placeName.trim();
    final cc = countryCode.trim().toUpperCase();
    final province = switch (admin1Name?.trim()) {
      final p? when p.isNotEmpty => p,
      _ => null,
    };
    final county = switch (countyName?.trim()) {
      final c? when c.isNotEmpty => c,
      _ => null,
    };

    final regionKeyParts = <String>[];
    if (cc.isNotEmpty) {
      regionKeyParts.add(cc);
    }
    if (province != null) {
      regionKeyParts.add(province);
    }
    if (county != null) {
      regionKeyParts.add(county);
    }
    regionKeyParts.add(name);
    final regionKey = regionKeyParts.join('|');

    final displayParts = <String>[name];
    if (county != null) {
      displayParts.add(county);
    }
    if (province != null) {
      displayParts.add(province);
    }
    if (cc.isNotEmpty) {
      displayParts.add(cc);
    }
    final displayName = displayParts.join(', ');

    return RegionSnapshot(
      regionKey: regionKey,
      displayName: displayName,
      position: position,
      recordedAt: recordedAt,
      state: province,
      county: county,
      city: name,
      offlineNearestDistanceMiles: offlineNearestDistanceMiles,
    );
  }

  /// Place labels unknown after OS geocoding and offline DB both miss.
  /// [displayName] is empty; [regionKey] stays coordinate-based for deduping stream events.
  factory RegionSnapshot.fromCoordinatesUnresolved({
    required Position position,
    required DateTime recordedAt,
  }) {
    final regionKey =
        '${position.latitude.toStringAsFixed(3)},${position.longitude.toStringAsFixed(3)}';
    return RegionSnapshot(
      regionKey: regionKey,
      displayName: '',
      position: position,
      recordedAt: recordedAt,
      offlineNearestDistanceMiles: null,
    );
  }

  final String regionKey;
  final String displayName;
  final Position position;
  final DateTime recordedAt;
  final String? state;
  final String? city;
  final String? county;
  final String? town;
  final double? offlineNearestDistanceMiles;

  double get speedMph {
    final metersPerSecond = position.speed.isFinite && position.speed > 0
        ? position.speed
        : 0.0;
    return metersPerSecond * 2.2369362921;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static String _displayName({
    required String? city,
    required String? county,
    required String? state,
  }) {
    final primary = city ?? county ?? state ?? 'Current area';
    if (state == null || primary == state) {
      return primary;
    }
    return '$primary, $state';
  }
}
