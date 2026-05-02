// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:vector_map_tiles/vector_map_tiles.dart';

typedef MapTileProviderFactory = Future<VectorTileProvider> Function(String pmtilesPath);
typedef MapTileProviderDisposer = void Function(VectorTileProvider provider);

enum MapDisplayMode { mapOnly, mapWithFog }

class MapScreenServices {
  const MapScreenServices({required this.pmtilesPath, this.initialDisplayMode = MapDisplayMode.mapOnly, this.tileProviderFactory, this.tileProviderDisposer});

  final String pmtilesPath;
  final MapDisplayMode initialDisplayMode;
  final MapTileProviderFactory? tileProviderFactory;
  final MapTileProviderDisposer? tileProviderDisposer;

  bool get initiallyShowsFog => initialDisplayMode == MapDisplayMode.mapWithFog;

  bool get usesLocalPmtilesPath {
    final String lowerPath = pmtilesPath.toLowerCase();
    return !lowerPath.startsWith('http://') && !lowerPath.startsWith('https://') && !lowerPath.startsWith('asset://');
  }
}
