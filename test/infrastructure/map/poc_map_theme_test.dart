// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/infrastructure/map/poc_map_theme.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

void main() {
  test('creates a custom Protomaps theme with the local source key', () {
    final vtr.Theme theme = createPocMapTheme();

    expect(theme.id, kPocMapThemeId);
    expect(theme.tileSources, <String>{kPocTileProviderSourceKey});
    expect(theme.layers.map((vtr.ThemeLayer layer) => layer.id), containsAll(<String>['background', 'earth', 'landuse', 'water', 'roads', 'boundaries']));
  });

  test('style has no remote sprite, glyph, Mapbox, or MapLibre metadata', () {
    final String encodedStyle = jsonEncode(createPocMapThemeStyle()).toLowerCase();

    expect(encodedStyle, isNot(contains('http://')));
    expect(encodedStyle, isNot(contains('https://')));
    expect(encodedStyle, isNot(contains('sprite')));
    expect(encodedStyle, isNot(contains('glyph')));
    expect(encodedStyle, isNot(contains('mapbox')));
    expect(encodedStyle, isNot(contains('maplibre')));
  });

  test('style uses neutral MirkFall-derived map colors', () {
    expect(kPocMapNeutralColorArgbValues, contains(kMirkFogAtmosphericBaseColorArgb));
    expect(kPocMapNeutralColorArgbValues, contains(kMirkFogAtmosphericHighlightColorArgb));
    expect(kPocMapNeutralColorArgbValues, contains(kMirkFogAtmosphericShadowColorArgb));
    expect(kPocMapNeutralColorArgbValues.length, greaterThanOrEqualTo(6));
  });

  test('pubspec does not add Mapbox or MapLibre dependencies', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();

    expect(pubspec, isNot(contains('mapbox')));
    expect(pubspec, isNot(contains('maplibre')));
  });
}
