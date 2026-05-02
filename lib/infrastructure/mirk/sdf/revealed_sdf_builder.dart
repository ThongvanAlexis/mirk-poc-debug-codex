// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async' show Completer;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';

/// Builds the viewport signed-distance field consumed by the atmospheric fog shader.
///
/// The RGBA texture is always [kMirkFogSdfResolution] square. R/G/B use the
/// parent MirkFall midpoint-128 signed distance convention:
/// values below 128 are revealed area, 128 is the reveal boundary, and 255 is
/// saturated unrevealed fog. Alpha is always 255.
class RevealedSdfBuilder {
  const RevealedSdfBuilder();

  static const int resolution = kMirkFogSdfResolution;

  Future<ui.Image> buildFromDiscs({required Iterable<RevealDisc> discs, required MirkViewportBbox viewport}) async {
    final pixels = buildRgbaBytesFromDiscs(discs: discs, viewport: viewport);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(pixels, resolution, resolution, ui.PixelFormat.rgba8888, completer.complete);
    return completer.future;
  }

  Uint8List buildRgbaBytesFromDiscs({required Iterable<RevealDisc> discs, required MirkViewportBbox viewport}) {
    final discList = discs.toList(growable: false);
    if (discList.isEmpty) return _allFogPixels();

    final dLat = viewport.north - viewport.south;
    final dLon = viewport.longitudeSpanDegrees;
    if (dLat <= 0.0 || dLon <= 0.0) return _allFogPixels();

    final meanLatRad = (viewport.south + viewport.north) * 0.5 * math.pi / 180.0;
    final metersPerDegreeLon = kMetersPerDegreeLat * math.cos(meanLatRad);
    if (metersPerDegreeLon <= 0.0) return _allFogPixels();

    final metersPerPixelY = (dLat * kMetersPerDegreeLat) / resolution;
    final metersPerPixelX = (dLon * metersPerDegreeLon) / resolution;
    if (metersPerPixelX <= 0.0 || metersPerPixelY <= 0.0) return _allFogPixels();

    final metersPerPixel = math.sqrt(metersPerPixelX * metersPerPixelY);
    final distMaxPixels = resolution * 0.5;
    final signed = Float32List(resolution * resolution);
    for (var i = 0; i < signed.length; i++) {
      signed[i] = 1e9;
    }

    for (final disc in discList) {
      if (!disc.intersectsBbox(viewport)) continue;

      final cx = (viewport.normalizeLongitudeForProjection(disc.lon) - viewport.projectionWest) / dLon * resolution;
      final cy = (viewport.north - disc.lat) / dLat * resolution;
      final paddedMeters = disc.radiusMeters + distMaxPixels * metersPerPixel;
      final xPadPixels = paddedMeters / metersPerPixelX;
      final yPadPixels = paddedMeters / metersPerPixelY;
      final xMin = math.max(0, (cx - xPadPixels).floor());
      final xMax = math.min(resolution, (cx + xPadPixels).ceil());
      final yMin = math.max(0, (cy - yPadPixels).floor());
      final yMax = math.min(resolution, (cy + yPadPixels).ceil());
      if (xMin >= xMax || yMin >= yMax) continue;

      for (var y = yMin; y < yMax; y++) {
        final dy = (y + 0.5) - cy;
        final dyMeters = dy * metersPerPixelY;
        final rowOffset = y * resolution;
        for (var x = xMin; x < xMax; x++) {
          final dx = (x + 0.5) - cx;
          final dxMeters = dx * metersPerPixelX;
          final distMeters = math.sqrt(dxMeters * dxMeters + dyMeters * dyMeters);
          final candidate = (distMeters - disc.radiusMeters) / metersPerPixel;
          final index = rowOffset + x;
          if (candidate < signed[index]) signed[index] = candidate;
        }
      }
    }

    final pixels = Uint8List(resolution * resolution * 4);
    for (var i = 0; i < signed.length; i++) {
      final clamped = _clampDouble(signed[i], -distMaxPixels, distMaxPixels);
      final byte = _clampDouble(128.0 + (clamped / distMaxPixels) * 127.0, 0.0, 255.0).toInt();
      final pixelIndex = i * 4;
      pixels[pixelIndex] = byte;
      pixels[pixelIndex + 1] = byte;
      pixels[pixelIndex + 2] = byte;
      pixels[pixelIndex + 3] = 255;
    }
    return pixels;
  }

  Uint8List _allFogPixels() {
    final pixels = Uint8List(resolution * resolution * 4);
    for (var i = 0; i < resolution * resolution; i++) {
      final pixelIndex = i * 4;
      pixels[pixelIndex] = 255;
      pixels[pixelIndex + 1] = 255;
      pixels[pixelIndex + 2] = 255;
      pixels[pixelIndex + 3] = 255;
    }
    return pixels;
  }
}

double _clampDouble(double value, double low, double high) {
  if (value < low) return low;
  if (value > high) return high;
  return value;
}
