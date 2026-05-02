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

  test('runs on manual dispatch, pull requests, and pushes to main', () {
    for (final String required in <String>['workflow_dispatch:', 'pull_request:', 'push:', 'branches:', '- main']) {
      expect(workflow, contains(required));
    }
  });

  test('runs the required quality gates before artifact jobs', () {
    final int androidIndex = workflow.indexOf('android-debug-apk:');
    final int iosIndex = workflow.indexOf('ios-unsigned-ipa:');
    final int firstArtifactIndex = androidIndex < iosIndex ? androidIndex : iosIndex;

    expect(androidIndex, greaterThanOrEqualTo(0));
    expect(iosIndex, greaterThanOrEqualTo(0));
    expect(firstArtifactIndex, greaterThan(workflow.indexOf('gates:')));
    for (final String required in <String>[
      'flutter pub get',
      'dart format --line-length 160 --set-exit-if-changed .',
      'flutter analyze --fatal-infos --fatal-warnings',
      'dart run tool/check_headers.dart',
      'dart run tool/check_licenses.dart',
      'dart run tool/check_dependencies_md.dart',
      'dart test tool/test/',
      'flutter test',
    ]) {
      final int gateStepIndex = workflow.indexOf(required);
      expect(gateStepIndex, greaterThanOrEqualTo(0), reason: required);
      expect(gateStepIndex, lessThan(firstArtifactIndex), reason: required);
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

  test('builds and uploads an unsigned SideStore-shaped iOS IPA after gates', () {
    final int gatesIndex = workflow.indexOf('gates:');
    final int iosIndex = workflow.indexOf('ios-unsigned-ipa:');

    expect(gatesIndex, greaterThanOrEqualTo(0));
    expect(iosIndex, greaterThan(gatesIndex));
    expect(workflow, contains('runs-on: macos-latest'));
    expect(workflow, contains('needs: gates'));
    expect(workflow, contains("flutter-version: '3.41.7'"));
    expect(workflow, contains('flutter pub get'));
    expect(workflow, contains('flutter build ios --no-codesign'));
    expect(workflow, isNot(contains('flutter build ipa')));
    expect(workflow, contains('mkdir -p build/ios/ipa/Payload'));
    expect(workflow, contains('cp -R build/ios/iphoneos/Runner.app build/ios/ipa/Payload/Runner.app'));
    expect(workflow, contains('MirkFall-POC-unsigned-ios.ipa'));
    expect(workflow, contains('actions/upload-artifact@v4'));
    expect(workflow, contains('name: MirkFall-POC-unsigned-ios-ipa'));
    expect(workflow, contains('path: build/ios/MirkFall-POC-unsigned-ios.ipa'));
    expect(workflow, isNot(contains('APPLE_CERTIFICATE')));
    expect(workflow, isNot(contains('PROVISIONING_PROFILE')));
  });
}
