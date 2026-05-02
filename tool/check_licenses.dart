// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const Set<String> allowedSpdx = <String>{'MIT', 'BSD-2-Clause', 'BSD-3-Clause', 'Apache-2.0', 'MPL-2.0', 'ISC', 'Zlib', 'CC0-1.0', 'Unlicense'};

const List<String> forbiddenLicenseMarkers = <String>[
  'GNU GENERAL PUBLIC LICENSE',
  'GNU LESSER GENERAL PUBLIC LICENSE',
  'GNU AFFERO GENERAL PUBLIC LICENSE',
  'SERVER SIDE PUBLIC LICENSE',
  'SSPL',
];

const List<String> telemetryPackageNeedles = <String>[
  'firebase_analytics',
  'firebase_crashlytics',
  'sentry',
  'posthog',
  'mixpanel',
  'amplitude',
  'segment',
  'appsflyer',
  'adjust',
  'google_mobile_ads',
  'facebook_app_events',
  'maplibre',
  'mapbox',
];

const int maxLicenseBytes = 64 * 1024;

Future<int> runCheck(List<String> args) async {
  final String repoRoot = args.isEmpty ? '.' : args.first;
  final File lockFile = File(p.join(repoRoot, 'pubspec.lock'));
  final File packageConfigFile = File(p.join(repoRoot, '.dart_tool', 'package_config.json'));
  if (!lockFile.existsSync()) {
    stderr.writeln('check_licenses: pubspec.lock not found');
    return 2;
  }
  if (!packageConfigFile.existsSync()) {
    stderr.writeln('check_licenses: .dart_tool/package_config.json not found. Run pub get first.');
    return 2;
  }

  final YamlMap lock = loadYaml(lockFile.readAsStringSync()) as YamlMap;
  final YamlMap packages = lock['packages'] as YamlMap? ?? YamlMap();
  final Map<String, String> roots = _readPackageRoots(packageConfigFile);
  final List<String> violations = <String>[];
  final List<String> unresolved = <String>[];
  var checked = 0;

  for (final MapEntry<dynamic, dynamic> entry in packages.entries) {
    final String name = entry.key as String;
    final YamlMap meta = entry.value as YamlMap;
    if (meta['source'] == 'sdk') {
      continue;
    }
    final String lowerName = name.toLowerCase();
    final String? denyNeedle = telemetryPackageNeedles.where(lowerName.contains).firstOrNull;
    if (denyNeedle != null) {
      violations.add('$name: package name matches denied telemetry/ads/MapLibre token "$denyNeedle"');
      continue;
    }

    final String? spdx = _resolveSpdx(name, roots[name], packageConfigFile);
    if (spdx == null) {
      unresolved.add(name);
      continue;
    }
    final String? violation = _validateSpdx(name, spdx);
    if (violation != null) {
      violations.add(violation);
    } else {
      checked++;
    }
  }

  if (violations.isEmpty && unresolved.isEmpty) {
    stdout.writeln('check_licenses: OK ($checked packages)');
    return 0;
  }
  if (violations.isNotEmpty) {
    stderr.writeln('check_licenses: violations:');
    violations.forEach(stderr.writeln);
  }
  if (unresolved.isNotEmpty) {
    stderr.writeln('check_licenses: unresolved packages:');
    unresolved.forEach(stderr.writeln);
  }
  return 1;
}

Map<String, String> _readPackageRoots(File packageConfigFile) {
  final Map<String, Object?> json = jsonDecode(packageConfigFile.readAsStringSync()) as Map<String, Object?>;
  final List<Object?> packages = json['packages'] as List<Object?>;
  final Map<String, String> roots = <String, String>{};
  for (final Object? package in packages) {
    if (package is! Map<String, Object?>) {
      continue;
    }
    final String? name = package['name'] as String?;
    final String? rootUri = package['rootUri'] as String?;
    if (name != null && rootUri != null) {
      roots[name] = rootUri;
    }
  }
  return roots;
}

String? _resolveSpdx(String packageName, String? rootUri, File packageConfigFile) {
  if (rootUri == null) {
    return null;
  }
  final Uri uri = Uri.parse(rootUri);
  final String packagePath = uri.scheme == 'file' ? uri.toFilePath() : p.normalize(p.join(packageConfigFile.parent.path, uri.path));
  final Directory packageDir = Directory(packagePath);
  if (!packageDir.existsSync()) {
    return null;
  }

  final String? forbidden = _scanForbiddenLicenseMarkers(packageDir);
  if (forbidden != null) {
    return 'FORBIDDEN: $forbidden';
  }

  final File pubspec = File(p.join(packagePath, 'pubspec.yaml'));
  if (pubspec.existsSync()) {
    final Object? parsed = loadYaml(pubspec.readAsStringSync());
    if (parsed is YamlMap) {
      final Object? license = parsed['license'];
      if (license is String && license.trim().isNotEmpty && !_isPlaceholderLicense(license)) {
        return license.trim();
      }
    }
  }

  for (final String candidate in <String>['LICENSE', 'LICENSE.md', 'LICENSE.txt', 'COPYING']) {
    final File license = File(p.join(packagePath, candidate));
    if (!license.existsSync()) {
      continue;
    }
    final String text = _readLicenseHead(license);
    final String lower = text.toLowerCase();
    if (lower.contains('apache license') && lower.contains('version 2.0')) {
      return 'Apache-2.0';
    }
    if (lower.contains('mit license') || lower.contains('permission is hereby granted, free of charge')) {
      if (lower.contains('redistribution and use in source and binary forms')) {
        return lower.contains('neither the name') ? 'BSD-3-Clause' : 'BSD-2-Clause';
      }
      return 'MIT';
    }
    if (lower.contains('redistribution and use in source and binary forms')) {
      return lower.contains('neither the name') ? 'BSD-3-Clause' : 'BSD-2-Clause';
    }
    if (lower.contains('mozilla public license') && lower.contains('version 2.0')) {
      return 'MPL-2.0';
    }
    if (lower.contains('isc license')) {
      return 'ISC';
    }
    if (lower.contains('unlicense')) {
      return 'Unlicense';
    }
    if (lower.contains('cc0 1.0 universal')) {
      return 'CC0-1.0';
    }
    if (lower.contains('zlib license')) {
      return 'Zlib';
    }
  }

  return null;
}

String? _scanForbiddenLicenseMarkers(Directory packageDir) {
  for (final String candidate in <String>['LICENSE', 'LICENSE.md', 'LICENSE.txt', 'COPYING']) {
    final File license = File(p.join(packageDir.path, candidate));
    if (!license.existsSync()) {
      continue;
    }
    final String licenseHead = _readLicenseHead(license);
    final String lower = licenseHead.toLowerCase();
    if (lower.contains('mozilla public license') && lower.contains('version 2.0')) {
      continue;
    }
    final String upper = licenseHead.toUpperCase();
    for (final String marker in forbiddenLicenseMarkers) {
      if (upper.contains(marker)) {
        return marker;
      }
    }
  }
  return null;
}

String? _validateSpdx(String packageName, String expression) {
  if (expression.startsWith('FORBIDDEN: ')) {
    return '$packageName: ${expression.substring('FORBIDDEN: '.length)} is forbidden';
  }
  final String normalized = _stripOuterParens(expression.trim());
  if (normalized.toLowerCase().startsWith('licenseref-')) {
    return '$packageName: non-standard license expression "$expression"';
  }
  if (RegExp(r'\s+(AND|WITH)\s+', caseSensitive: false).hasMatch(normalized)) {
    return '$packageName: unsupported compound license expression "$expression"';
  }
  final Set<String> allowedLower = allowedSpdx.map((String spdx) => spdx.toLowerCase()).toSet();
  final bool allowed = normalized
      .split(RegExp(r'\s+OR\s+', caseSensitive: false))
      .map((String part) => _stripOuterParens(part.trim()).toLowerCase())
      .any(allowedLower.contains);
  return allowed ? null : '$packageName: "$expression" is not in the allowed license set';
}

String _readLicenseHead(File file) {
  final RandomAccessFile handle = file.openSync();
  try {
    final int toRead = handle.lengthSync() < maxLicenseBytes ? handle.lengthSync() : maxLicenseBytes;
    return utf8.decode(handle.readSync(toRead), allowMalformed: true);
  } finally {
    handle.closeSync();
  }
}

bool _isPlaceholderLicense(String value) {
  final String lower = value.toLowerCase().trim();
  return lower == 'unknown' || lower == 'tbd' || lower == 'n/a' || lower.contains('see license');
}

String _stripOuterParens(String value) {
  if (value.length < 2 || !value.startsWith('(') || !value.endsWith(')')) {
    return value;
  }
  var depth = 0;
  for (var i = 0; i < value.length; i++) {
    if (value[i] == '(') {
      depth++;
    } else if (value[i] == ')') {
      depth--;
    }
    if (depth == 0 && i < value.length - 1) {
      return value;
    }
  }
  return value.substring(1, value.length - 1).trim();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final Iterator<T> iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}

Future<void> main(List<String> args) async {
  exitCode = await runCheck(args);
}
