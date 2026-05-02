// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:vector_map_tiles/vector_map_tiles.dart';

typedef MapTileProviderFactory = Future<VectorTileProvider> Function(String pmtilesPath);

enum MapDisplayMode { mapOnly, mapWithFog }

class MapScreenServices {
  const MapScreenServices({required this.pmtilesPath, this.initialDisplayMode = MapDisplayMode.mapOnly, this.tileProviderFactory});

  final String pmtilesPath;
  final MapDisplayMode initialDisplayMode;
  final MapTileProviderFactory? tileProviderFactory;

  bool get initiallyShowsFog => initialDisplayMode == MapDisplayMode.mapWithFog;
}
