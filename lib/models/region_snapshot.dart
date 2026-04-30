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
