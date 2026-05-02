// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../config/constants.dart';
import '../../domain/location/geo_fix.dart';
import '../../domain/map/map_screen_services.dart';
import '../../domain/revealed/reveal_disc_repository.dart';
import '../../infrastructure/map/poc_map_theme.dart';
import '../../infrastructure/mirk/sdf/sdf_cache.dart';
import '../widgets/fog_layer.dart';
import '../widgets/map_mode_toggle.dart';

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
  late final RevealDiscRepository _revealDiscRepository;
  late final bool _ownsRevealDiscRepository;
  late final SdfCache<ui.Image> _sdfCache;
  late MapDisplayMode _mode;
  VectorTileProvider? _openedProvider;
  ui.FragmentShader? _fogShader;
  GeoFix? _latestFix;
  StreamSubscription<GeoFix>? _latestFixSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _theme = createPocMapTheme();
    _mode = widget.services.initialDisplayMode;
    _revealDiscRepository = widget.services.revealDiscRepository ?? RevealDiscRepository();
    _ownsRevealDiscRepository = widget.services.revealDiscRepository == null;
    _sdfCache = createFogSdfCache();
    final initialLatestFix = widget.services.initialLatestFix;
    if (initialLatestFix != null && _revealDiscRepository.appendFix(initialLatestFix)) {
      _latestFix = initialLatestFix;
    }
    _latestFixSubscription = widget.services.latestFixStream?.listen(_acceptLatestFix);
    _providerFuture = _openProvider();
    _loadFogShader().ignore();
  }

  @override
  void dispose() {
    _latestFixSubscription?.cancel().ignore();
    _latestFixSubscription = null;
    final VectorTileProvider? provider = _openedProvider;
    if (provider != null) {
      _disposeProvider(provider);
    }
    if (_ownsRevealDiscRepository) {
      _revealDiscRepository.dispose();
    }
    _sdfCache.dispose();
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
          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: createPocMapOptions(),
                  children: createPocMapChildren(
                    tileProvider: snapshot.requireData,
                    theme: _theme,
                    displayMode: _mode,
                    revealDiscRepository: _revealDiscRepository,
                    fogShader: _fogShader,
                    sdfCache: _sdfCache,
                    latestFix: _latestFix,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: SafeArea(
                  child: MapModeToggle(
                    mode: _mode,
                    onChanged: (MapDisplayMode mode) {
                      setState(() {
                        _mode = mode;
                      });
                    },
                  ),
                ),
              ),
            ],
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

  Future<void> _loadFogShader() async {
    try {
      final FogProgramLoader loader = widget.services.fogProgramLoader ?? () => ui.FragmentProgram.fromAsset(kPocFogShaderAssetPath);
      final program = await loader();
      if (!mounted) return;
      setState(() {
        _fogShader = program.fragmentShader();
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _fogShader = null;
      });
    }
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

  void _acceptLatestFix(GeoFix fix) {
    if (!_revealDiscRepository.appendFix(fix)) return;
    if (!mounted) return;
    setState(() {
      _latestFix = fix;
    });
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
List<Widget> createPocMapChildren({
  required VectorTileProvider tileProvider,
  required vtr.Theme theme,
  MapDisplayMode displayMode = MapDisplayMode.mapOnly,
  RevealDiscRepository? revealDiscRepository,
  ui.FragmentShader? fogShader,
  SdfCache<ui.Image>? sdfCache,
  GeoFix? latestFix,
}) {
  final children = <Widget>[
    VectorTileLayer(
      tileProviders: TileProviders(<String, VectorTileProvider>{kPocTileProviderSourceKey: tileProvider}),
      theme: theme,
      maximumZoom: kPocMaxZoom,
    ),
  ];
  if (displayMode == MapDisplayMode.mapWithFog && revealDiscRepository != null && sdfCache != null) {
    children.add(FogLayer(discRepository: revealDiscRepository, shader: fogShader, sdfCache: sdfCache));
  }
  if (latestFix != null) {
    children.add(
      CircleLayer<Object>(
        circles: <CircleMarker<Object>>[
          CircleMarker<Object>(point: latestFix.latLng, radius: 7.0, color: Colors.blue, borderStrokeWidth: 2.0, borderColor: Colors.white),
        ],
      ),
    );
  }
  return children;
}
