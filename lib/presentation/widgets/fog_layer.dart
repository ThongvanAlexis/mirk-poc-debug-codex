// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async' show unawaited;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../config/constants.dart';
import '../../domain/mirk/mirk_viewport_bbox.dart';
import '../../domain/revealed/reveal_disc.dart';
import '../../domain/revealed/reveal_disc_repository.dart';
import '../../infrastructure/mirk/animation_helpers.dart';
import '../../infrastructure/mirk/sdf/revealed_sdf_builder.dart';
import '../../infrastructure/mirk/sdf/sdf_cache.dart';
import '../../infrastructure/mirk/shader/fog_shader_uniforms.dart';
import 'fog_clip_path.dart';

abstract class FogShaderRenderer {
  void render({
    required ui.FragmentShader? shader,
    required Size resolution,
    required double timeSeconds,
    required double curlScale,
    required ui.Image sdfImage,
  });
}

class _FragmentShaderFogRenderer implements FogShaderRenderer {
  const _FragmentShaderFogRenderer();

  @override
  void render({
    required ui.FragmentShader? shader,
    required Size resolution,
    required double timeSeconds,
    required double curlScale,
    required ui.Image sdfImage,
  }) {
    if (shader == null) return;
    FogShaderUniforms.setAll(
      shader,
      resolution: resolution,
      time: timeSeconds,
      offset: const (0.0, 0.0),
      baseArgb: kMirkFogAtmosphericBaseColorArgb,
      baseAlpha: 1.0,
      highlightArgb: kMirkFogAtmosphericHighlightColorArgb,
      shadowArgb: kMirkFogAtmosphericShadowColorArgb,
      driftZFar: kMirkFogAtmosphericDriftZFar,
      driftZMid: kMirkFogAtmosphericDriftZMid,
      driftZNear: kMirkFogAtmosphericDriftZNear,
      scaleFar: kMirkFogAtmosphericScaleFar,
      scaleMid: kMirkFogAtmosphericScaleMid,
      scaleNear: kMirkFogAtmosphericScaleNear,
      opacityFar: kMirkFogOpacityFar,
      opacityMid: kMirkFogOpacityMid,
      opacityNear: kMirkFogOpacityNear,
      curlAmplitude: kMirkFogCurlAmplitude,
      curlScale: curlScale,
      lightDirRadians: kMirkFogLightDirRadians,
      lightOffset: kMirkFogLightOffset,
      lightStrength: kMirkFogLightStrength,
      hueNoiseScale: kMirkFogHueNoiseScale,
      hueStrength: kMirkFogHueStrength,
      boundarySharpDistance: kMirkFogBoundarySharpDistance,
      boundaryBleedDistance: kMirkFogBoundaryBleedDistance,
      boundaryEdgeBand: kMirkFogBoundaryEdgeBand,
      boundaryDensityBoost: kMirkFogBoundaryDensityBoost,
      sdfRect: FogShaderUniforms.identitySdfRect,
      sdfImage: sdfImage,
    );
  }
}

class FogLayer extends StatefulWidget {
  const FogLayer({
    required this.discRepository,
    required this.shader,
    required this.sdfCache,
    this.shaderRenderer = const _FragmentShaderFogRenderer(),
    super.key,
  });

  final RevealDiscRepository discRepository;
  final ui.FragmentShader? shader;
  final SdfCache<ui.Image> sdfCache;
  final FogShaderRenderer shaderRenderer;

  @visibleForTesting
  static VoidCallback? debugOnCameraRead;

  @override
  State<FogLayer> createState() => _FogLayerState();
}

class _FogLayerState extends State<FogLayer> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Stopwatch _wallClock = Stopwatch()..start();
  final _RepaintSignal _repaint = _RepaintSignal();
  ui.Image? _currentSdfImage;
  String? _currentSdfKey;
  String? _requestedSdfKey;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) => _repaint.notify());
    _ticker.start();
    widget.discRepository.addListener(_onDiscsChanged);
  }

  @override
  void didUpdateWidget(FogLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.discRepository, widget.discRepository)) {
      oldWidget.discRepository.removeListener(_onDiscsChanged);
      widget.discRepository.addListener(_onDiscsChanged);
      _requestedSdfKey = null;
      _currentSdfKey = null;
      _currentSdfImage = null;
    }
  }

  @override
  void dispose() {
    widget.discRepository.removeListener(_onDiscsChanged);
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _onDiscsChanged() {
    _requestedSdfKey = null;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    FogLayer.debugOnCameraRead?.call();
    final MapCamera camera = MapCamera.of(context);
    final viewport = viewportFromCamera(camera);
    final discs = widget.discRepository.snapshot();
    final sdfKey = SdfCacheKey.from(discs: discs, viewport: viewport).value;
    if (_requestedSdfKey != sdfKey) {
      _requestedSdfKey = sdfKey;
      unawaited(_resolveSdfImage(key: sdfKey, discs: discs, viewport: viewport));
    }

    return MobileLayerTransformer(
      child: CustomPaint(
        painter: _FogPainter(
          camera: camera,
          viewport: viewport,
          discs: discs,
          shader: widget.shader,
          sdfImage: _currentSdfKey == sdfKey ? _currentSdfImage : null,
          wallClock: _wallClock,
          shaderRenderer: widget.shaderRenderer,
          repaint: _repaint,
        ),
        size: Size(camera.size.x, camera.size.y),
      ),
    );
  }

  Future<void> _resolveSdfImage({required String key, required List<RevealDisc> discs, required MirkViewportBbox viewport}) async {
    try {
      final image = await widget.sdfCache.getOrBuild(discs: discs, viewport: viewport);
      if (!mounted || _requestedSdfKey != key) return;
      setState(() {
        _currentSdfKey = key;
        _currentSdfImage = image;
      });
    } on Object {
      if (!mounted || _requestedSdfKey != key) return;
      setState(() {
        _currentSdfKey = null;
        _currentSdfImage = null;
      });
    }
  }
}

@visibleForTesting
MirkViewportBbox viewportFromCamera(MapCamera camera) {
  final bounds = camera.visibleBounds;
  return MirkViewportBbox(south: bounds.south, west: bounds.west, north: bounds.north, east: bounds.east);
}

@visibleForTesting
SdfCache<ui.Image> createFogSdfCache() {
  const builder = RevealedSdfBuilder();
  return SdfCache<ui.Image>(
    buildImage: ({required List<RevealDisc> discs, required MirkViewportBbox viewport}) => builder.buildFromDiscs(discs: discs, viewport: viewport),
    disposeImage: (ui.Image image) => image.dispose(),
  );
}

class _RepaintSignal extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class _FogPainter extends CustomPainter {
  _FogPainter({
    required this.camera,
    required this.viewport,
    required this.discs,
    required this.shader,
    required this.sdfImage,
    required this.wallClock,
    required this.shaderRenderer,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final MapCamera camera;
  final MirkViewportBbox viewport;
  final List<RevealDisc> discs;
  final ui.FragmentShader? shader;
  final ui.Image? sdfImage;
  final Stopwatch wallClock;
  final FogShaderRenderer shaderRenderer;

  @override
  void paint(Canvas canvas, Size size) {
    final sdf = sdfImage;
    if (sdf == null || size.isEmpty) return;

    final timeSeconds = wallClock.elapsedMicroseconds / _microsecondsPerSecond;
    final curlScale = kMirkFogCurlScaleAnimationDefaultEnabled
        ? triangleWave(tSec: timeSeconds, period: kMirkFogCurlScaleAnimationPeriodSec, minV: kMirkFogCurlScaleAnimationMin, maxV: kMirkFogCurlScaleAnimationMax)
        : kMirkFogCurlScale;
    final clipPath = buildViewportFogClipPathFromDiscs(discs: discs, viewport: viewport, canvasSize: size);

    canvas.save();
    canvas.clipPath(clipPath);
    shaderRenderer.render(shader: shader, resolution: size, timeSeconds: timeSeconds, curlScale: curlScale, sdfImage: sdf);
    final liveShader = shader;
    if (liveShader != null) {
      canvas.drawRect(Offset.zero & size, Paint()..shader = liveShader);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FogPainter oldDelegate) {
    return !identical(oldDelegate.camera, camera) ||
        !identical(oldDelegate.discs, discs) ||
        !identical(oldDelegate.shader, shader) ||
        !identical(oldDelegate.sdfImage, sdfImage);
  }
}

const double _microsecondsPerSecond = 1000000.0;
