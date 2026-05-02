// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:convert';
import 'dart:io';

const String expectedHeader = '''// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details''';

const List<String> defaultRoots = <String>['lib', 'test', 'tool', 'integration_test'];

final List<RegExp> excludedPatterns = <RegExp>[
  RegExp(r'\.g\.dart$'),
  RegExp(r'\.freezed\.dart$'),
  RegExp(r'\.mocks\.dart$'),
  RegExp(r'[/\\]\.dart_tool[/\\]'),
  RegExp(r'[/\\]build[/\\]'),
  RegExp(r'[/\\]generated[/\\]'),
];

Future<int> runCheck(List<String> args) async {
  final List<String> roots = args.where((String arg) => !arg.startsWith('--')).toList();
  final List<String> scanRoots = roots.isEmpty ? defaultRoots : roots;
  final List<String> failures = <String>[];
  var rootsSeen = 0;
  var scanned = 0;

  for (final String rootPath in scanRoots) {
    final Directory root = Directory(rootPath);
    if (!root.existsSync()) {
      continue;
    }
    rootsSeen++;
    await for (final FileSystemEntity entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final String normalized = entity.path.replaceAll('\\', '/');
      if (excludedPatterns.any((RegExp pattern) => pattern.hasMatch(normalized))) {
        continue;
      }
      scanned++;
      final String contents = await _readText(entity);
      final String withoutBom = contents.startsWith('\uFEFF') ? contents.substring(1) : contents;
      if (!withoutBom.startsWith(expectedHeader)) {
        failures.add(entity.path);
        continue;
      }
      final String afterHeader = withoutBom.substring(expectedHeader.length);
      if (afterHeader.isNotEmpty && !afterHeader.startsWith('\n') && !afterHeader.startsWith('\r\n')) {
        failures.add(entity.path);
      }
    }
  }

  if (rootsSeen == 0) {
    stderr.writeln('check_headers: no scan roots found: ${scanRoots.join(', ')}');
    return 2;
  }
  if (failures.isEmpty) {
    stdout.writeln('check_headers: OK ($scanned files)');
    return 0;
  }
  stderr.writeln('check_headers: ${failures.length} file(s) missing required GOSL header:');
  for (final String failure in failures) {
    stderr.writeln('  - $failure');
  }
  return 1;
}

Future<String> _readText(File file) async {
  final List<int> bytes = await file.readAsBytes();
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    final List<int> body = bytes.sublist(2);
    final StringBuffer buffer = StringBuffer();
    for (var i = 0; i + 1 < body.length; i += 2) {
      buffer.writeCharCode(body[i] | (body[i + 1] << 8));
    }
    return buffer.toString();
  }
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    final List<int> body = bytes.sublist(2);
    final StringBuffer buffer = StringBuffer();
    for (var i = 0; i + 1 < body.length; i += 2) {
      buffer.writeCharCode((body[i] << 8) | body[i + 1]);
    }
    return buffer.toString();
  }
  return utf8.decode(bytes, allowMalformed: true);
}

Future<void> main(List<String> args) async {
  exitCode = await runCheck(args);
}
