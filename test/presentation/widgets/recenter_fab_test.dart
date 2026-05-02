// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:test/test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/presentation/widgets/recenter_fab.dart').readAsStringSync();
  });

  test('renders a compact recenter control that is disabled without a latest fix', () {
    expect(source, contains('class RecenterFab extends StatelessWidget'));
    expect(source, contains('GeoFix? latestFix'));
    expect(source, contains('latestFix == null ? null : onRecenter'));
    expect(source, contains('Icons.my_location'));
  });

  test('delegates movement to MapScreen so the map controller remains injectable there', () {
    expect(source, contains('VoidCallback onRecenter'));
    expect(source, isNot(contains('MapController()')));
  });
}
