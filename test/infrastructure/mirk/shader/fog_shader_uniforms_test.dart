// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:mirk_poc_debug/config/constants.dart';
import 'package:test/test.dart';

void main() {
  final source = File('lib/infrastructure/mirk/shader/fog_shader_uniforms.dart').readAsStringSync();

  test('declares exactly 41 float slots', () {
    expect(source, contains('static const int totalFloatSlots = 41;'));
  });

  test('writes every float slot from 0 through 40', () {
    final indices = RegExp(r'shader\.setFloat\((\d+),').allMatches(source).map((match) => int.parse(match.group(1)!)).toList();

    expect(indices, equals(List<int>.generate(41, (index) => index)));
  });

  test('binds the SDF sampler at sampler index 0', () {
    expect(source, contains('shader.setImageSampler(0, sdfImage);'));
  });

  test('keeps identity SDF rect defaults wired to constants', () {
    expect(kPocFogSdfRectOriginX, equals(0.0));
    expect(kPocFogSdfRectOriginY, equals(0.0));
    expect(kPocFogSdfRectSizeX, equals(1.0));
    expect(kPocFogSdfRectSizeY, equals(1.0));
    expect(source, contains('identitySdfRect'));
  });
}
