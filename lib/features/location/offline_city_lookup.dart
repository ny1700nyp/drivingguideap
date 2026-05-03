import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kdtree/kdtree.dart';

class _CityRow {
  const _CityRow({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
    required this.admin1Code,
    required this.admin2Code,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String countryCode;
  final String admin1Code;

  /// GeoNames admin2 code (e.g. US county FIPS-style suffix); may be empty.
  final String admin2Code;
}

/// Nearest GeoNames city from bundled [cities15000] + admin1/admin2 names.
class OfflineCityLookup {
  OfflineCityLookup._();
  static final OfflineCityLookup instance = OfflineCityLookup._();

  static const _citiesAsset = 'assets/geodata/cities15000.txt';
  static const _admin1Asset = 'assets/geodata/admin1CodesASCII.txt';
  static const _admin2Asset = 'assets/geodata/admin2Codes.txt';

  List<_CityRow>? _rows;
  KDTree? _kdTree;
  Map<String, String>? _admin1NameByKey;
  Map<String, String>? _admin2NameByKey;
  bool _loadFailed = false;
  Future<void>? _loading;

  /// Warm parse + k-d tree build (first run can take a moment).
  Future<void> preload() => _ensureLoaded();

  Future<void> _ensureLoaded() async {
    if (_rows != null || _loadFailed) {
      return;
    }
    _loading ??= _loadInternal();
    await _loading;
  }

  Future<void> _loadInternal() async {
    try {
      final citiesRaw = await rootBundle.loadString(_citiesAsset);
      final admin1Raw = await rootBundle.loadString(_admin1Asset);
      final admin2Raw = await rootBundle.loadString(_admin2Asset);

      final rows = _parseCities15000(citiesRaw);
      final admin1Map = _parseAdmin1Codes(admin1Raw);
      final admin2Map = _parseAdminTabCodes(admin2Raw);

      final points = <Map<String, dynamic>>[];
      for (var i = 0; i < rows.length; i++) {
        final r = rows[i];
        points.add({
          'latitude': r.latitude,
          'longitude': r.longitude,
          '_i': i,
        });
      }

      _rows = rows;
      _admin1NameByKey = admin1Map;
      _admin2NameByKey = admin2Map;
      _kdTree = KDTree(points, _treeDistance, ['latitude', 'longitude']);
    } catch (e, stackTrace) {
      _loadFailed = true;
      debugPrint(
        'OfflineCityLookup: failed to load offline geodata: $e\n$stackTrace',
      );
    }
  }

  /// Haversine distance in miles (matches geocoder_offline / GeoNames tooling).
  static double _calculateDistanceMiles(
    double latStart,
    double lonStart,
    double latEnd,
    double lonEnd,
  ) {
    const earthMi = 3958.8;
    final dLat = _deg2rad(latEnd - latStart);
    final dLon = _deg2rad(lonEnd - lonStart);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(latStart)) *
            cos(_deg2rad(latEnd)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthMi * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  static double _treeDistance(dynamic location1, dynamic location2) {
    final lat1 = location1['latitude'] as double;
    final lon1 = location1['longitude'] as double;
    final lat2 = location2['latitude'] as double;
    final lon2 = location2['longitude'] as double;
    return _calculateDistanceMiles(lat1, lon1, lat2, lon2);
  }

  /// Returns null when data failed to load, no hit, or nearest city is farther
  /// than [maxDistanceMiles].
  Future<
      ({
        String placeName,
        String countryCode,
        String admin1Name,
        String countyName,
        double distanceMiles,
      })?> nearest(
    double latitude,
    double longitude, {
    double maxDistanceMiles = 100,
  }) async {
    await _ensureLoaded();
    final tree = _kdTree;
    final rows = _rows;
    final admin1Map = _admin1NameByKey;
    final admin2Map = _admin2NameByKey;
    if (tree == null || rows == null || admin1Map == null || admin2Map == null) {
      return null;
    }

    try {
      final hits = tree.nearest({
        'latitude': latitude,
        'longitude': longitude,
      }, 1);
      if (hits.isEmpty) {
        return null;
      }
      final pair = hits.first as List<dynamic>;
      final obj = pair[0] as Map<String, dynamic>;
      final distance = pair[1] as double;
      if (distance > maxDistanceMiles) {
        return null;
      }

      final ix = obj['_i'] as int;
      final row = rows[ix];
      final name = row.name.trim();
      if (name.isEmpty) {
        return null;
      }

      final cc = row.countryCode.trim().toUpperCase();
      final a1 = row.admin1Code.trim();
      final a2 = row.admin2Code.trim();

      final adminKey = '$cc.$a1';
      final admin1Name = (admin1Map[adminKey] ?? '').trim();

      var countyName = '';
      if (a2.isNotEmpty && a1.isNotEmpty && cc.isNotEmpty) {
        final admin2Key = '$cc.$a1.$a2';
        countyName = (admin2Map[admin2Key] ?? '').trim();
      }

      return (
        placeName: name,
        countryCode: cc,
        admin1Name: admin1Name,
        countyName: countyName,
        distanceMiles: distance,
      );
    } catch (e, stackTrace) {
      debugPrint('OfflineCityLookup.search failed: $e\n$stackTrace');
      return null;
    }
  }

  static List<_CityRow> _parseCities15000(String raw) {
    final lines = const LineSplitter().convert(raw);
    if (lines.isEmpty) {
      return [];
    }

    final header = lines.first.split('\t');
    int idx(String col) {
      final i = header.indexOf(col);
      if (i < 0) {
        throw StateError('Missing "$col" column in cities15000 header');
      }
      return i;
    }

    final iName = idx('name');
    final iLat = idx('latitude');
    final iLon = idx('longitude');
    final iCc = idx('country code');
    final iAdm1 = idx('admin1 code');
    final iAdm2 = idx('admin2 code');

    final minCols = [iName, iLat, iLon, iCc, iAdm1, iAdm2].reduce(max) + 1;

    final out = <_CityRow>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        continue;
      }
      final cols = line.split('\t');
      if (cols.length < minCols) {
        continue;
      }

      final name = cols[iName].trim();
      final lat = double.tryParse(cols[iLat].trim());
      final lon = double.tryParse(cols[iLon].trim());
      final cc = cols[iCc].trim();
      final a1 = cols[iAdm1].trim();
      final a2 = cols[iAdm2].trim();

      if (name.isEmpty || lat == null || lon == null || cc.isEmpty) {
        continue;
      }

      out.add(
        _CityRow(
          name: name,
          latitude: lat,
          longitude: lon,
          countryCode: cc,
          admin1Code: a1,
          admin2Code: a2,
        ),
      );
    }
    return out;
  }

  /// admin2Codes.txt — tab-separated `CODE\tName\tascii\tgeonameid`.
  static Map<String, String> _parseAdminTabCodes(String raw) {
    final map = <String, String>{};
    for (final line in const LineSplitter().convert(raw)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      if (!trimmed.contains('\t')) {
        continue;
      }
      final parts = trimmed.split('\t');
      if (parts.length >= 2) {
        final code = parts[0].trim();
        final name = parts[1].trim();
        if (code.isNotEmpty && name.isNotEmpty) {
          map[code] = name;
        }
      }
    }
    return map;
  }

  static Map<String, String> _parseAdmin1Codes(String raw) {
    final map = <String, String>{};
    for (final line in const LineSplitter().convert(raw)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      if (trimmed.contains('\t')) {
        final parts = trimmed.split('\t');
        if (parts.length >= 2) {
          final code = parts[0].trim();
          final name = parts[1].trim();
          if (code.isNotEmpty && name.isNotEmpty) {
            map[code] = name;
          }
        }
        continue;
      }

      final parsed = _parseSpaceSeparatedAdminLine(trimmed);
      if (parsed != null) {
        map[parsed.$1] = parsed.$2;
      }
    }
    return map;
  }

  /// Handles corrupted dumps where tabs became spaces (still GeoNames order).
  static (String, String)? _parseSpaceSeparatedAdminLine(String line) {
    final codeMatch =
        RegExp(r'^([A-Za-z]{2}\.[A-Za-z0-9_.-]+)\s+').firstMatch(line);
    if (codeMatch == null) {
      return null;
    }
    final code = codeMatch.group(1)!;
    final rest = line.substring(codeMatch.end);
    final idMatch = RegExp(r'\s(\d+)\s*$').firstMatch(rest);
    if (idMatch == null) {
      return null;
    }
    final namesPart =
        rest.substring(0, rest.length - idMatch.group(0)!.length).trim();
    final label = _splitDuplicatePlaceName(namesPart);
    if (label.isEmpty) {
      return null;
    }
    return (code, label);
  }

  /// GeoNames stores English name + ASCII name; often duplicated word-for-word.
  static String _splitDuplicatePlaceName(String namesPart) {
    final tokens = namesPart.split(RegExp(r'\s+'));
    if (tokens.isEmpty) {
      return namesPart.trim();
    }
    final n = tokens.length;
    for (var k = n ~/ 2; k >= 1; k--) {
      if (n >= 2 * k) {
        final a = tokens.sublist(0, k).join(' ');
        final b = tokens.sublist(k, 2 * k).join(' ');
        if (a.toLowerCase() == b.toLowerCase()) {
          return a;
        }
      }
    }
    return tokens.take((n + 1) ~/ 2).join(' ');
  }
}
