// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:latlong2/latlong.dart';

/// Small location value at the Phase 2 boundary.
///
/// Phase 3 can adapt foreground GPS positions into this type without making
/// widgets depend directly on a permission/location plugin.
class GeoFix {
  const GeoFix({required this.latitude, required this.longitude, required this.fixedAtUtc});

  final double latitude;
  final double longitude;
  final DateTime fixedAtUtc;

  bool get hasFiniteCoordinates => latitude.isFinite && longitude.isFinite;

  bool get isInCoordinateRange => latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0;

  bool get isAcceptedForReveal => hasFiniteCoordinates && isInCoordinateRange;

  LatLng get latLng => LatLng(latitude, longitude);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoFix && other.latitude == latitude && other.longitude == longitude && other.fixedAtUtc == fixedAtUtc;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, fixedAtUtc);

  @override
  String toString() => 'GeoFix(latitude: $latitude, longitude: $longitude, fixedAtUtc: $fixedAtUtc)';
}
