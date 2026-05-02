// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('platform metadata', () {
    late String androidGradle;
    late String androidManifest;
    late String iosProject;
    late String iosInfoPlist;

    setUpAll(() {
      androidGradle = File(p.join('android', 'app', 'build.gradle.kts')).readAsStringSync();
      androidManifest = File(p.join('android', 'app', 'src', 'main', 'AndroidManifest.xml')).readAsStringSync();
      iosProject = File(p.join('ios', 'Runner.xcodeproj', 'project.pbxproj')).readAsStringSync();
      iosInfoPlist = File(p.join('ios', 'Runner', 'Info.plist')).readAsStringSync();
    });

    test('locks Android application ID and display name', () {
      expect(androidGradle, contains('applicationId = "com.thongvan.mirk_poc_debug"'));
      expect(androidManifest, contains('android:label="MirkFall POC"'));
    });

    test('locks iOS bundle identifier', () {
      expect(iosProject, contains('PRODUCT_BUNDLE_IDENTIFIER = com.thongvan.mirkPocDebug;'));
    });

    test('uses SideStore-safe iOS names', () {
      expect(iosInfoPlist, contains('<key>CFBundleDisplayName</key>'));
      expect(iosInfoPlist, contains('<string>MirkFall POC</string>'));
      expect(iosInfoPlist, contains('<key>CFBundleName</key>'));
      expect(iosInfoPlist, contains('<string>MirkPocDebug</string>'));
      expect(iosInfoPlist, isNot(contains('<string>mirk_poc_debug</string>')));
      expect(iosInfoPlist, isNot(contains('<string>Mirk-Poc-Debug</string>')));
    });

    test('declares no non-exempt encryption', () {
      final RegExp encryptionFalse = RegExp(r'<key>ITSAppUsesNonExemptEncryption</key>\s*<false\s*/>', multiLine: true);
      expect(encryptionFalse.hasMatch(iosInfoPlist), isTrue);
    });
  });
}
