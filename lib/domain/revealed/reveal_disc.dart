// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:math' as math;

import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';

/// Immutable continuous reveal geometry copied from MirkFall's fog pipeline.
class RevealDisc {
  const RevealDisc({required this.id, required this.sessionId, required this.lat, required this.lon, required this.radiusMeters, required this.fixedAtUtc})
    : assert(radiusMeters > 0.0, 'RevealDisc: radiusMeters must be > 0');

  final String id;
  final String sessionId;
  final double lat;
  final double lon;
  final double radiusMeters;
  final DateTime fixedAtUtc;

  double distanceMetersTo(double otherLat, double otherLon) {
    return _haversineMeters(lat, lon, otherLat, otherLon);
  }

  /// Returns true when this disc's conservative lat/lon extent overlaps [bbox].
  ///
  /// False positives are acceptable because the SDF builder later computes the
  /// exact metric distance for each sampled pixel. False negatives would drop
  /// real reveal geometry, so the longitude extent deliberately handles the
  /// parent antimeridian convention.
  bool intersectsBbox(MirkViewportBbox bbox) {
    final latDegPerMeter = 1.0 / kMetersPerDegreeLat;
    final clampedLatRad = _toRad(_clampDouble(lat, -_polarLatClampDeg, _polarLatClampDeg));
    final lonDegPerMeter = 1.0 / (kMetersPerDegreeLat * math.cos(clampedLatRad));

    final minLat = lat - radiusMeters * latDegPerMeter;
    final maxLat = lat + radiusMeters * latDegPerMeter;
    final minLon = lon - radiusMeters * lonDegPerMeter;
    final maxLon = lon + radiusMeters * lonDegPerMeter;

    if (maxLat < bbox.south || minLat > bbox.north) return false;

    if (!bbox.crossesAntimeridian) {
      return !(maxLon < bbox.west || minLon > bbox.east);
    }

    final overlapsEastHalf = !(maxLon < bbox.west || minLon > _maxLonDeg);
    final overlapsWestHalf = !(maxLon < _minLonDeg || minLon > bbox.east);
    return overlapsEastHalf || overlapsWestHalf;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevealDisc &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.lat == lat &&
        other.lon == lon &&
        other.radiusMeters == radiusMeters &&
        other.fixedAtUtc == fixedAtUtc;
  }

  @override
  int get hashCode => Object.hash(id, sessionId, lat, lon, radiusMeters, fixedAtUtc);

  @override
  String toString() {
    return 'RevealDisc(id: $id, sessionId: $sessionId, lat: $lat, lon: $lon, radiusMeters: $radiusMeters, fixedAtUtc: $fixedAtUtc)';
  }
}

const double _degreesPerHalfTurn = 180.0;
const double _maxLonDeg = 180.0;
const double _minLonDeg = -180.0;
const double _polarLatClampDeg = 85.0511287798066;

double _toRad(double deg) => deg * math.pi / _degreesPerHalfTurn;

double _clampDouble(double value, double low, double high) {
  if (value < low) return low;
  if (value > high) return high;
  return value;
}

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final l1 = _toRad(lat1);
  final l2 = _toRad(lat2);
  final a = math.sin(dLat / 2.0) * math.sin(dLat / 2.0) + math.sin(dLon / 2.0) * math.sin(dLon / 2.0) * math.cos(l1) * math.cos(l2);
  final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
  return kEarthRadiusMeters * c;
}
