// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<int> runCheck(List<String> args) async {
  final String repoRoot = args.isEmpty ? '.' : args.first;
  final File lockFile = File(p.join(repoRoot, 'pubspec.lock'));
  final File dependenciesFile = File(p.join(repoRoot, 'DEPENDENCIES.md'));
  if (!lockFile.existsSync()) {
    stderr.writeln('check_dependencies_md: pubspec.lock not found');
    return 2;
  }
  if (!dependenciesFile.existsSync()) {
    stderr.writeln('check_dependencies_md: DEPENDENCIES.md not found');
    return 2;
  }

  final Map<String, String> expected = _readLockfilePackages(lockFile);
  final Map<String, String> declared = _readDependencyRows(dependenciesFile);
  final List<String> missing = <String>[];
  final List<String> extra = <String>[];
  final List<String> mismatched = <String>[];

  for (final MapEntry<String, String> entry in expected.entries) {
    final String? declaredVersion = declared[entry.key];
    if (declaredVersion == null) {
      missing.add('${entry.key} ${entry.value}');
    } else if (declaredVersion != entry.value) {
      mismatched.add('${entry.key}: lock=${entry.value} md=$declaredVersion');
    }
  }
  for (final String package in declared.keys) {
    if (!expected.containsKey(package)) {
      extra.add(package);
    }
  }

  if (missing.isEmpty && extra.isEmpty && mismatched.isEmpty) {
    stdout.writeln('check_dependencies_md: OK (${expected.length} packages)');
    return 0;
  }
  if (missing.isNotEmpty) {
    stderr.writeln('check_dependencies_md: missing rows:');
    missing.forEach(stderr.writeln);
  }
  if (extra.isNotEmpty) {
    stderr.writeln('check_dependencies_md: extra rows:');
    extra.forEach(stderr.writeln);
  }
  if (mismatched.isNotEmpty) {
    stderr.writeln('check_dependencies_md: version mismatches:');
    mismatched.forEach(stderr.writeln);
  }
  return 1;
}

Map<String, String> _readLockfilePackages(File lockFile) {
  final YamlMap lock = loadYaml(lockFile.readAsStringSync()) as YamlMap;
  final YamlMap packages = lock['packages'] as YamlMap? ?? YamlMap();
  final Map<String, String> expected = <String, String>{};
  for (final MapEntry<dynamic, dynamic> entry in packages.entries) {
    final String name = entry.key as String;
    final YamlMap meta = entry.value as YamlMap;
    if (meta['source'] == 'sdk') {
      continue;
    }
    expected[name] = meta['version'] as String? ?? '';
  }
  return expected;
}

Map<String, String> _readDependencyRows(File dependenciesFile) {
  final Map<String, String> declared = <String, String>{};
  var inPackageSection = false;
  for (final String rawLine in dependenciesFile.readAsLinesSync()) {
    final String line = rawLine.trim();
    if (line.startsWith('## ')) {
      final String title = line.substring(3).toLowerCase();
      inPackageSection = title.contains('direct dependencies') || title.contains('dev dependencies') || title.contains('transitive dependencies');
      continue;
    }
    if (!inPackageSection || !line.startsWith('|')) {
      continue;
    }
    final List<String> cells = line.split('|').map((String cell) => cell.trim()).toList();
    if (cells.length < 4) {
      continue;
    }
    final String name = cells[1];
    final String version = cells[2];
    if (name.isEmpty || name == 'Package' || name.startsWith('-') || version == 'Version' || version.startsWith('-')) {
      continue;
    }
    if (version == '(SDK)') {
      continue;
    }
    declared[name] = version;
  }
  return declared;
}

Future<void> main(List<String> args) async {
  exitCode = await runCheck(args);
}
