// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/infrastructure/permissions/location_permission_service.dart';
import 'package:mirk_poc_debug/presentation/screens/permission_gate_screen.dart';

void main() {
  testWidgets('shows rationale before the user-triggered permission request', (WidgetTester tester) async {
    var requestCount = 0;
    final service = LocationPermissionService(
      statusReader: () async => LocationPermissionState.denied,
      requestWhenInUse: () async {
        requestCount++;
        return LocationPermissionState.granted;
      },
      openSettings: () async => true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PermissionGateScreen(permissionService: service, grantedBuilder: (_) => const Text('map ready')),
      ),
    );
    await tester.pump();

    expect(find.text('Enable foreground location'), findsOneWidget);
    expect(find.text('Enable Location'), findsOneWidget);
    expect(requestCount, 0);

    await tester.tap(find.text('Enable Location'));
    await tester.pump();

    expect(requestCount, 1);
    expect(find.text('map ready'), findsOneWidget);
  });

  testWidgets('denied permission shows settings and recheck recovery', (WidgetTester tester) async {
    var settingsCount = 0;
    final service = LocationPermissionService(
      statusReader: () async => LocationPermissionState.denied,
      requestWhenInUse: () async => LocationPermissionState.denied,
      openSettings: () async {
        settingsCount++;
        return true;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PermissionGateScreen(permissionService: service, grantedBuilder: (_) => const Text('map ready')),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Enable Location'));
    await tester.pump();

    expect(find.text('Location is disabled'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
    expect(find.text('Check Permission'), findsOneWidget);

    await tester.tap(find.text('Open Settings'));
    await tester.pump();

    expect(settingsCount, 1);
  });
}
