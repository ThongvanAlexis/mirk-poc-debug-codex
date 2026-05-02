// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../config/constants.dart';
import '../../domain/map/map_screen_services.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({required this.services, super.key});

  final MapScreenServices services;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  late final vtr.Theme _theme;
  late final Future<VectorTileProvider> _providerFuture;
  VectorTileProvider? _openedProvider;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _theme = ProtomapsThemes.lightV3();
    _providerFuture = _openProvider();
  }

  @override
  void dispose() {
    final VectorTileProvider? provider = _openedProvider;
    if (provider != null) {
      _disposeProvider(provider);
    }
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<VectorTileProvider>(
        future: _providerFuture,
        builder: (BuildContext context, AsyncSnapshot<VectorTileProvider> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: Text('Opening Melun map'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Map open failed'));
          }
          return FlutterMap(
            mapController: _mapController,
            options: createPocMapOptions(),
            children: createPocMapChildren(tileProvider: snapshot.requireData, theme: _theme),
          );
        },
      ),
    );
  }

  Future<VectorTileProvider> _openProvider() async {
    if (!widget.services.usesLocalPmtilesPath) {
      throw ArgumentError.value(widget.services.pmtilesPath, 'pmtilesPath', 'PMTiles source must be the copied local filesystem path.');
    }
    final MapTileProviderFactory factory = widget.services.tileProviderFactory ?? (String pmtilesPath) => PmTilesVectorTileProvider.fromSource(pmtilesPath);
    final VectorTileProvider provider = await factory(widget.services.pmtilesPath);
    if (!mounted) {
      _disposeProvider(provider);
      return provider;
    }
    _openedProvider = provider;
    return provider;
  }

  void _disposeProvider(VectorTileProvider provider) {
    final MapTileProviderDisposer? disposer = widget.services.tileProviderDisposer;
    if (disposer != null) {
      disposer(provider);
      return;
    }
    if (provider is PmTilesVectorTileProvider) {
      provider.archive.close().ignore();
    }
  }
}

@visibleForTesting
MapOptions createPocMapOptions() {
  return const MapOptions(
    initialCenter: LatLng(kPocInitialLatitude, kPocInitialLongitude),
    initialZoom: kPocInitialZoom,
    minZoom: kPocMinZoom,
    maxZoom: kPocMaxZoom,
    backgroundColor: Color(kMirkFogAtmosphericShadowColorArgb),
  );
}

@visibleForTesting
List<Widget> createPocMapChildren({required VectorTileProvider tileProvider, required vtr.Theme theme}) {
  return <Widget>[
    VectorTileLayer(
      tileProviders: TileProviders(<String, VectorTileProvider>{kPocTileProviderSourceKey: tileProvider}),
      theme: theme,
      maximumZoom: kPocMaxZoom,
    ),
  ];
}
