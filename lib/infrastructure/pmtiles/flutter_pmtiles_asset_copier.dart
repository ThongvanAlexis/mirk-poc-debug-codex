// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/constants.dart';
import 'pmtiles_asset_copier.dart';

Future<String> ensureFlutterPmtilesAssetCopied() {
  return PmtilesAssetCopier(
    assetLoader: () async {
      final ByteData data = await rootBundle.load(kPmtilesAssetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    },
    supportDirectoryProvider: getApplicationSupportDirectory,
  ).ensureCopied();
}
