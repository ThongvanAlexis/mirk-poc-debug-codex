// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:logging/logging.dart';
import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';

typedef SdfCacheBuilder<T extends Object> = Future<T> Function({required List<RevealDisc> discs, required MirkViewportBbox viewport});
typedef SdfCacheDisposer<T extends Object> = void Function(T image);

/// Small deterministic cache for viewport SDF images.
///
/// The class is generic so cache semantics stay pure-Dart testable. The fog
/// layer can use `SdfCache<ui.Image>` with `disposeImage: (image) => image.dispose()`.
class SdfCache<T extends Object> {
  SdfCache({required SdfCacheBuilder<T> buildImage, SdfCacheDisposer<T>? disposeImage}) : _buildImage = buildImage, _disposeImage = disposeImage;

  static final Logger _log = Logger('infrastructure.mirk.sdf_cache');

  final SdfCacheBuilder<T> _buildImage;
  final SdfCacheDisposer<T>? _disposeImage;
  final Map<String, Future<T>> _inFlight = <String, Future<T>>{};

  String? _cachedKey;
  T? _cachedImage;
  bool _disposed = false;

  Future<T> getOrBuild({required Iterable<RevealDisc> discs, required MirkViewportBbox viewport}) {
    if (_disposed) throw StateError('SdfCache has been disposed');

    final discSnapshot = discs.toList(growable: false);
    final key = SdfCacheKey.from(discs: discSnapshot, viewport: viewport).value;
    final keyMarker = _keyMarker(key);
    final cachedImage = _cachedImage;
    if (cachedImage != null && _cachedKey == key) {
      _log.fine('sdf_cache_hit key=$keyMarker discCount=${discSnapshot.length}');
      return Future<T>.value(cachedImage);
    }

    final inFlight = _inFlight[key];
    if (inFlight != null) {
      _log.fine('sdf_cache_in_flight key=$keyMarker discCount=${discSnapshot.length}');
      return inFlight;
    }

    late final Future<T> future;
    final Stopwatch stopwatch = Stopwatch()..start();
    _log.info('sdf_build_start key=$keyMarker discCount=${discSnapshot.length}');
    future = _buildImage(discs: discSnapshot, viewport: viewport)
        .then(
          (image) {
            stopwatch.stop();
            if (_disposed) {
              _dispose(image);
              throw StateError('SdfCache was disposed before the SDF build completed');
            }

            final previousImage = _cachedImage;
            if (previousImage != null && !identical(previousImage, image)) _dispose(previousImage);
            _cachedKey = key;
            _cachedImage = image;
            _log.info('sdf_build_success key=$keyMarker discCount=${discSnapshot.length} elapsedMs=${stopwatch.elapsedMilliseconds}');
            return image;
          },
          onError: (Object error, StackTrace stackTrace) {
            stopwatch.stop();
            _log.warning('sdf_build_failure key=$keyMarker discCount=${discSnapshot.length} elapsedMs=${stopwatch.elapsedMilliseconds}', error, stackTrace);
            Error.throwWithStackTrace(error, stackTrace);
          },
        )
        .whenComplete(() {
          if (identical(_inFlight[key], future)) _inFlight.remove(key);
        });
    _inFlight[key] = future;
    return future;
  }

  void clear() {
    final cachedImage = _cachedImage;
    _cachedImage = null;
    _cachedKey = null;
    if (cachedImage != null) _dispose(cachedImage);
  }

  void dispose() {
    _disposed = true;
    clear();
    _inFlight.clear();
  }

  void _dispose(T image) {
    _disposeImage?.call(image);
  }

  static String _keyMarker(String key) => key.hashCode.toUnsigned(32).toRadixString(16);
}

class SdfCacheKey {
  const SdfCacheKey._(this.value);

  final String value;

  factory SdfCacheKey.from({required Iterable<RevealDisc> discs, required MirkViewportBbox viewport}) {
    final discKeys = discs.map(_discKey).toList(growable: false)..sort();
    return SdfCacheKey._(
      <String>[viewport.south.toString(), viewport.west.toString(), viewport.north.toString(), viewport.east.toString(), ...discKeys].join('|'),
    );
  }

  static String _discKey(RevealDisc disc) {
    return <String>[
      disc.id,
      disc.sessionId,
      disc.lat.toString(),
      disc.lon.toString(),
      disc.radiusMeters.toString(),
      disc.fixedAtUtc.toUtc().microsecondsSinceEpoch.toString(),
    ].join(',');
  }
}
