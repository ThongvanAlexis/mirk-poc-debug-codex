// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:ui' show Offset, Size;

import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';

/// Projects lat/lon coordinates into the current fog canvas coordinate space.
class MirkProjection {
  const MirkProjection._();

  static Offset latLonToScreen({required double lat, required double lon, required MirkViewportBbox viewport, required Size size}) {
    final dLat = viewport.north - viewport.south;
    final dLon = viewport.longitudeSpanDegrees;
    if (dLat == 0.0 || dLon == 0.0) return Offset.zero;

    final projectionLon = viewport.normalizeLongitudeForProjection(lon);
    final x = ((projectionLon - viewport.projectionWest) / dLon) * size.width;
    final y = ((viewport.north - lat) / dLat) * size.height;
    return Offset(x, y);
  }
}
