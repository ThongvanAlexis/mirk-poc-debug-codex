// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';

import 'package:mirk_poc_debug/domain/mirk/mirk_viewport_bbox.dart';
import 'package:mirk_poc_debug/domain/revealed/reveal_disc.dart';
import 'package:mirk_poc_debug/infrastructure/mirk/sdf/sdf_cache.dart';
import 'package:test/test.dart';

void main() {
  final fixedAt = DateTime.utc(2026, 5, 2, 10);
  const viewport = MirkViewportBbox(south: 48.5387, west: 2.6533, north: 48.5407, east: 2.6573);

  RevealDisc disc(String id, {double radiusMeters = 25.0}) {
    return RevealDisc(id: id, sessionId: 'session_test', lat: 48.5397, lon: 2.6553, radiusMeters: radiusMeters, fixedAtUtc: fixedAt);
  }

  test('deduplicates concurrent builds for identical disc and viewport keys', () async {
    var buildCount = 0;
    final completer = Completer<_FakeSdfImage>();
    final cache = SdfCache<_FakeSdfImage>(
      buildImage: ({required List<RevealDisc> discs, required MirkViewportBbox viewport}) {
        buildCount++;
        return completer.future;
      },
    );

    final first = cache.getOrBuild(discs: <RevealDisc>[disc('a')], viewport: viewport);
    final second = cache.getOrBuild(discs: <RevealDisc>[disc('a')], viewport: viewport);
    final image = _FakeSdfImage('image');
    completer.complete(image);

    expect(await first, same(image));
    expect(await second, same(image));
    expect(buildCount, equals(1));
  });

  test('uses a deterministic key independent of disc iteration order', () async {
    var buildCount = 0;
    final image = _FakeSdfImage('cached');
    final cache = SdfCache<_FakeSdfImage>(
      buildImage: ({required List<RevealDisc> discs, required MirkViewportBbox viewport}) async {
        buildCount++;
        return image;
      },
    );

    expect(await cache.getOrBuild(discs: <RevealDisc>[disc('b'), disc('a')], viewport: viewport), same(image));
    expect(await cache.getOrBuild(discs: <RevealDisc>[disc('a'), disc('b')], viewport: viewport), same(image));
    expect(buildCount, equals(1));
  });

  test('disposes the previous cached value when a new key wins', () async {
    final images = <_FakeSdfImage>[_FakeSdfImage('first'), _FakeSdfImage('second')];
    var buildCount = 0;
    final cache = SdfCache<_FakeSdfImage>(
      buildImage: ({required List<RevealDisc> discs, required MirkViewportBbox viewport}) async => images[buildCount++],
      disposeImage: (image) => image.dispose(),
    );

    expect(await cache.getOrBuild(discs: <RevealDisc>[disc('a')], viewport: viewport), same(images[0]));
    expect(await cache.getOrBuild(discs: <RevealDisc>[disc('a', radiusMeters: 30.0)], viewport: viewport), same(images[1]));
    expect(images[0].disposed, isTrue);
    expect(images[1].disposed, isFalse);
  });

  test('clear disposes the cached image', () async {
    final image = _FakeSdfImage('cached');
    final cache = SdfCache<_FakeSdfImage>(
      buildImage: ({required List<RevealDisc> discs, required MirkViewportBbox viewport}) async => image,
      disposeImage: (cachedImage) => cachedImage.dispose(),
    );

    await cache.getOrBuild(discs: <RevealDisc>[disc('a')], viewport: viewport);
    cache.clear();

    expect(image.disposed, isTrue);
  });
}

class _FakeSdfImage {
  _FakeSdfImage(this.label);

  final String label;
  bool disposed = false;

  void dispose() {
    disposed = true;
  }
}
