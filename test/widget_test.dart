// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/domain/map/map_screen_services.dart';
import 'package:mirk_poc_debug/main.dart';
import 'package:mirk_poc_debug/infrastructure/pmtiles/pmtiles_asset_copier.dart';
import 'package:mirk_poc_debug/presentation/screens/map_screen.dart';

void main() {
  testWidgets('routes copied PMTiles path into MapScreen on startup success', (WidgetTester tester) async {
    await tester.pumpWidget(MirkPocApp(pmtilesPathFuture: Future<String>.value('/support/maps/Fra_Melun.pmtile')));
    await tester.pump();

    final MapScreen mapScreen = tester.widget<MapScreen>(find.byType(MapScreen));
    expect(mapScreen.services.pmtilesPath, '/support/maps/Fra_Melun.pmtile');
    expect(mapScreen.services.initialDisplayMode, MapDisplayMode.mapOnly);
  });

  testWidgets('renders focused PMTiles copy error on startup failure', (WidgetTester tester) async {
    await tester.pumpWidget(MirkPocApp(pmtilesPathFuture: Future<String>.error(const PmtilesAssetCopyException('boom'))));
    await tester.pump();

    expect(find.text('PMTiles copy failed'), findsOneWidget);
  });
}
