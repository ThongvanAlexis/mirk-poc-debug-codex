// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:test/test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/presentation/widgets/blue_dot_marker.dart').readAsStringSync();
  });

  test('builds a flutter_map CircleMarker from the latest fix point', () {
    expect(source, contains('class BlueDotMarker'));
    expect(source, contains('CircleMarker<Object> build'));
    expect(source, contains('required LatLng point'));
  });

  test('uses a blue fill, white stroke, and pixel radius constants', () {
    expect(source, contains('kPocBlueDotRadiusPx'));
    expect(source, contains('kPocBlueDotFillArgb'));
    expect(source, contains('kPocBlueDotStrokePx'));
    expect(source, contains('borderColor: Colors.white'));
    expect(source, contains('useRadiusInMeter: false'));
  });
}
