// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../config/constants.dart';

typedef PmtilesAssetLoader = Future<Uint8List> Function();
typedef PmtilesSupportDirectoryProvider = Future<Directory> Function();

class PmtilesAssetCopyException implements Exception {
  const PmtilesAssetCopyException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null ? 'PmtilesAssetCopyException: $message' : 'PmtilesAssetCopyException: $message ($cause)';
}

class PmtilesAssetCopier {
  const PmtilesAssetCopier({required PmtilesAssetLoader assetLoader, required PmtilesSupportDirectoryProvider supportDirectoryProvider})
    : _assetLoader = assetLoader,
      _supportDirectoryProvider = supportDirectoryProvider;

  static final Logger _log = Logger('infrastructure.pmtiles');

  final PmtilesAssetLoader _assetLoader;
  final PmtilesSupportDirectoryProvider _supportDirectoryProvider;

  Future<String> ensureCopied() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    _log.info('pmtiles_copy_start asset=$kPmtilesBasename expectedBytes=$kPmtilesExpectedByteLength');
    try {
      final Directory supportDir = await _supportDirectoryProvider();
      final Directory mapsDir = Directory(p.join(supportDir.path, kPmtilesMapsSubdir));
      await mapsDir.create(recursive: true);

      final File destination = File(p.join(mapsDir.path, kPmtilesBasename));
      if (await _isValidFile(destination)) {
        _log.info(
          'pmtiles_copy_skip_valid basename=${p.basename(destination.path)} bytes=$kPmtilesExpectedByteLength elapsedMs=${stopwatch.elapsedMilliseconds}',
        );
        return destination.absolute.path;
      }

      final Uint8List bytes = await _assetLoader();
      _log.info('pmtiles_asset_loaded basename=$kPmtilesBasename bytes=${bytes.length} elapsedMs=${stopwatch.elapsedMilliseconds}');
      _validateBytes(bytes, 'bundled asset');

      final File temp = File('${destination.path}.tmp');
      if (await temp.exists()) {
        await temp.delete();
      }
      await temp.writeAsBytes(bytes, flush: true);

      if (!await _isValidFile(temp)) {
        throw const PmtilesAssetCopyException('Temporary PMTiles copy failed validation.');
      }

      if (await destination.exists()) {
        await destination.delete();
      }
      final File copied = await temp.rename(destination.path);
      _log.info('pmtiles_copy_success basename=${p.basename(copied.path)} bytes=${bytes.length} elapsedMs=${stopwatch.elapsedMilliseconds}');
      return copied.absolute.path;
    } on PmtilesAssetCopyException catch (error, stackTrace) {
      _log.warning('pmtiles_copy_failure elapsedMs=${stopwatch.elapsedMilliseconds} reason=${error.message}', error, stackTrace);
      rethrow;
    } on Object catch (error, stackTrace) {
      _log.warning('pmtiles_copy_failure elapsedMs=${stopwatch.elapsedMilliseconds}', error, stackTrace);
      throw PmtilesAssetCopyException('Could not copy PMTiles asset to app support.', error);
    }
  }

  Future<bool> _isValidFile(File file) async {
    if (!await file.exists()) {
      return false;
    }
    final int length = await file.length();
    if (length != kPmtilesExpectedByteLength) {
      return false;
    }
    final Uint8List bytes = await file.readAsBytes();
    return _sha256Hex(bytes) == kPmtilesExpectedSha256;
  }

  void _validateBytes(Uint8List bytes, String label) {
    if (bytes.length != kPmtilesExpectedByteLength) {
      throw PmtilesAssetCopyException('$label has ${bytes.length} bytes, expected $kPmtilesExpectedByteLength.');
    }
    final String hash = _sha256Hex(bytes);
    if (hash != kPmtilesExpectedSha256) {
      throw PmtilesAssetCopyException('$label SHA-256 mismatch: $hash.');
    }
  }

  String _sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();
}
