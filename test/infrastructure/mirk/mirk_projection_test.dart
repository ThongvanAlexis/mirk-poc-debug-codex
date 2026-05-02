// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/infrastructure/mirk/mirk_projection.dart';

void main() {
  test('projects viewport corners and centre to screen coordinates', () {
    const viewport = MirkViewportBbox(south: 0.0, west: 20.0, north: 10.0, east: 30.0);
    const size = Size(100, 200);

    expect(MirkProjection.latLonToScreen(lat: 10.0, lon: 20.0, viewport: viewport, size: size), equals(Offset.zero));
    expect(MirkProjection.latLonToScreen(lat: 0.0, lon: 30.0, viewport: viewport, size: size), equals(const Offset(100, 200)));
    expect(MirkProjection.latLonToScreen(lat: 5.0, lon: 25.0, viewport: viewport, size: size), equals(const Offset(50, 100)));
  });

  test('does not clamp points outside the viewport', () {
    const viewport = MirkViewportBbox(south: 0.0, west: 20.0, north: 10.0, east: 30.0);
    const size = Size(100, 200);

    expect(MirkProjection.latLonToScreen(lat: 11.0, lon: 19.0, viewport: viewport, size: size), equals(const Offset(-10, -20)));
  });

  test('guards degenerate spans with Offset.zero', () {
    const viewport = MirkViewportBbox(south: 10.0, west: 20.0, north: 10.0, east: 30.0);

    expect(MirkProjection.latLonToScreen(lat: 10.0, lon: 25.0, viewport: viewport, size: const Size(100, 200)), equals(Offset.zero));
  });

  test('projects antimeridian-wrapped longitudes through the positive span', () {
    const viewport = MirkViewportBbox(south: -10.0, west: 170.0, north: 10.0, east: -170.0);

    expect(MirkProjection.latLonToScreen(lat: 0.0, lon: -175.0, viewport: viewport, size: const Size(200, 200)), equals(const Offset(150, 100)));
  });
}
