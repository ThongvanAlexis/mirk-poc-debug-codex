// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/main.dart';
import 'package:mirk_poc_debug/infrastructure/pmtiles/pmtiles_asset_copier.dart';

void main() {
  testWidgets('renders copied PMTiles path on startup success', (WidgetTester tester) async {
    await tester.pumpWidget(MirkPocApp(pmtilesPathFuture: Future<String>.value('/support/maps/Fra_Melun.pmtile')));
    await tester.pump();

    expect(find.text('PMTiles ready'), findsOneWidget);
    expect(find.text('/support/maps/Fra_Melun.pmtile'), findsOneWidget);
  });

  testWidgets('renders focused PMTiles copy error on startup failure', (WidgetTester tester) async {
    await tester.pumpWidget(MirkPocApp(pmtilesPathFuture: Future<String>.error(const PmtilesAssetCopyException('boom'))));
    await tester.pump();

    expect(find.text('PMTiles copy failed'), findsOneWidget);
  });
}
