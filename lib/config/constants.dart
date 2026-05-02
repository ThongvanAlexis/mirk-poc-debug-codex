// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

const String kPmtilesAssetPath = 'assets/maps/Fra_Melun.pmtile';
const String kPmtilesBasename = 'Fra_Melun.pmtile';
const String kPmtilesMapsSubdir = 'maps';
const int kPmtilesExpectedByteLength = 4176302;
const String kPmtilesExpectedSha256 = '6bc39c03501d99dadc5c08994663fd07cdb18f6149fb5425c2aa933c7b09ddf1';

const String kPocTileProviderSourceKey = 'protomaps';
const double kPocInitialLatitude = 48.5397;
const double kPocInitialLongitude = 2.6553;
const double kPocInitialZoom = 13.0;
const double kPocRecenterZoom = 15.0;
const double kPocMinZoom = 11.0;
const double kPocMaxZoom = 18.0;
const double kPocBlueDotRadiusPx = 7.0;
const int kPocBlueDotFillArgb = 0xFF2B7CD6;
const double kPocBlueDotStrokePx = 2.0;
const double kPocMelunBoundsSouth = 48.48;
const double kPocMelunBoundsWest = 2.55;
const double kPocMelunBoundsNorth = 48.60;
const double kPocMelunBoundsEast = 2.78;

const String kPocFogShaderAssetPath = 'assets/shaders/atmospheric_fog.frag';
const double kPocRevealDiscRadiusMeters = 25.0;
const double kEarthRadiusMeters = 6371008.8;
const double kMetersPerDegreeLat = 111320.0;
const double kPocFogSdfRectOriginX = 0.0;
const double kPocFogSdfRectOriginY = 0.0;
const double kPocFogSdfRectSizeX = 1.0;
const double kPocFogSdfRectSizeY = 1.0;

const int kMirkFogAtmosphericBaseColorArgb = 0xFF3A4358;
const int kMirkFogAtmosphericHighlightColorArgb = 0xFF7C8AA3;
const int kMirkFogAtmosphericShadowColorArgb = 0xFF1E2536;
const double kMirkFogAtmosphericDriftZFar = 0.23;
const double kMirkFogAtmosphericDriftZMid = 0.24;
const double kMirkFogAtmosphericDriftZNear = 0.23;
const double kMirkFogAtmosphericScaleFar = 2.9;
const double kMirkFogAtmosphericScaleMid = 5.1;
const double kMirkFogAtmosphericScaleNear = 10.5;
const double kMirkFogOpacityFar = 0.58;
const double kMirkFogOpacityMid = 0.58;
const double kMirkFogOpacityNear = 0.58;
const double kMirkFogCurlAmplitude = 1.0;
const double kMirkFogCurlScale = 0.8;
const bool kMirkFogCurlScaleAnimationDefaultEnabled = true;
const double kMirkFogCurlScaleAnimationPeriodSec = 40.0;
const double kMirkFogCurlScaleAnimationMin = 0.0;
const double kMirkFogCurlScaleAnimationMax = 4.0;
const double kMirkFogLightDirRadians = -1.11;
const double kMirkFogLightOffset = 0.46;
const double kMirkFogLightStrength = 1.67;
const double kMirkFogHueNoiseScale = 1.6;
const double kMirkFogHueStrength = 0.44;
const double kMirkFogBoundarySharpDistance = 0.04;
const double kMirkFogBoundaryBleedDistance = 0.12;
const double kMirkFogBoundaryEdgeBand = 0.17;
const double kMirkFogBoundaryDensityBoost = 0.15;
const int kMirkFogSdfResolution = 256;
