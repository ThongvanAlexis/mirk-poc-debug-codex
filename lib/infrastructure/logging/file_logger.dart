// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../config/constants.dart';

typedef FileLoggerClock = DateTime Function();

class FileLogger {
  FileLogger._();

  static final Logger _log = Logger('infrastructure.logging.file_logger');

  static StreamSubscription<LogRecord>? _subscription;
  static RandomAccessFile? _raf;
  static File? _activeLogFile;
  static FileLoggerClock _clock = DateTime.now;

  static String? get activeLogFilePath => _activeLogFile?.absolute.path;

  static Future<void> bootstrap({Directory? documentsDirectory, FileLoggerClock? clock, int maxLogsDirBytes = kMaxLogsDirBytes}) async {
    await disposeForTest();
    _clock = clock ?? DateTime.now;
    Logger.root.level = const bool.fromEnvironment('DEBUG') ? Level.ALL : Level.INFO;

    try {
      final Directory documents = documentsDirectory ?? await getApplicationDocumentsDirectory();
      final Directory logsDir = Directory(p.join(documents.path, 'logs'));
      await logsDir.create(recursive: true);

      final File activeFile = File(p.join(logsDir.path, '${_formatBasicUtc(_clock().toUtc())}_logs.txt'));
      _activeLogFile = activeFile;
      _raf = activeFile.openSync(mode: FileMode.writeOnlyAppend);
      await _pruneLogs(logsDir: logsDir, activeFile: activeFile, maxLogsDirBytes: maxLogsDirBytes);
      _subscription = Logger.root.onRecord.listen(_onRecord);
      _log.info('file_logger_bootstrap activePath=${activeFile.absolute.path} activeFilename=${p.basename(activeFile.path)}');
    } on FileSystemException {
      await disposeForTest();
      rethrow;
    }
  }

  static Future<List<File>> listLogFiles({Directory? documentsDirectory}) async {
    final Directory documents = documentsDirectory ?? await getApplicationDocumentsDirectory();
    final Directory logsDir = Directory(p.join(documents.path, 'logs'));
    if (!await logsDir.exists()) return <File>[];

    final List<_LogFileEntry> entries = <_LogFileEntry>[];
    await for (final FileSystemEntity entity in logsDir.list()) {
      if (entity is! File || !_isLogFile(entity)) continue;
      try {
        final FileStat stat = await entity.stat();
        entries.add(_LogFileEntry(file: entity, modified: stat.modified, length: stat.size));
      } on FileSystemException {
        // A log from another run may disappear while listing. It will be retried on next bootstrap.
      }
    }
    entries.sort((_LogFileEntry a, _LogFileEntry b) => a.modified.compareTo(b.modified));
    return entries.map((_LogFileEntry entry) => entry.file).toList(growable: false);
  }

  static Future<void> flush() async {
    // Durability is enforced per record by RandomAccessFile.flushSync().
  }

  static Future<void> disposeForTest() async {
    final RandomAccessFile? raf = _raf;
    _raf = null;
    _activeLogFile = null;
    if (raf != null) {
      try {
        raf.closeSync();
      } on FileSystemException {
        // Test/runtime cleanup should be idempotent.
      }
    }
    await _subscription?.cancel();
    _subscription = null;
  }

  static void _onRecord(LogRecord record) {
    final RandomAccessFile? raf = _raf;
    if (raf == null) return;

    final String line = '${jsonEncode(_entryFor(record))}\n';
    try {
      raf.writeStringSync(line);
      raf.flushSync();
    } on FileSystemException catch (error, stackTrace) {
      developer.log('FileLogger record write failed', name: 'infrastructure.logging.file_logger', error: error, stackTrace: stackTrace);
      _raf = null;
    }
  }

  static Map<String, Object?> _entryFor(LogRecord record) {
    final Map<String, Object?> entry = <String, Object?>{
      'ts': _clock().toUtc().toIso8601String(),
      'lvl': record.level.name,
      'logger': record.loggerName,
      'msg': record.message,
    };
    final Object? error = record.error;
    if (error != null) entry['error'] = error.toString();
    final StackTrace? stackTrace = record.stackTrace;
    if (stackTrace != null) entry['stack'] = stackTrace.toString();
    return entry;
  }

  static Future<void> _pruneLogs({required Directory logsDir, required File activeFile, required int maxLogsDirBytes}) async {
    final String activePath = activeFile.absolute.path;
    final List<_LogFileEntry> entries = <_LogFileEntry>[];

    await for (final FileSystemEntity entity in logsDir.list()) {
      if (entity is! File || !_isLogFile(entity)) continue;
      try {
        final FileStat stat = await entity.stat();
        entries.add(_LogFileEntry(file: entity, modified: stat.modified, length: stat.size));
      } on FileSystemException {
        // Best-effort prune; a disappearing file is harmless.
      }
    }

    var totalBytes = entries.fold<int>(0, (int total, _LogFileEntry entry) => total + entry.length);
    entries.sort((_LogFileEntry a, _LogFileEntry b) => a.modified.compareTo(b.modified));
    for (final _LogFileEntry entry in entries) {
      if (totalBytes <= maxLogsDirBytes) break;
      if (entry.file.absolute.path == activePath) continue;
      try {
        await entry.file.delete();
        totalBytes -= entry.length;
      } on FileSystemException {
        // Keep going; Windows may reject deletion of an open file from another run.
      }
    }
  }

  static bool _isLogFile(File file) {
    final String extension = p.extension(file.path).toLowerCase();
    return extension == '.txt' || file.path.toLowerCase().endsWith('.txt.gz');
  }

  static String _formatBasicUtc(DateTime utc) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}T${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }
}

class _LogFileEntry {
  const _LogFileEntry({required this.file, required this.modified, required this.length});

  final File file;
  final DateTime modified;
  final int length;
}
