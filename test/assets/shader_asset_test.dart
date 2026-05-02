// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/config/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('atmospheric fog shader is declared under flutter.shaders', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('shaders:\n    - $kPocFogShaderAssetPath'));
  });

  test('atmospheric fog shader asset contains scalar SDF rect uniforms', () async {
    final String shader = await rootBundle.loadString(kPocFogShaderAssetPath);

    expect(shader, contains('uSdfRectOriginX'));
    expect(shader, contains('uSdfRectOriginY'));
    expect(shader, contains('uSdfRectSizeX'));
    expect(shader, contains('uSdfRectSizeY'));
  });
}
