// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../config/constants.dart';
import '../../domain/location/geo_fix.dart';
import '../../domain/map/map_screen_services.dart';
import '../../domain/revealed/reveal_disc_repository.dart';
import '../../infrastructure/logging/frame_timing_logger.dart';
import '../../infrastructure/map/poc_map_theme.dart';
import '../../infrastructure/mirk/sdf/sdf_cache.dart';
import '../widgets/blue_dot_marker.dart';
import '../widgets/fog_layer.dart';
import '../widgets/map_mode_toggle.dart';
import '../widgets/recenter_fab.dart';
import '../widgets/share_log_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({required this.services, super.key});

  final MapScreenServices services;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static final Logger _log = Logger('presentation.map_screen');

  late final MapController _mapController;
  late final vtr.Theme _theme;
  late final Future<VectorTileProvider> _providerFuture;
  late final RevealDiscRepository _revealDiscRepository;
  late final bool _ownsRevealDiscRepository;
  late final SdfCache<ui.Image> _sdfCache;
  late final FrameTimingLogger _frameTimingLogger;
  late MapDisplayMode _mode;
  VectorTileProvider? _openedProvider;
  ui.FragmentShader? _fogShader;
  GeoFix? _latestFix;
  StreamSubscription<GeoFix>? _latestFixSubscription;
  DateTime? _lastMapEventLoggedAt;
  String? _lastMapEventType;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _theme = createPocMapTheme();
    _mode = widget.services.initialDisplayMode;
    _revealDiscRepository = widget.services.revealDiscRepository ?? RevealDiscRepository();
    _ownsRevealDiscRepository = widget.services.revealDiscRepository == null;
    _sdfCache = createFogSdfCache();
    _frameTimingLogger = FrameTimingLogger(modeProvider: () => _mode.name)..start();
    final initialLatestFix = widget.services.initialLatestFix;
    if (initialLatestFix != null && _revealDiscRepository.appendFix(initialLatestFix)) {
      _latestFix = initialLatestFix;
      _log.info('latest_fix_initial_accepted inMelun=${_isInMelunBounds(initialLatestFix)}');
    }
    _latestFixSubscription = widget.services.latestFixStream?.listen(_acceptLatestFix);
    _providerFuture = _openProvider();
    _loadFogShader().ignore();
  }

  @override
  void dispose() {
    _frameTimingLogger.stop();
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
                  options: createPocMapOptions(onMapEvent: _logMapEvent),
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
                      _log.info('map_display_mode_changed from=${_mode.name} to=${mode.name}');
                      setState(() {
                        _mode = mode;
                      });
                    },
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: SafeArea(child: ShareLogButton(onShareLog: widget.services.shareActiveLog)),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: SafeArea(
                  child: RecenterFab(latestFix: _latestFix, onRecenter: _recenterToLatestFix),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<VectorTileProvider> _openProvider() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final String sourceBasename = p.basename(widget.services.pmtilesPath);
    _log.info('tile_provider_open_start source=$sourceBasename');
    if (!widget.services.usesLocalPmtilesPath) {
      _log.warning('tile_provider_open_rejected source=$sourceBasename reason=non_local_path elapsedMs=${stopwatch.elapsedMilliseconds}');
      throw ArgumentError.value(widget.services.pmtilesPath, 'pmtilesPath', 'PMTiles source must be the copied local filesystem path.');
    }
    final MapTileProviderFactory factory = widget.services.tileProviderFactory ?? (String pmtilesPath) => PmTilesVectorTileProvider.fromSource(pmtilesPath);
    try {
      final VectorTileProvider provider = await factory(widget.services.pmtilesPath);
      _log.info('tile_provider_open_success source=$sourceBasename elapsedMs=${stopwatch.elapsedMilliseconds}');
      if (!mounted) {
        _disposeProvider(provider);
        return provider;
      }
      _openedProvider = provider;
      return provider;
    } on Object catch (error, stackTrace) {
      _log.warning('tile_provider_open_failure source=$sourceBasename elapsedMs=${stopwatch.elapsedMilliseconds}', error, stackTrace);
      rethrow;
    }
  }

  Future<void> _loadFogShader() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    _log.info('fog_shader_load_start asset=$kPocFogShaderAssetPath');
    try {
      final FogProgramLoader loader = widget.services.fogProgramLoader ?? () => ui.FragmentProgram.fromAsset(kPocFogShaderAssetPath);
      final program = await loader();
      if (!mounted) return;
      setState(() {
        _fogShader = program.fragmentShader();
      });
      _log.info('fog_shader_load_success asset=$kPocFogShaderAssetPath elapsedMs=${stopwatch.elapsedMilliseconds}');
    } on Object catch (error, stackTrace) {
      _log.warning('fog_shader_load_failure asset=$kPocFogShaderAssetPath elapsedMs=${stopwatch.elapsedMilliseconds}', error, stackTrace);
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
    if (!_revealDiscRepository.appendFix(fix)) {
      _log.warning('latest_fix_rejected latitude=${fix.latitude} longitude=${fix.longitude}');
      return;
    }
    final bool inMelun = _isInMelunBounds(fix);
    _log.info('latest_fix_accepted latitude=${fix.latitude} longitude=${fix.longitude} inMelun=$inMelun');
    if (!inMelun) {
      _log.info('latest_fix_out_of_melun latitude=${fix.latitude} longitude=${fix.longitude}');
    }
    if (!mounted) return;
    setState(() {
      _latestFix = fix;
    });
  }

  void _recenterToLatestFix() {
    final fix = _latestFix;
    if (fix == null) return;
    _log.info('map_recenter_to_latest_fix latitude=${fix.latitude} longitude=${fix.longitude} zoom=$kPocRecenterZoom');
    _mapController.move(fix.latLng, kPocRecenterZoom);
  }

  void _logMapEvent(MapEvent event) {
    final DateTime now = DateTime.now().toUtc();
    final String type = event.runtimeType.toString();
    final DateTime? lastLoggedAt = _lastMapEventLoggedAt;
    if (_lastMapEventType == type && lastLoggedAt != null && now.difference(lastLoggedAt) < _mapEventLogThrottle) return;

    _lastMapEventType = type;
    _lastMapEventLoggedAt = now;
    _log.info(
      'map_event type=$type source=${event.source.name} mode=${_mode.name} '
      'zoom=${event.camera.zoom.toStringAsFixed(2)} centerLat=${event.camera.center.latitude.toStringAsFixed(6)} '
      'centerLon=${event.camera.center.longitude.toStringAsFixed(6)}',
    );
  }

  bool _isInMelunBounds(GeoFix fix) {
    return fix.latitude >= kPocMelunBoundsSouth &&
        fix.latitude <= kPocMelunBoundsNorth &&
        fix.longitude >= kPocMelunBoundsWest &&
        fix.longitude <= kPocMelunBoundsEast;
  }
}

@visibleForTesting
MapOptions createPocMapOptions({MapEventCallback? onMapEvent}) {
  return MapOptions(
    initialCenter: const LatLng(kPocInitialLatitude, kPocInitialLongitude),
    initialZoom: kPocInitialZoom,
    minZoom: kPocMinZoom,
    maxZoom: kPocMaxZoom,
    backgroundColor: const Color(kMirkFogAtmosphericShadowColorArgb),
    onMapEvent: onMapEvent,
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
    children.add(CircleLayer<Object>(circles: <CircleMarker<Object>>[BlueDotMarker.build(point: latestFix.latLng)]));
  }
  return children;
}

const Duration _mapEventLogThrottle = Duration(milliseconds: 500);
