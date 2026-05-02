// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:ui' as ui;

import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../location/geo_fix.dart';
import '../revealed/reveal_disc_repository.dart';

typedef MapTileProviderFactory = Future<VectorTileProvider> Function(String pmtilesPath);
typedef MapTileProviderDisposer = void Function(VectorTileProvider provider);
typedef FogProgramLoader = Future<ui.FragmentProgram> Function();

enum MapDisplayMode { mapOnly, mapWithFog }

class MapScreenServices {
  const MapScreenServices({
    required this.pmtilesPath,
    this.initialDisplayMode = MapDisplayMode.mapOnly,
    this.initialLatestFix,
    this.latestFixStream,
    this.revealDiscRepository,
    this.tileProviderFactory,
    this.tileProviderDisposer,
    this.fogProgramLoader,
  });

  final String pmtilesPath;
  final MapDisplayMode initialDisplayMode;
  final GeoFix? initialLatestFix;
  final Stream<GeoFix>? latestFixStream;
  final RevealDiscRepository? revealDiscRepository;
  final MapTileProviderFactory? tileProviderFactory;
  final MapTileProviderDisposer? tileProviderDisposer;
  final FogProgramLoader? fogProgramLoader;

  bool get initiallyShowsFog => initialDisplayMode == MapDisplayMode.mapWithFog;

  bool get usesLocalPmtilesPath {
    final String lowerPath = pmtilesPath.toLowerCase();
    return !lowerPath.startsWith('http://') && !lowerPath.startsWith('https://') && !lowerPath.startsWith('asset://');
  }
}
