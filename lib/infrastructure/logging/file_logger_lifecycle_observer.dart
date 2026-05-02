// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'file_logger.dart';

typedef FileLoggerFlushCallback = Future<void> Function();

class FileLoggerLifecycleObserver extends WidgetsBindingObserver {
  FileLoggerLifecycleObserver({FileLoggerFlushCallback flushCallback = FileLogger.flush}) : _flushCallback = flushCallback;

  static final Logger _log = Logger('infrastructure.logging.lifecycle');

  final FileLoggerFlushCallback _flushCallback;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) return;
    _log.info('app_lifecycle_flush state=${state.name}');
    unawaited(_flushCallback());
  }
}
