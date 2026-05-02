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

  test('builds and uploads the Android debug APK after gates', () {
    final int gatesIndex = workflow.indexOf('gates:');
    final int androidIndex = workflow.indexOf('android-debug-apk:');

    expect(gatesIndex, greaterThanOrEqualTo(0));
    expect(androidIndex, greaterThan(gatesIndex));
    expect(workflow, contains('runs-on: ubuntu-latest'));
    expect(workflow, contains('needs: gates'));
    expect(workflow, contains("flutter-version: '3.41.7'"));
    expect(workflow, contains('flutter pub get'));
    expect(workflow, contains('flutter build apk --debug'));
    expect(workflow, contains('actions/upload-artifact@v4'));
    expect(workflow, contains('name: MirkFall-POC-android-debug-apk'));
    expect(workflow, contains('path: build/app/outputs/flutter-apk/app-debug.apk'));
  });
}
