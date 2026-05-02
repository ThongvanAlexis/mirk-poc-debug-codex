// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/map/map_screen_services.dart';
import 'package:mirk_poc_debug/presentation/screens/map_screen.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

void main() {
  testWidgets('opens the copied PMTiles path and builds Melun FlutterMap options', (WidgetTester tester) async {
    final _RecordingVectorTileProvider provider = _RecordingVectorTileProvider();
    final List<String> openedPaths = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          services: MapScreenServices(
            pmtilesPath: '/support/maps/Fra_Melun.pmtile',
            tileProviderFactory: (String pmtilesPath) async {
              openedPaths.add(pmtilesPath);
              return provider;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(openedPaths, <String>['/support/maps/Fra_Melun.pmtile']);

    final FlutterMap map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(map.options.initialCenter.latitude, kPocInitialLatitude);
    expect(map.options.initialCenter.longitude, kPocInitialLongitude);
    expect(map.options.initialZoom, kPocInitialZoom);
    expect(map.options.minZoom, kPocMinZoom);
    expect(map.options.maxZoom, kPocMaxZoom);
  });

  testWidgets('wires VectorTileLayer to the protomaps source key and raster mode', (WidgetTester tester) async {
    final _RecordingVectorTileProvider provider = _RecordingVectorTileProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          services: MapScreenServices(pmtilesPath: '/support/maps/Fra_Melun.pmtile', tileProviderFactory: (String pmtilesPath) async => provider),
        ),
      ),
    );
    await tester.pump();

    final VectorTileLayer layer = tester.widget<VectorTileLayer>(find.byType(VectorTileLayer));
    expect(layer.tileProviders.tileProviderBySource, containsPair(kPocTileProviderSourceKey, provider));
    expect(layer.layerMode, VectorTileLayerMode.raster);
    expect(layer.maximumZoom, kPocMaxZoom);
  });

  testWidgets('disposes the opened provider through the lifecycle seam', (WidgetTester tester) async {
    final _RecordingVectorTileProvider provider = _RecordingVectorTileProvider();
    final List<VectorTileProvider> disposedProviders = <VectorTileProvider>[];

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          services: MapScreenServices(
            pmtilesPath: '/support/maps/Fra_Melun.pmtile',
            tileProviderFactory: (String pmtilesPath) async => provider,
            tileProviderDisposer: disposedProviders.add,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());

    expect(disposedProviders, <VectorTileProvider>[provider]);
  });

  testWidgets('rejects remote PMTiles sources before provider construction', (WidgetTester tester) async {
    var providerWasOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          services: MapScreenServices(
            pmtilesPath: 'https://example.com/Fra_Melun.pmtile',
            tileProviderFactory: (String pmtilesPath) async {
              providerWasOpened = true;
              return _RecordingVectorTileProvider();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(providerWasOpened, isFalse);
    expect(find.text('Map open failed'), findsOneWidget);
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
