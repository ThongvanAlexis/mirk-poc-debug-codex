// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:mirk_poc_debug/config/constants.dart';
import 'package:test/test.dart';

void main() {
  test('locks the Melun map source and initial camera', () {
    expect(kPocTileProviderSourceKey, equals('protomaps'));
    expect(kPocInitialLatitude, equals(48.5397));
    expect(kPocInitialLongitude, equals(2.6553));
    expect(kPocInitialZoom, equals(13.0));
    expect(kPocRecenterZoom, equals(15.0));
    expect(kPocMinZoom, lessThanOrEqualTo(kPocInitialZoom));
    expect(kPocMaxZoom, greaterThanOrEqualTo(kPocRecenterZoom));
  });

  test('keeps local Melun bounds padded around the initial camera', () {
    expect(kPocMelunBoundsSouth, lessThan(kPocInitialLatitude));
    expect(kPocMelunBoundsNorth, greaterThan(kPocInitialLatitude));
    expect(kPocMelunBoundsWest, lessThan(kPocInitialLongitude));
    expect(kPocMelunBoundsEast, greaterThan(kPocInitialLongitude));
  });

  test('locks renderer-critical fog and SDF constants', () {
    expect(kMaxLogsDirBytes, equals(10 * 1024 * 1024));
    expect(kPocFogShaderAssetPath, equals('assets/shaders/atmospheric_fog.frag'));
    expect(kPocRevealDiscRadiusMeters, equals(25.0));
    expect(kEarthRadiusMeters, equals(6371008.8));
    expect(kMetersPerDegreeLat, equals(111320.0));
    expect(kMirkFogSdfResolution, equals(256));
  });

  test('keeps the first same-pipeline SDF rect as identity', () {
    expect(kPocFogSdfRectOriginX, equals(0.0));
    expect(kPocFogSdfRectOriginY, equals(0.0));
    expect(kPocFogSdfRectSizeX, equals(1.0));
    expect(kPocFogSdfRectSizeY, equals(1.0));
  });

  test('copies atmospheric shader defaults from the parent project', () {
    expect(kMirkFogAtmosphericBaseColorArgb, equals(0xFF3A4358));
    expect(kMirkFogAtmosphericHighlightColorArgb, equals(0xFF7C8AA3));
    expect(kMirkFogAtmosphericShadowColorArgb, equals(0xFF1E2536));
    expect(kMirkFogAtmosphericDriftZFar, equals(0.23));
    expect(kMirkFogAtmosphericDriftZMid, equals(0.24));
    expect(kMirkFogAtmosphericDriftZNear, equals(0.23));
    expect(kMirkFogAtmosphericScaleFar, equals(2.9));
    expect(kMirkFogAtmosphericScaleMid, equals(5.1));
    expect(kMirkFogAtmosphericScaleNear, equals(10.5));
    expect(kMirkFogOpacityFar, equals(0.58));
    expect(kMirkFogOpacityMid, equals(0.58));
    expect(kMirkFogOpacityNear, equals(0.58));
    expect(kMirkFogCurlAmplitude, equals(1.0));
    expect(kMirkFogCurlScale, equals(0.8));
    expect(kMirkFogCurlScaleAnimationDefaultEnabled, isTrue);
    expect(kMirkFogCurlScaleAnimationPeriodSec, equals(40.0));
    expect(kMirkFogCurlScaleAnimationMin, equals(0.0));
    expect(kMirkFogCurlScaleAnimationMax, equals(4.0));
    expect(kMirkFogLightDirRadians, equals(-1.11));
    expect(kMirkFogLightOffset, equals(0.46));
    expect(kMirkFogLightStrength, equals(1.67));
    expect(kMirkFogHueNoiseScale, equals(1.6));
    expect(kMirkFogHueStrength, equals(0.44));
    expect(kMirkFogBoundarySharpDistance, equals(0.04));
    expect(kMirkFogBoundaryBleedDistance, equals(0.12));
    expect(kMirkFogBoundaryEdgeBand, equals(0.17));
    expect(kMirkFogBoundaryDensityBoost, equals(0.15));
  });
}
