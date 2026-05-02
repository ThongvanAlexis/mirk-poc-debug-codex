// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../config/constants.dart';

const String kPocMapThemeId = 'mirkfall-poc-neutral-v1';
const int kPocMapBackgroundColorArgb = kMirkFogAtmosphericShadowColorArgb;
const int kPocMapLandColorArgb = 0xFF333C4F;
const int kPocMapLandcoverColorArgb = kMirkFogAtmosphericBaseColorArgb;
const int kPocMapWaterColorArgb = 0xFF263C5B;
const int kPocMapBoundaryColorArgb = kMirkFogAtmosphericHighlightColorArgb;
const int kPocMapRoadColorArgb = 0xFFB7BBC4;
const int kPocMapBuildingColorArgb = 0xFF505868;

const Set<int> kPocMapNeutralColorArgbValues = <int>{
  kPocMapBackgroundColorArgb,
  kPocMapLandColorArgb,
  kPocMapLandcoverColorArgb,
  kPocMapWaterColorArgb,
  kPocMapBoundaryColorArgb,
  kPocMapRoadColorArgb,
  kPocMapBuildingColorArgb,
};

vtr.Theme createPocMapTheme() {
  return vtr.ThemeReader().read(createPocMapThemeStyle());
}

Map<String, Object> createPocMapThemeStyle() {
  return <String, Object>{
    'id': kPocMapThemeId,
    'metadata': <String, Object>{'version': '1'},
    'version': 8,
    'layers': <Map<String, Object>>[
      <String, Object>{
        'id': 'background',
        'type': 'background',
        'paint': <String, Object>{'background-color': _hexColor(kPocMapBackgroundColorArgb)},
      },
      _fillLayer(id: 'earth', sourceLayer: 'earth', color: kPocMapLandColorArgb),
      _fillLayer(id: 'landuse', sourceLayer: 'landuse', color: kPocMapLandcoverColorArgb, opacity: 0.78),
      _fillLayer(id: 'natural', sourceLayer: 'natural', color: kPocMapLandcoverColorArgb, opacity: 0.62),
      _fillLayer(id: 'water', sourceLayer: 'water', color: kPocMapWaterColorArgb),
      _fillLayer(id: 'buildings', sourceLayer: 'buildings', color: kPocMapBuildingColorArgb, opacity: 0.78, minzoom: 13),
      _lineLayer(id: 'physical-lines', sourceLayer: 'physical_line', color: kPocMapWaterColorArgb, width: 0.8, opacity: 0.65),
      _lineLayer(id: 'roads', sourceLayer: 'roads', color: kPocMapRoadColorArgb, width: 1.15, opacity: 0.76),
      _lineLayer(id: 'boundaries', sourceLayer: 'boundaries', color: kPocMapBoundaryColorArgb, width: 0.7, opacity: 0.58),
    ],
  };
}

Map<String, Object> _fillLayer({required String id, required String sourceLayer, required int color, double opacity = 1.0, int? minzoom}) {
  final layer = <String, Object>{
    'id': id,
    'type': 'fill',
    'source': kPocTileProviderSourceKey,
    'source-layer': sourceLayer,
    'paint': <String, Object>{'fill-color': _hexColor(color), 'fill-opacity': opacity},
  };
  if (minzoom != null) {
    layer['minzoom'] = minzoom;
  }
  return layer;
}

Map<String, Object> _lineLayer({required String id, required String sourceLayer, required int color, required double width, double opacity = 1.0}) {
  return <String, Object>{
    'id': id,
    'type': 'line',
    'source': kPocTileProviderSourceKey,
    'source-layer': sourceLayer,
    'layout': <String, Object>{'line-cap': 'round', 'line-join': 'round'},
    'paint': <String, Object>{'line-color': _hexColor(color), 'line-width': width, 'line-opacity': opacity},
  };
}

String _hexColor(int argb) => '#${(argb & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
