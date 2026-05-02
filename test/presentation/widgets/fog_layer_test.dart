// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:test/test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/presentation/widgets/fog_layer.dart').readAsStringSync();
  });

  test('is a stateful flutter_map layer transformed by MobileLayerTransformer', () {
    expect(source, contains('class FogLayer extends StatefulWidget'));
    expect(source, contains('with SingleTickerProviderStateMixin'));
    expect(source, contains('MobileLayerTransformer('));
    expect(source, contains('CustomPaint('));
  });

  test('reads MapCamera once per build and passes the snapshot into paint inputs', () {
    expect(RegExp(r'MapCamera\.of\(context\)').allMatches(source), hasLength(1));
    expect(source, contains('final MapCamera camera = MapCamera.of(context);'));
    expect(source, contains('viewportFromCamera(camera)'));
    expect(source, contains('camera: camera'));
  });

  test('uses SDF cache, clip path, triangle-wave animation, and locked shader uniforms', () {
    expect(source, contains('SdfCache<ui.Image>'));
    expect(source, contains('RevealedSdfBuilder'));
    expect(source, contains('buildViewportFogClipPathFromDiscs'));
    expect(source, contains('FogShaderUniforms.setAll'));
    expect(source, contains('triangleWave('));
    expect(source, contains('FogShaderUniforms.identitySdfRect'));
  });

  test('does not isolate fog from the map repaint pipeline', () {
    expect(source, isNot(contains('RepaintBoundary')));
  });

  test('logs SDF image readiness and failure markers', () {
    expect(source, contains('presentation.fog_layer'));
    expect(source, contains('sdf_image_ready'));
    expect(source, contains('sdf_image_unavailable'));
  });
}
