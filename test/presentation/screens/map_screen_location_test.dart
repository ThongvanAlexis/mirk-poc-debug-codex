// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/location/geo_fix.dart';
import 'package:mirk_poc_debug/domain/map/map_screen_services.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc_repository.dart';
import 'package:mirk_poc_debug/presentation/screens/map_screen.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

void main() {
  testWidgets('injected latest-fix stream appends accepted fixes without a permission prompt', (WidgetTester tester) async {
    final latestFixes = StreamController<GeoFix>();
    final repository = RevealDiscRepository(seedDiscs: const <RevealDisc>[]);
    final provider = _RecordingVectorTileProvider();
    final fixedAt = DateTime.utc(2026, 5, 2, 11, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          services: MapScreenServices(
            pmtilesPath: '/support/maps/Fra_Melun.pmtile',
            initialDisplayMode: MapDisplayMode.mapOnly,
            latestFixStream: latestFixes.stream,
            revealDiscRepository: repository,
            tileProviderFactory: (String pmtilesPath) async => provider,
          ),
        ),
      ),
    );
    await tester.pump();

    latestFixes.add(GeoFix(latitude: 48.5402, longitude: 2.6562, fixedAtUtc: fixedAt));
    await tester.pump();

    expect(repository.snapshot(), hasLength(1));
    expect(repository.snapshot().single.radiusMeters, equals(kPocRevealDiscRadiusMeters));
    expect(repository.snapshot().single.lat, equals(48.5402));
    expect(repository.snapshot().single.lon, equals(2.6562));

    await latestFixes.close();
  });

  testWidgets('injected initial latest fix is accepted once for testable state', (WidgetTester tester) async {
    final repository = RevealDiscRepository(seedDiscs: const <RevealDisc>[]);
    final provider = _RecordingVectorTileProvider();
    final fixedAt = DateTime.utc(2026, 5, 2, 11, 35);

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          services: MapScreenServices(
            pmtilesPath: '/support/maps/Fra_Melun.pmtile',
            initialDisplayMode: MapDisplayMode.mapOnly,
            initialLatestFix: GeoFix(latitude: 48.541, longitude: 2.657, fixedAtUtc: fixedAt),
            revealDiscRepository: repository,
            tileProviderFactory: (String pmtilesPath) async => provider,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(repository.snapshot(), hasLength(1));
    expect(repository.snapshot().single.lat, equals(48.541));
    expect(repository.snapshot().single.lon, equals(2.657));
  });
}

class _RecordingVectorTileProvider extends VectorTileProvider {
  final Completer<Uint8List> _tileCompleter = Completer<Uint8List>();

  @override
  int get maximumZoom => 18;

  @override
  int get minimumZoom => 0;

  @override
  Future<Uint8List> provide(TileIdentity tile) => _tileCompleter.future;
}
