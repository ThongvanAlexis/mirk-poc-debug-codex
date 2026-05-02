// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/infrastructure/logging/file_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory documentsDir;

  setUp(() {
    documentsDir = Directory.systemTemp.createTempSync('mirk_file_logger_test_');
  });

  tearDown(() async {
    await FileLogger.disposeForTest();
    if (documentsDir.existsSync()) {
      documentsDir.deleteSync(recursive: true);
    }
  });

  test('bootstraps a UTC-basic JSONL file under documents logs', () async {
    await FileLogger.bootstrap(documentsDirectory: documentsDir, clock: () => DateTime.utc(2026, 5, 2, 12, 34, 56, 789));

    final String activePath = FileLogger.activeLogFilePath!;
    expect(activePath, endsWith(p.join('logs', '20260502T123456Z_logs.txt')));

    Logger('test.file_logger').info('hello');
    final List<String> lines = File(activePath).readAsLinesSync();
    final Map<String, Object?> record = jsonDecode(lines.last) as Map<String, Object?>;
    expect(record['ts'], '2026-05-02T12:34:56.789Z');
    expect(record['lvl'], 'INFO');
    expect(record['logger'], 'test.file_logger');
    expect(record['msg'], 'hello');
  });

  test('uses synchronous RandomAccessFile writes and avoids broad logger recursion paths', () {
    final String source = File(p.join('lib', 'infrastructure', 'logging', 'file_logger.dart')).readAsStringSync();

    expect(source, contains('RandomAccessFile'));
    expect(source, contains('writeStringSync'));
    expect(source, contains('flushSync'));
    expect(source, contains('on FileSystemException catch'));
    expect(source, contains('developer.log'));
    expect(source, isNot(contains('IOSink')));
    expect(source, isNot(contains('catch (Object')));
  });

  test('prunes inactive logs without deleting the active file', () async {
    final Directory logsDir = Directory(p.join(documentsDir.path, 'logs'))..createSync(recursive: true);
    final File oldest = File(p.join(logsDir.path, '20260502T000001Z_logs.txt'))..writeAsBytesSync(List<int>.filled(8, 1), flush: true);
    final File newer = File(p.join(logsDir.path, '20260502T000002Z_logs.txt'))..writeAsBytesSync(List<int>.filled(8, 2), flush: true);
    oldest.setLastModifiedSync(DateTime.utc(2026, 5, 2, 0, 0, 1));
    newer.setLastModifiedSync(DateTime.utc(2026, 5, 2, 0, 0, 2));

    await FileLogger.bootstrap(documentsDirectory: documentsDir, clock: () => DateTime.utc(2026, 5, 2, 0, 0, 3), maxLogsDirBytes: 9);

    expect(FileLogger.activeLogFilePath, isNotNull);
    expect(File(FileLogger.activeLogFilePath!).existsSync(), isTrue);
    expect(oldest.existsSync(), isFalse);
    expect(newer.existsSync(), isTrue);
  });

  test('locks the log directory cap constant', () {
    expect(kMaxLogsDirBytes, 10 * 1024 * 1024);
  });

  test('lifecycle observer flushes non-resumed app states only', () {
    final String source = File(p.join('lib', 'infrastructure', 'logging', 'file_logger_lifecycle_observer.dart')).readAsStringSync();

    expect(source, contains('extends WidgetsBindingObserver'));
    expect(source, contains('if (state == AppLifecycleState.resumed) return;'));
    expect(source, contains('unawaited(_flushCallback())'));
    expect(source, contains('app_lifecycle_flush'));
  });
}
