// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:math' as math;
import 'dart:ui' show Path, PathOperation, Rect, Size;

import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';
import 'package:mirk_poc_debug/infrastructure/mirk/mirk_projection.dart';

/// Builds `viewport rect - union(reveal disc circles)` for the fog shader clip.
Path buildViewportFogClipPathFromDiscs({required Iterable<RevealDisc> discs, required MirkViewportBbox viewport, required Size canvasSize}) {
  final viewportRect = Path()..addRect(Rect.fromLTWH(0.0, 0.0, canvasSize.width, canvasSize.height));

  final dLat = viewport.north - viewport.south;
  final dLon = viewport.longitudeSpanDegrees;
  if (dLat <= 0.0 || dLon <= 0.0 || canvasSize.width <= 0.0 || canvasSize.height <= 0.0) return viewportRect;

  final meanLatRad = (viewport.south + viewport.north) * 0.5 * math.pi / 180.0;
  final metersPerPixelY = (dLat * kMetersPerDegreeLat) / canvasSize.height;
  final metersPerPixelX = (dLon * kMetersPerDegreeLat * math.cos(meanLatRad)) / canvasSize.width;
  if (metersPerPixelX <= 0.0 || metersPerPixelY <= 0.0) return viewportRect;

  final metersPerPixel = math.sqrt(metersPerPixelX * metersPerPixelY);
  final holesPath = Path();
  var hasAnyHole = false;
  for (final disc in discs) {
    if (!disc.intersectsBbox(viewport)) continue;
    final centre = MirkProjection.latLonToScreen(lat: disc.lat, lon: disc.lon, viewport: viewport, size: canvasSize);
    final radiusPx = disc.radiusMeters / metersPerPixel;
    if (radiusPx <= 0.0) continue;
    holesPath.addOval(Rect.fromCircle(center: centre, radius: radiusPx));
    hasAnyHole = true;
  }

  if (!hasAnyHole) return viewportRect;
  return Path.combine(PathOperation.difference, viewportRect, holesPath);
}
