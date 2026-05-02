// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';
import 'package:mirk_poc_debug/infrastructure/mirk/mirk_projection.dart';
import 'package:mirk_poc_debug/infrastructure/mirk/sdf/revealed_sdf_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const builder = RevealedSdfBuilder();
  final fixedAt = DateTime.utc(2026, 5, 2, 10);
  const viewport = MirkViewportBbox(south: 48.5387, west: 2.6533, north: 48.5407, east: 2.6573);

  RevealDisc disc({double lat = 48.5397, double lon = 2.6553, double radiusMeters = 25.0}) {
    return RevealDisc(id: 'rvd_test', sessionId: 'session_test', lat: lat, lon: lon, radiusMeters: radiusMeters, fixedAtUtc: fixedAt);
  }

  testWidgets('empty disc list builds all-fog midpoint bytes', (tester) async {
    final bytes = await _sdfBytes(discs: const <RevealDisc>[], viewport: viewport);

    expect(bytes.length, equals(kMirkFogSdfResolution * kMirkFogSdfResolution * 4));
    expect(_redAt(bytes, 0, 0), equals(255));
    expect(_redAt(bytes, 128, 128), equals(255));
    expect(_redAt(bytes, 255, 255), equals(255));
  });

  testWidgets('single disc reveals the centre and leaves corners fogged', (tester) async {
    final bytes = await _sdfBytes(discs: <RevealDisc>[disc()], viewport: viewport);

    expect(_redAt(bytes, 128, 128), lessThan(128));
    expect(_redAt(bytes, 0, 0), equals(255));
    expect(_redAt(bytes, 255, 255), equals(255));
  });

  testWidgets('outside disc leaves the viewport all fogged', (tester) async {
    final bytes = await _sdfBytes(discs: <RevealDisc>[disc(lat: 48.58, lon: 2.72)], viewport: viewport);

    expect(_redAt(bytes, 128, 128), equals(255));
    expect(_redAt(bytes, 64, 64), equals(255));
  });

  testWidgets('25 metre Melun disc stays circular in metre space', (tester) async {
    final reveal = disc();
    final bytes = await _sdfBytes(discs: <RevealDisc>[reveal], viewport: viewport);
    final meanLatRad = (viewport.south + viewport.north) * 0.5 * math.pi / 180.0;
    final northLat = reveal.lat + reveal.radiusMeters / kMetersPerDegreeLat;
    final eastLon = reveal.lon + reveal.radiusMeters / (kMetersPerDegreeLat * math.cos(meanLatRad));
    final northPx = MirkProjection.latLonToScreen(lat: northLat, lon: reveal.lon, viewport: viewport, size: const ui.Size(256, 256));
    final eastPx = MirkProjection.latLonToScreen(lat: reveal.lat, lon: eastLon, viewport: viewport, size: const ui.Size(256, 256));
    final northByte = _redAt(bytes, _clampedPixel(northPx.dx), _clampedPixel(northPx.dy));
    final eastByte = _redAt(bytes, _clampedPixel(eastPx.dx), _clampedPixel(eastPx.dy));

    expect(northByte, closeTo(eastByte, 20));
    expect(northByte, closeTo(128, 30));
    expect(eastByte, closeTo(128, 30));
  });

  Future<Uint8List> _sdfBytes({required Iterable<RevealDisc> discs, required MirkViewportBbox viewport}) async {
    final image = await builder.buildFromDiscs(discs: discs, viewport: viewport);
    addTearDown(image.dispose);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List();
  }
}

int _redAt(Uint8List bytes, int x, int y) {
  return bytes[(y * kMirkFogSdfResolution + x) * 4];
}

int _clampedPixel(double value) {
  final rounded = value.round();
  if (rounded < 0) return 0;
  if (rounded >= kMirkFogSdfResolution) return kMirkFogSdfResolution - 1;
  return rounded;
}
