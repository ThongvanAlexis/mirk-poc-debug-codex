// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:test/test.dart';

void main() {
  test('stores immutable south west north east bounds', () {
    const bbox = MirkViewportBbox(south: 48.48, west: 2.55, north: 48.60, east: 2.78);

    expect(bbox.south, equals(48.48));
    expect(bbox.west, equals(2.55));
    expect(bbox.north, equals(48.60));
    expect(bbox.east, equals(2.78));
    expect(bbox.crossesAntimeridian, isFalse);
    expect(bbox.longitudeSpanDegrees, closeTo(0.23, 1e-12));
  });

  test('supports antimeridian viewport wrap with explicit span semantics', () {
    const bbox = MirkViewportBbox(south: -1.0, west: 170.0, north: 1.0, east: -170.0);

    expect(bbox.crossesAntimeridian, isTrue);
    expect(bbox.longitudeSpanDegrees, equals(20.0));
    expect(bbox.normalizeLongitudeForProjection(179.0), equals(179.0));
    expect(bbox.normalizeLongitudeForProjection(-179.0), equals(181.0));
  });

  test('implements value equality', () {
    const a = MirkViewportBbox(south: 1.0, west: 2.0, north: 3.0, east: 4.0);
    const b = MirkViewportBbox(south: 1.0, west: 2.0, north: 3.0, east: 4.0);

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a.toString(), contains('south: 1.0'));
  });

  test('asserts ordered latitude and valid antimeridian shape', () {
    MirkViewportBbox bbox({required double south, required double west, required double north, required double east}) {
      return MirkViewportBbox(south: south, west: west, north: north, east: east);
    }

    expect(() => bbox(south: 2.0, west: 0.0, north: 1.0, east: 1.0), throwsA(isA<AssertionError>()));
    expect(() => bbox(south: -1.0, west: -170.0, north: 1.0, east: 170.0), returnsNormally);
    expect(() => bbox(south: -1.0, west: -170.0, north: 1.0, east: -175.0), throwsA(isA<AssertionError>()));
  });
}
