// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/config/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Fra_Melun.pmtile is bundled with expected size and SHA-256', () async {
    final ByteData data = await rootBundle.load(kPmtilesAssetPath);
    final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    expect(bytes.length, equals(kPmtilesExpectedByteLength));
    expect(sha256.convert(bytes).toString(), equals(kPmtilesExpectedSha256));
  });
}
