// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/domain/map/map_screen_services.dart';
import 'package:mirk_poc_debug/presentation/widgets/map_mode_toggle.dart';

void main() {
  testWidgets('renders compact map and fog segments with the selected mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapModeToggle(mode: MapDisplayMode.mapOnly, onChanged: (MapDisplayMode mode) {}),
        ),
      ),
    );

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Fog'), findsOneWidget);

    final SegmentedButton<MapDisplayMode> button = tester.widget<SegmentedButton<MapDisplayMode>>(find.byType(SegmentedButton<MapDisplayMode>));
    expect(button.selected, <MapDisplayMode>{MapDisplayMode.mapOnly});
    expect(button.showSelectedIcon, isFalse);
  });

  testWidgets('reports mode changes without changing map ownership', (WidgetTester tester) async {
    final List<MapDisplayMode> changes = <MapDisplayMode>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapModeToggle(mode: MapDisplayMode.mapOnly, onChanged: changes.add),
        ),
      ),
    );

    await tester.tap(find.text('Fog'));

    expect(changes, <MapDisplayMode>[MapDisplayMode.mapWithFog]);
  });
}
