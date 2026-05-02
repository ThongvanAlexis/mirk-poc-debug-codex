// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';
import 'package:test/test.dart';

void main() {
  final fixedAt = DateTime.utc(2026, 5, 2, 10);

  RevealDisc disc({double lat = 48.5397, double lon = 2.6553, double radiusMeters = 25.0}) {
    return RevealDisc(id: 'rvd_test', sessionId: 'session_test', lat: lat, lon: lon, radiusMeters: radiusMeters, fixedAtUtc: fixedAt);
  }

  test('measures centre distance with Haversine metres', () {
    expect(disc().distanceMetersTo(48.5407, 2.6553), closeTo(111.2, 0.5));
    expect(disc().distanceMetersTo(48.5397, 2.6553), equals(0.0));
  });

  test('intersects viewport bbox conservatively in metre space', () {
    const melunViewport = MirkViewportBbox(south: 48.53, west: 2.64, north: 48.55, east: 2.67);
    const outsideViewport = MirkViewportBbox(south: 48.56, west: 2.70, north: 48.58, east: 2.73);

    expect(disc().intersectsBbox(melunViewport), isTrue);
    expect(disc().intersectsBbox(outsideViewport), isFalse);
  });

  test('preserves parent antimeridian bbox intersection semantics', () {
    const antimeridianViewport = MirkViewportBbox(south: -1.0, west: 170.0, north: 1.0, east: -170.0);

    expect(disc(lat: 0.0, lon: 179.9, radiusMeters: 1000.0).intersectsBbox(antimeridianViewport), isTrue);
    expect(disc(lat: 0.0, lon: -179.9, radiusMeters: 1000.0).intersectsBbox(antimeridianViewport), isTrue);
    expect(disc(lat: 0.0, lon: 0.0, radiusMeters: 1000.0).intersectsBbox(antimeridianViewport), isFalse);
  });

  test('implements value equality for deterministic cache keys', () {
    final a = disc();
    final b = disc();

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a.toString(), contains('rvd_test'));
  });

  test('asserts a positive reveal radius', () {
    expect(() => disc(radiusMeters: 0.0), throwsA(isA<AssertionError>()));
  });
}
