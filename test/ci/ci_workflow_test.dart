// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:test/test.dart';

void main() {
  late String workflow;

  setUpAll(() {
    workflow = File('.github/workflows/ci.yml').readAsStringSync();
  });

  test('runs the required Phase 1 quality gates', () {
    for (final String required in <String>[
      'workflow_dispatch:',
      'pull_request:',
      'push:',
      'flutter pub get',
      'dart format --line-length 160 --set-exit-if-changed .',
      'flutter analyze --fatal-infos --fatal-warnings',
      'dart run tool/check_headers.dart',
      'dart run tool/check_licenses.dart',
      'dart run tool/check_dependencies_md.dart',
      'dart test tool/test/',
      'flutter test',
    ]) {
      expect(workflow, contains(required));
    }
  });

  test('does not build or upload IPA/APK artifacts in the gates-only workflow', () {
    for (final String forbidden in <String>['flutter build apk', 'flutter build ios', 'flutter build ipa', 'upload-artifact', 'actions/upload-artifact']) {
      expect(workflow, isNot(contains(forbidden)));
    }
  });
}
