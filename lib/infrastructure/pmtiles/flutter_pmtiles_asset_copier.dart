// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/constants.dart';
import 'pmtiles_asset_copier.dart';

final Logger _log = Logger('infrastructure.pmtiles.flutter_asset');

Future<String> ensureFlutterPmtilesAssetCopied() {
  return PmtilesAssetCopier(
    assetLoader: () async {
      final Stopwatch stopwatch = Stopwatch()..start();
      _log.info('pmtiles_root_bundle_load_start asset=$kPmtilesAssetPath');
      try {
        final ByteData data = await rootBundle.load(kPmtilesAssetPath);
        final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        _log.info('pmtiles_root_bundle_load_success asset=$kPmtilesAssetPath bytes=${bytes.length} elapsedMs=${stopwatch.elapsedMilliseconds}');
        return bytes;
      } on Object catch (error, stackTrace) {
        _log.warning('pmtiles_root_bundle_load_failure asset=$kPmtilesAssetPath elapsedMs=${stopwatch.elapsedMilliseconds}', error, stackTrace);
        rethrow;
      }
    },
    supportDirectoryProvider: getApplicationSupportDirectory,
  ).ensureCopied();
}
