// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';
import 'dart:ui' show TimingsCallback;

import 'package:logging/logging.dart';
import 'package:mirk_poc_debug/infrastructure/logging/frame_timing_logger.dart';
import 'package:test/test.dart';

void main() {
  test('aggregates frame timings into summary records by mode', () async {
    final List<TimingsCallback> callbacks = <TimingsCallback>[];
    final List<TimingsCallback> removedCallbacks = <TimingsCallback>[];
    final List<LogRecord> records = <LogRecord>[];
    final StreamSubscription<LogRecord> subscription = Logger.root.onRecord.listen(records.add);
    Logger.root.level = Level.ALL;

    final logger = FrameTimingLogger(
      modeProvider: () => 'mapWithFog',
      addTimingsCallback: callbacks.add,
      removeTimingsCallback: removedCallbacks.add,
      logger: Logger('test.frame_timing'),
      sampleBatchSize: 2,
    );

    logger.start();
    expect(callbacks, hasLength(1));
    logger.recordSamples(<FrameTimingSample>[
      const FrameTimingSample(buildDuration: Duration(milliseconds: 4), rasterDuration: Duration(milliseconds: 10)),
      const FrameTimingSample(buildDuration: Duration(milliseconds: 6), rasterDuration: Duration(milliseconds: 12)),
    ]);
    logger.stop();
    await subscription.cancel();

    expect(removedCallbacks, callbacks);
    expect(records.map((LogRecord record) => record.message), anyElement(contains('frame_timing_summary reason=batch mode=mapWithFog frames=2')));
  });
}
