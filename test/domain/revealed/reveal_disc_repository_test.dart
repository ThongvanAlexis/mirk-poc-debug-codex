// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/location/geo_fix.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc_repository.dart';
import 'package:test/test.dart';

void main() {
  final fixedAt = DateTime.utc(2026, 5, 2, 11);

  RevealDisc seed(String id) {
    return RevealDisc(id: id, sessionId: 'seed', lat: kPocInitialLatitude, lon: kPocInitialLongitude, radiusMeters: kPocRevealDiscRadiusMeters, fixedAtUtc: fixedAt);
  }

  GeoFix fix({double latitude = 48.5401, double longitude = 2.6561}) {
    return GeoFix(latitude: latitude, longitude: longitude, fixedAtUtc: fixedAt);
  }

  test('starts with seeded Melun reveal discs by default', () {
    final repository = RevealDiscRepository();

    final snapshot = repository.snapshot();

    expect(snapshot, isNotEmpty);
    expect(snapshot.every((disc) => disc.radiusMeters == kPocRevealDiscRadiusMeters), isTrue);
    expect(snapshot.any((disc) => disc.lat == kPocInitialLatitude && disc.lon == kPocInitialLongitude), isTrue);
  });

  test('snapshot is an immutable defensive copy', () {
    final repository = RevealDiscRepository(seedDiscs: <RevealDisc>[seed('seed_a')]);
    final snapshot = repository.snapshot();

    repository.appendFix(fix());

    expect(snapshot, hasLength(1));
    expect(() => snapshot.add(seed('should_not_mutate')), throwsUnsupportedError);
    expect(repository.snapshot(), hasLength(2));
  });

  test('appendFix accepts one finite fix as one 25 m reveal disc and notifies once', () {
    final repository = RevealDiscRepository(seedDiscs: const <RevealDisc>[]);
    var notifications = 0;
    repository.addListener(() => notifications++);

    final accepted = repository.appendFix(fix());

    expect(accepted, isTrue);
    expect(notifications, equals(1));
    final snapshot = repository.snapshot();
    expect(snapshot, hasLength(1));
    expect(snapshot.single.lat, equals(48.5401));
    expect(snapshot.single.lon, equals(2.6561));
    expect(snapshot.single.radiusMeters, equals(kPocRevealDiscRadiusMeters));
    expect(snapshot.single.fixedAtUtc, equals(fixedAt));
  });

  test('appendFix rejects non-finite and out-of-range fixes without notifying', () {
    final repository = RevealDiscRepository(seedDiscs: const <RevealDisc>[]);
    var notifications = 0;
    repository.addListener(() => notifications++);

    expect(repository.appendFix(fix(latitude: double.nan)), isFalse);
    expect(repository.appendFix(fix(longitude: double.infinity)), isFalse);
    expect(repository.appendFix(fix(latitude: 91.0)), isFalse);
    expect(repository.appendFix(fix(longitude: 181.0)), isFalse);

    expect(notifications, equals(0));
    expect(repository.snapshot(), isEmpty);
  });
}
