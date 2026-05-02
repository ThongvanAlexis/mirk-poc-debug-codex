// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../check_headers.dart' as check_headers;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('check_headers_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('accepts Dart files with the required GOSL header', () async {
    File(p.join(tempDir.path, 'valid.dart')).writeAsStringSync('${check_headers.expectedHeader}\n\nvoid main() {}\n');

    expect(await check_headers.runCheck(<String>[tempDir.path]), equals(0));
  });

  test('rejects Dart files without the required GOSL header', () async {
    File(p.join(tempDir.path, 'missing.dart')).writeAsStringSync('void main() {}\n');

    expect(await check_headers.runCheck(<String>[tempDir.path]), equals(1));
  });

  test('ignores generated Dart files', () async {
    File(p.join(tempDir.path, 'ignored.g.dart')).writeAsStringSync('void main() {}\n');

    expect(await check_headers.runCheck(<String>[tempDir.path]), equals(0));
  });
}
