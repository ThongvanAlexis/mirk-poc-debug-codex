// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:mirk_poc_debug/config/constants.dart';
import 'package:mirk_poc_debug/infrastructure/pmtiles/pmtiles_asset_copier.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late Uint8List validBytes;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pmtiles_asset_copier_test_');
    validBytes = File(kPmtilesAssetPath).readAsBytesSync();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  PmtilesAssetCopier buildCopier({Uint8List? assetBytes, Directory? supportDir}) {
    final Uint8List bytes = assetBytes ?? validBytes;
    return PmtilesAssetCopier(assetLoader: () async => bytes, supportDirectoryProvider: () async => supportDir ?? tempDir);
  }

  test('first copy writes asset bytes under <support>/maps/Fra_Melun.pmtile and returns an absolute path', () async {
    final String copiedPath = await buildCopier().ensureCopied();

    expect(p.isAbsolute(copiedPath), isTrue);
    expect(copiedPath, equals(p.join(tempDir.path, kPmtilesMapsSubdir, kPmtilesBasename)));
    expect(File(copiedPath).existsSync(), isTrue);
    expect(File(copiedPath).lengthSync(), equals(kPmtilesExpectedByteLength));
    expect(_sha256Hex(File(copiedPath).readAsBytesSync()), equals(kPmtilesExpectedSha256));
  });

  test('valid existing copy is returned without rewriting', () async {
    final PmtilesAssetCopier copier = buildCopier();
    final String firstPath = await copier.ensureCopied();
    final DateTime before = File(firstPath).statSync().modified;

    await Future<void>.delayed(const Duration(milliseconds: 20));
    final String secondPath = await copier.ensureCopied();

    expect(secondPath, equals(firstPath));
    expect(File(secondPath).statSync().modified, equals(before));
  });

  test('truncated destination is rewritten through validation path', () async {
    final PmtilesAssetCopier copier = buildCopier();
    final String copiedPath = await copier.ensureCopied();
    File(copiedPath).writeAsBytesSync(<int>[0x00], flush: true);

    final String repairedPath = await copier.ensureCopied();

    expect(repairedPath, equals(copiedPath));
    expect(_sha256Hex(File(repairedPath).readAsBytesSync()), equals(kPmtilesExpectedSha256));
  });

  test('same-size corrupt destination is rewritten', () async {
    final PmtilesAssetCopier copier = buildCopier();
    final String copiedPath = await copier.ensureCopied();
    final Uint8List corrupt = Uint8List.fromList(validBytes);
    corrupt[0] = corrupt[0] ^ 0xFF;
    File(copiedPath).writeAsBytesSync(corrupt, flush: true);

    final String repairedPath = await copier.ensureCopied();

    expect(repairedPath, equals(copiedPath));
    expect(_sha256Hex(File(repairedPath).readAsBytesSync()), equals(kPmtilesExpectedSha256));
  });

  test('invalid bundled bytes fail with typed exception before destination is trusted', () async {
    await expectLater(buildCopier(assetBytes: Uint8List.fromList(<int>[0x50, 0x4D, 0x54, 0x49])).ensureCopied(), throwsA(isA<PmtilesAssetCopyException>()));
  });

  test('filesystem failures propagate as typed exceptions', () async {
    final Directory blockedSupportDir = Directory(p.join(tempDir.path, 'blocked'));
    File(blockedSupportDir.path).writeAsStringSync('not a directory');

    await expectLater(buildCopier(supportDir: blockedSupportDir).ensureCopied(), throwsA(isA<PmtilesAssetCopyException>()));
  });
}

String _sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();
