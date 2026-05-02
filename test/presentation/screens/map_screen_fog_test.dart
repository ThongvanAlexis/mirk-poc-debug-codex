// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:test/test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/presentation/screens/map_screen.dart').readAsStringSync();
  });

  test('loads the atmospheric fog shader asset through a safe async seam', () {
    expect(source, contains('ui.FragmentProgram.fromAsset(kPocFogShaderAssetPath)'));
    expect(source, contains('widget.services.fogProgramLoader'));
    expect(source, contains('catch ('));
  });

  test('builds FlutterMap children in tile, fog, blue-dot order', () {
    final vectorIndex = source.indexOf('VectorTileLayer(');
    final fogIndex = source.indexOf('FogLayer(');
    final blueDotIndex = source.indexOf('CircleLayer<Object>(');

    expect(vectorIndex, isNonNegative);
    expect(fogIndex, greaterThan(vectorIndex));
    expect(blueDotIndex, greaterThan(fogIndex));
  });

  test('map-only mode gates only FogLayer while preserving VectorTileLayer', () {
    expect(source, contains('displayMode == MapDisplayMode.mapWithFog'));
    expect(source, contains('VectorTileLayer('));
    expect(source, contains('FogLayer('));
  });

  test('owns SDF cache and reveal repository in MapScreen rather than an external overlay', () {
    expect(source, contains('SdfCache<ui.Image>'));
    expect(source, contains('createFogSdfCache()'));
    expect(source, contains('createPocMapChildren('));
    expect(source, isNot(contains('Positioned.fill(child: FogLayer')));
  });
}
