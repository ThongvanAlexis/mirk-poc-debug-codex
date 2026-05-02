// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:ui' as ui show FragmentShader, Image;
import 'dart:ui' show Size;

import 'package:mirk_poc_debug/config/constants.dart';

/// Sets the atmospheric fog fragment shader uniforms in shader declaration order.
class FogShaderUniforms {
  const FogShaderUniforms._();

  static const int totalFloatSlots = 41;
  static const (double, double, double, double) identitySdfRect = (kPocFogSdfRectOriginX, kPocFogSdfRectOriginY, kPocFogSdfRectSizeX, kPocFogSdfRectSizeY);

  static void setAll(
    ui.FragmentShader shader, {
    required Size resolution,
    required double time,
    required (double, double) offset,
    required int baseArgb,
    required double baseAlpha,
    required int highlightArgb,
    required int shadowArgb,
    required double driftZFar,
    required double driftZMid,
    required double driftZNear,
    required double scaleFar,
    required double scaleMid,
    required double scaleNear,
    required double opacityFar,
    required double opacityMid,
    required double opacityNear,
    required double curlAmplitude,
    required double curlScale,
    required double lightDirRadians,
    required double lightOffset,
    required double lightStrength,
    required double hueNoiseScale,
    required double hueStrength,
    required double boundarySharpDistance,
    required double boundaryBleedDistance,
    required double boundaryEdgeBand,
    required double boundaryDensityBoost,
    required (double, double, double, double) sdfRect,
    required ui.Image sdfImage,
  }) {
    shader.setFloat(0, resolution.width);
    shader.setFloat(1, resolution.height);
    shader.setFloat(2, time);
    shader.setFloat(3, offset.$1);
    shader.setFloat(4, offset.$2);
    shader.setFloat(5, _red(baseArgb));
    shader.setFloat(6, _green(baseArgb));
    shader.setFloat(7, _blue(baseArgb));
    shader.setFloat(8, baseAlpha);
    shader.setFloat(9, _red(highlightArgb));
    shader.setFloat(10, _green(highlightArgb));
    shader.setFloat(11, _blue(highlightArgb));
    shader.setFloat(12, 1.0);
    shader.setFloat(13, _red(shadowArgb));
    shader.setFloat(14, _green(shadowArgb));
    shader.setFloat(15, _blue(shadowArgb));
    shader.setFloat(16, 1.0);
    shader.setFloat(17, driftZFar);
    shader.setFloat(18, driftZMid);
    shader.setFloat(19, driftZNear);
    shader.setFloat(20, scaleFar);
    shader.setFloat(21, scaleMid);
    shader.setFloat(22, scaleNear);
    shader.setFloat(23, opacityFar);
    shader.setFloat(24, opacityMid);
    shader.setFloat(25, opacityNear);
    shader.setFloat(26, curlAmplitude);
    shader.setFloat(27, curlScale);
    shader.setFloat(28, lightDirRadians);
    shader.setFloat(29, lightOffset);
    shader.setFloat(30, lightStrength);
    shader.setFloat(31, hueNoiseScale);
    shader.setFloat(32, hueStrength);
    shader.setFloat(33, boundarySharpDistance);
    shader.setFloat(34, boundaryBleedDistance);
    shader.setFloat(35, boundaryEdgeBand);
    shader.setFloat(36, boundaryDensityBoost);
    shader.setFloat(37, sdfRect.$1);
    shader.setFloat(38, sdfRect.$2);
    shader.setFloat(39, sdfRect.$3);
    shader.setFloat(40, sdfRect.$4);
    shader.setImageSampler(0, sdfImage);
  }

  static double _red(int argb) => ((argb >> 16) & 0xFF) / 255.0;

  static double _green(int argb) => ((argb >> 8) & 0xFF) / 255.0;

  static double _blue(int argb) => (argb & 0xFF) / 255.0;
}
