// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/scheduler.dart';
import 'package:logging/logging.dart';

typedef FrameTimingModeProvider = String Function();
typedef FrameTimingCallbackRegistrar = void Function(TimingsCallback callback);

class FrameTimingLogger {
  FrameTimingLogger({
    FrameTimingModeProvider modeProvider = _defaultModeProvider,
    FrameTimingCallbackRegistrar? addTimingsCallback,
    FrameTimingCallbackRegistrar? removeTimingsCallback,
    Logger? logger,
    this.sampleBatchSize = 60,
  }) : _modeProvider = modeProvider,
       _addTimingsCallback = addTimingsCallback ?? SchedulerBinding.instance.addTimingsCallback,
       _removeTimingsCallback = removeTimingsCallback ?? SchedulerBinding.instance.removeTimingsCallback,
       _log = logger ?? Logger('infrastructure.logging.frame_timing');

  final FrameTimingModeProvider _modeProvider;
  final FrameTimingCallbackRegistrar _addTimingsCallback;
  final FrameTimingCallbackRegistrar _removeTimingsCallback;
  final Logger _log;
  final int sampleBatchSize;

  bool _started = false;
  int _sampleCount = 0;
  int _totalBuildMicros = 0;
  int _totalRasterMicros = 0;
  int _worstFrameMicros = 0;

  void start() {
    if (_started) return;
    _started = true;
    _addTimingsCallback(_onTimings);
    _log.info('frame_timing_start mode=${_modeProvider()} batchSize=$sampleBatchSize');
  }

  void stop() {
    if (!_started) return;
    _removeTimingsCallback(_onTimings);
    flush(reason: 'stop');
    _started = false;
    _log.info('frame_timing_stop mode=${_modeProvider()}');
  }

  void recordSamples(Iterable<FrameTimingSample> samples) {
    for (final FrameTimingSample sample in samples) {
      _sampleCount += 1;
      _totalBuildMicros += sample.buildDuration.inMicroseconds;
      _totalRasterMicros += sample.rasterDuration.inMicroseconds;
      final int frameMicros = sample.buildDuration.inMicroseconds + sample.rasterDuration.inMicroseconds;
      if (frameMicros > _worstFrameMicros) _worstFrameMicros = frameMicros;
    }
    if (_sampleCount >= sampleBatchSize) {
      flush(reason: 'batch');
    }
  }

  void flush({String reason = 'manual'}) {
    if (_sampleCount == 0) return;
    final double averageBuildMs = _totalBuildMicros / _sampleCount / 1000.0;
    final double averageRasterMs = _totalRasterMicros / _sampleCount / 1000.0;
    final double worstFrameMs = _worstFrameMicros / 1000.0;
    _log.info(
      'frame_timing_summary reason=$reason mode=${_modeProvider()} frames=$_sampleCount '
      'avgBuildMs=${averageBuildMs.toStringAsFixed(2)} avgRasterMs=${averageRasterMs.toStringAsFixed(2)} '
      'worstFrameMs=${worstFrameMs.toStringAsFixed(2)}',
    );
    _sampleCount = 0;
    _totalBuildMicros = 0;
    _totalRasterMicros = 0;
    _worstFrameMicros = 0;
  }

  void _onTimings(List<FrameTiming> timings) {
    recordSamples(timings.map(FrameTimingSample.fromFrameTiming));
  }

  static String _defaultModeProvider() => 'unknown';
}

class FrameTimingSample {
  const FrameTimingSample({required this.buildDuration, required this.rasterDuration});

  factory FrameTimingSample.fromFrameTiming(FrameTiming timing) {
    return FrameTimingSample(buildDuration: timing.buildDuration, rasterDuration: timing.rasterDuration);
  }

  final Duration buildDuration;
  final Duration rasterDuration;
}
