// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mirk_poc_debug/domain/map/map_screen_services.dart';
import 'package:mirk_poc_debug/infrastructure/location/foreground_location_service.dart';
import 'package:mirk_poc_debug/infrastructure/permissions/location_permission_service.dart';
import 'package:mirk_poc_debug/infrastructure/pmtiles/pmtiles_asset_copier.dart';
import 'package:mirk_poc_debug/infrastructure/sharing/active_log_share_service.dart';
import 'package:mirk_poc_debug/main.dart';
import 'package:mirk_poc_debug/presentation/screens/map_screen.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  testWidgets('routes copied PMTiles path into MapScreen on startup success', (WidgetTester tester) async {
    await tester.pumpWidget(
      MirkPocApp(
        pmtilesPathFuture: Future<String>.value('/support/maps/Fra_Melun.pmtile'),
        permissionService: _grantedPermissionService(),
        locationService: _quietLocationService(),
      ),
    );
    await tester.pump();
    await tester.pump();

    final MapScreen mapScreen = tester.widget<MapScreen>(find.byType(MapScreen));
    expect(mapScreen.services.pmtilesPath, '/support/maps/Fra_Melun.pmtile');
    expect(mapScreen.services.initialDisplayMode, MapDisplayMode.mapOnly);
  });

  testWidgets('renders focused PMTiles copy error on startup failure', (WidgetTester tester) async {
    final Directory tempDir = Directory.systemTemp.createTempSync('mirk_widget_share_log_');
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    final File logFile = File('${tempDir.path}/active_log.jsonl')..writeAsStringSync('log');
    var shareCount = 0;

    await tester.pumpWidget(
      MirkPocApp(
        pmtilesPathLoader: () async => throw const PmtilesAssetCopyException('boom'),
        permissionService: _grantedPermissionService(),
        locationService: _quietLocationService(),
        shareLogService: ActiveLogShareService(
          activeLogPathProvider: () => logFile.path,
          share: (ShareParams params) async {
            shareCount++;
            return const ShareResult('test', ShareResultStatus.success);
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Map data could not open. Restart the app or share the active log for diagnosis.'), findsOneWidget);
    expect(find.byTooltip('Share active log'), findsOneWidget);

    await tester.tap(find.byTooltip('Share active log'));
    await tester.pump();
    expect(shareCount, 1);
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

ForegroundLocationService _quietLocationService() {
  return ForegroundLocationService(positionStreamFactory: (_) => const Stream<Position>.empty());
}
