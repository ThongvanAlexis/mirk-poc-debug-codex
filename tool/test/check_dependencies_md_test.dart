// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../check_dependencies_md.dart' as check_dependencies_md;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('check_dependencies_md_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('accepts documented hosted packages and ignores SDK packages', () async {
    _writeLockfile(tempDir, hostedPackages: <String, String>{'alpha': '1.2.3', 'beta': '4.5.6'}, includeFlutterSdk: true);
    _writeDependencies(tempDir, rows: <String, String>{'alpha': '1.2.3', 'beta': '4.5.6'}, includeFlutterSdk: true);

    expect(await check_dependencies_md.runCheck(<String>[tempDir.path]), equals(0));
  });

  test('rejects missing dependency rows', () async {
    _writeLockfile(tempDir, hostedPackages: <String, String>{'alpha': '1.2.3', 'beta': '4.5.6'});
    _writeDependencies(tempDir, rows: <String, String>{'alpha': '1.2.3'});

    expect(await check_dependencies_md.runCheck(<String>[tempDir.path]), equals(1));
  });

  test('rejects stale dependency versions', () async {
    _writeLockfile(tempDir, hostedPackages: <String, String>{'alpha': '1.2.3'});
    _writeDependencies(tempDir, rows: <String, String>{'alpha': '1.2.4'});

    expect(await check_dependencies_md.runCheck(<String>[tempDir.path]), equals(1));
  });
}

void _writeLockfile(Directory repo, {required Map<String, String> hostedPackages, bool includeFlutterSdk = false}) {
  final StringBuffer buffer = StringBuffer('packages:\n');
  for (final MapEntry<String, String> package in hostedPackages.entries) {
    buffer
      ..writeln('  ${package.key}:')
      ..writeln('    dependency: transitive')
      ..writeln('    description:')
      ..writeln('      name: ${package.key}')
      ..writeln('      url: "https://pub.dev"')
      ..writeln('    source: hosted')
      ..writeln('    version: "${package.value}"');
  }
  if (includeFlutterSdk) {
    buffer
      ..writeln('  flutter:')
      ..writeln('    dependency: "direct main"')
      ..writeln('    description: flutter')
      ..writeln('    source: sdk')
      ..writeln('    version: "0.0.0"');
  }
  File(p.join(repo.path, 'pubspec.lock')).writeAsStringSync(buffer.toString());
}

void _writeDependencies(Directory repo, {required Map<String, String> rows, bool includeFlutterSdk = false}) {
  final StringBuffer buffer = StringBuffer(
    '# Dependency Audit\n\n'
    '## Direct Dependencies\n\n'
    '| Package | Version | License | Source | Telemetry | Transitive licenses | Maintenance | Platform | Audit date |\n'
    '| --- | --- | --- | --- | --- | --- | --- | --- | --- |\n',
  );
  for (final MapEntry<String, String> row in rows.entries) {
    buffer.writeln('| ${row.key} | ${row.value} | MIT | pub.dev | None | Verified | Active | Dart | 2026-05-02 |');
  }
  if (includeFlutterSdk) {
    buffer.writeln('| flutter | (SDK) | BSD-3-Clause | Flutter SDK | None | SDK | Active | Flutter | 2026-05-02 |');
  }
  File(p.join(repo.path, 'DEPENDENCIES.md')).writeAsStringSync(buffer.toString());
}
