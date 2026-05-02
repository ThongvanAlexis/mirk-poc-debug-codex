// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:mirk_poc_debug/infrastructure/location/foreground_location_service.dart';
import 'package:test/test.dart';

void main() {
  test('emits finite in-range fixes, including positions outside Melun', () async {
    final StreamController<Position> positions = StreamController<Position>();
    final service = ForegroundLocationService(positionStreamFactory: (_) => positions.stream, logger: Logger('test.location'));

    service.start();
    positions.add(_position(latitude: 49.0, longitude: 3.0));

    final fix = await service.fixes.first;
    expect(fix.latitude, 49.0);
    expect(fix.longitude, 3.0);

    await positions.close();
    await service.dispose();
  });

  test('rejects invalid coordinates and stops the subscription', () async {
    final StreamController<Position> positions = StreamController<Position>();
    final service = ForegroundLocationService(positionStreamFactory: (_) => positions.stream, logger: Logger('test.location'));

    service.start();
    positions.add(_position(latitude: double.nan, longitude: 2.0));
    await Future<void>.delayed(Duration.zero);

    var emitted = false;
    final subscription = service.fixes.listen((_) {
      emitted = true;
    });
    await service.stop(reason: 'test');
    await positions.close();
    await service.dispose();
    await subscription.cancel();

    expect(emitted, isFalse);
  });
}

Position _position({required double latitude, required double longitude}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime.utc(2026, 5, 2, 12),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}
