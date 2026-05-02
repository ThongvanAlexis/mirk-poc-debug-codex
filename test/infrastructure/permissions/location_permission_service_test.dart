// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:logging/logging.dart';
import 'package:mirk_poc_debug/infrastructure/permissions/location_permission_service.dart';
import 'package:test/test.dart';

void main() {
  test('requests only foreground when-in-use location through the injected seam', () async {
    var requestCount = 0;
    final service = LocationPermissionService(
      requestWhenInUse: () async {
        requestCount++;
        return LocationPermissionState.granted;
      },
      statusReader: () async => LocationPermissionState.denied,
      openSettings: () async => true,
      logger: Logger('test.permissions'),
    );

    expect(await service.requestWhenInUse(), LocationPermissionState.granted);
    expect(requestCount, 1);
  });

  test('reports settings open outcome through the fakeable seam', () async {
    final service = LocationPermissionService(
      statusReader: () async => LocationPermissionState.permanentlyDenied,
      requestWhenInUse: () async => LocationPermissionState.denied,
      openSettings: () async => false,
      logger: Logger('test.permissions'),
    );

    expect(await service.status(), LocationPermissionState.permanentlyDenied);
    expect(await service.openSettings(), isFalse);
  });
}
