// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../check_licenses.dart' as check_licenses;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('check_licenses_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('accepts packages with allowed SPDX licenses', () async {
    _writeRepo(
      tempDir,
      packages: <_PackageFixture>[_PackageFixture(name: 'allowed', version: '1.0.0', pubspecLicense: 'MIT')],
    );

    expect(await check_licenses.runCheck(<String>[tempDir.path]), equals(0));
  });

  test('rejects forbidden license markers in license files', () async {
    _writeRepo(
      tempDir,
      packages: <_PackageFixture>[_PackageFixture(name: 'forbidden', version: '1.0.0', licenseText: 'GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007\n')],
    );

    expect(await check_licenses.runCheck(<String>[tempDir.path]), equals(1));
  });

  test('rejects denied telemetry, ads, and MapLibre package names', () async {
    _writeRepo(
      tempDir,
      packages: <_PackageFixture>[_PackageFixture(name: 'maplibre_gl', version: '1.0.0', pubspecLicense: 'BSD-3-Clause')],
    );

    expect(await check_licenses.runCheck(<String>[tempDir.path]), equals(1));
  });

  test('rejects packages whose license cannot be resolved', () async {
    _writeRepo(
      tempDir,
      packages: <_PackageFixture>[_PackageFixture(name: 'unresolved', version: '1.0.0')],
    );

    expect(await check_licenses.runCheck(<String>[tempDir.path]), equals(1));
  });
}

void _writeRepo(Directory repo, {required List<_PackageFixture> packages}) {
  final Directory dartTool = Directory(p.join(repo.path, '.dart_tool'))..createSync(recursive: true);
  final StringBuffer lock = StringBuffer('packages:\n');
  final List<Map<String, String>> packageConfigEntries = <Map<String, String>>[];

  for (final _PackageFixture package in packages) {
    lock
      ..writeln('  ${package.name}:')
      ..writeln('    dependency: transitive')
      ..writeln('    description:')
      ..writeln('      name: ${package.name}')
      ..writeln('      url: "https://pub.dev"')
      ..writeln('    source: hosted')
      ..writeln('    version: "${package.version}"');

    final Directory packageDir = Directory(p.join(repo.path, 'packages', package.name))..createSync(recursive: true);
    if (package.pubspecLicense != null) {
      File(p.join(packageDir.path, 'pubspec.yaml')).writeAsStringSync('name: ${package.name}\nlicense: ${package.pubspecLicense}\n');
    }
    if (package.licenseText != null) {
      File(p.join(packageDir.path, 'LICENSE')).writeAsStringSync(package.licenseText!);
    }
    packageConfigEntries.add(<String, String>{'name': package.name, 'rootUri': packageDir.uri.toString(), 'packageUri': 'lib/'});
  }

  File(p.join(repo.path, 'pubspec.lock')).writeAsStringSync(lock.toString());
  File(p.join(dartTool.path, 'package_config.json')).writeAsStringSync(jsonEncode(<String, Object?>{'configVersion': 2, 'packages': packageConfigEntries}));
}

final class _PackageFixture {
  const _PackageFixture({required this.name, required this.version, this.pubspecLicense, this.licenseText});

  final String name;
  final String version;
  final String? pubspecLicense;
  final String? licenseText;
}
