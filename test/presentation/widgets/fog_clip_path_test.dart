// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';
import 'package:mirk_poc_debug/infrastructure/mirk/mirk_projection.dart';
import 'package:mirk_poc_debug/presentation/widgets/fog_clip_path.dart';

void main() {
  final fixedAt = DateTime.utc(2026, 5, 2, 10);
  const viewport = MirkViewportBbox(south: 48.5387, west: 2.6533, north: 48.5407, east: 2.6573);
  const canvasSize = Size(200, 200);

  RevealDisc disc({double lat = 48.5397, double lon = 2.6553, double radiusMeters = 25.0}) {
    return RevealDisc(id: 'rvd_test', sessionId: 'session_test', lat: lat, lon: lon, radiusMeters: radiusMeters, fixedAtUtc: fixedAt);
  }

  test('empty disc list leaves the whole viewport fogged', () {
    final path = buildViewportFogClipPathFromDiscs(discs: const <RevealDisc>[], viewport: viewport, canvasSize: canvasSize);

    expect(path.contains(const Offset(0, 0)), isTrue);
    expect(path.contains(const Offset(100, 100)), isTrue);
  });

  test('subtracts reveal-disc circles from the viewport rect', () {
    final path = buildViewportFogClipPathFromDiscs(discs: <RevealDisc>[disc()], viewport: viewport, canvasSize: canvasSize);

    expect(path.contains(const Offset(0, 0)), isTrue);
    expect(path.contains(const Offset(100, 100)), isFalse);
  });

  test('clip radius agrees with the SDF metre-space projection convention', () {
    final reveal = disc();
    final path = buildViewportFogClipPathFromDiscs(discs: <RevealDisc>[reveal], viewport: viewport, canvasSize: canvasSize);
    final centre = MirkProjection.latLonToScreen(lat: reveal.lat, lon: reveal.lon, viewport: viewport, size: canvasSize);
    final radiusPx = reveal.radiusMeters / _metresPerPixel(viewport, canvasSize);

    expect(path.contains(centre), isFalse);
    expect(path.contains(centre + Offset(radiusPx + 2.0, 0.0)), isTrue);
  });
}

double _metresPerPixel(MirkViewportBbox viewport, Size size) {
  final meanLatRad = (viewport.south + viewport.north) * 0.5 * math.pi / 180.0;
  final metersPerPixelY = ((viewport.north - viewport.south) * kMetersPerDegreeLat) / size.height;
  final metersPerPixelX = (viewport.longitudeSpanDegrees * kMetersPerDegreeLat * math.cos(meanLatRad)) / size.width;
  return math.sqrt(metersPerPixelX * metersPerPixelY);
}
