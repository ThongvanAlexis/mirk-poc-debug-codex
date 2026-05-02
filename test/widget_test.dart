// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/domain/map/map_screen_services.dart';
import 'package:mirk_poc_debug/infrastructure/permissions/location_permission_service.dart';
import 'package:mirk_poc_debug/main.dart';
import 'package:mirk_poc_debug/infrastructure/pmtiles/pmtiles_asset_copier.dart';
import 'package:mirk_poc_debug/presentation/screens/map_screen.dart';

void main() {
  testWidgets('routes copied PMTiles path into MapScreen on startup success', (WidgetTester tester) async {
    await tester.pumpWidget(
      MirkPocApp(pmtilesPathFuture: Future<String>.value('/support/maps/Fra_Melun.pmtile'), permissionService: _grantedPermissionService()),
    );
    await tester.pump();

    final MapScreen mapScreen = tester.widget<MapScreen>(find.byType(MapScreen));
    expect(mapScreen.services.pmtilesPath, '/support/maps/Fra_Melun.pmtile');
    expect(mapScreen.services.initialDisplayMode, MapDisplayMode.mapOnly);
  });

  testWidgets('renders focused PMTiles copy error on startup failure', (WidgetTester tester) async {
    await tester.pumpWidget(
      MirkPocApp(pmtilesPathFuture: Future<String>.error(const PmtilesAssetCopyException('boom')), permissionService: _grantedPermissionService()),
    );
    await tester.pump();

    expect(find.text('Map data could not open. Restart the app or share the active log for diagnosis.'), findsOneWidget);
  });

  test('main bootstraps the file logger before runApp and registers lifecycle flushing', () {
    final String source = File('lib/main.dart').readAsStringSync();
    final int bindingIndex = source.indexOf('WidgetsFlutterBinding.ensureInitialized()');
    final int bootstrapIndex = source.indexOf('await FileLogger.bootstrap()');
    final int observerIndex = source.indexOf('WidgetsBinding.instance.addObserver(FileLoggerLifecycleObserver())');
    final int runAppIndex = source.indexOf('runApp(');

    expect(bindingIndex, greaterThanOrEqualTo(0));
    expect(bootstrapIndex, greaterThan(bindingIndex));
    expect(observerIndex, greaterThan(bootstrapIndex));
    expect(runAppIndex, greaterThan(observerIndex));
    expect(source, contains("developer.log('FileLogger bootstrap failed; continuing without file logging'"));
  });

  testWidgets('starts with foreground permission rationale before map bootstrap', (WidgetTester tester) async {
    var mapLoaderStarted = false;

    await tester.pumpWidget(
      MirkPocApp(
        pmtilesPathLoader: () {
          mapLoaderStarted = true;
          return Future<String>.value('/support/maps/Fra_Melun.pmtile');
        },
        permissionService: LocationPermissionService(
          statusReader: () async => LocationPermissionState.denied,
          requestWhenInUse: () async => LocationPermissionState.denied,
          openSettings: () async => true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Enable foreground location'), findsOneWidget);
    expect(find.text('Enable Location'), findsOneWidget);
    expect(mapLoaderStarted, isFalse);
  });
}

LocationPermissionService _grantedPermissionService() {
  return LocationPermissionService(
    statusReader: () async => LocationPermissionState.granted,
    requestWhenInUse: () async => LocationPermissionState.granted,
    openSettings: () async => true,
  );
}
