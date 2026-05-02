// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('platform metadata', () {
    late String androidGradle;
    late String androidManifest;
    late String iosProject;
    late String iosInfoPlist;
    late String iosPodfile;
    late File iosPrivacyManifestFile;
    late String iosPrivacyManifest;

    setUpAll(() {
      androidGradle = File(p.join('android', 'app', 'build.gradle.kts')).readAsStringSync();
      androidManifest = File(p.join('android', 'app', 'src', 'main', 'AndroidManifest.xml')).readAsStringSync();
      iosProject = File(p.join('ios', 'Runner.xcodeproj', 'project.pbxproj')).readAsStringSync();
      iosInfoPlist = File(p.join('ios', 'Runner', 'Info.plist')).readAsStringSync();
      iosPodfile = File(p.join('ios', 'Podfile')).readAsStringSync();
      iosPrivacyManifestFile = File(p.join('ios', 'Runner', 'PrivacyInfo.xcprivacy'));
      iosPrivacyManifest = iosPrivacyManifestFile.readAsStringSync();
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

    test('configures permission_handler for iOS foreground location', () {
      expect(iosPodfile, contains('post_install do |installer|'));
      expect(iosPodfile, contains("config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']"));
      expect(iosPodfile, contains("'PERMISSION_LOCATION=1'"));
      expect(iosPodfile, isNot(contains('PERMISSION_NOTIFICATIONS=1')));
      expect(iosPodfile, isNot(contains('PERMISSION_CAMERA=1')));
    });

    test('declares iOS foreground location usage only', () {
      expect(iosInfoPlist, contains('<key>NSLocationWhenInUseUsageDescription</key>'));
      expect(
        iosInfoPlist,
        contains('The POC uses your current position to draw the blue dot, reveal 25 m fog discs, and write evidence logs for the renderer test.'),
      );
      expect(iosInfoPlist, isNot(contains('NSLocationAlwaysAndWhenInUseUsageDescription')));
      expect(iosInfoPlist, isNot(contains('NSLocationAlwaysUsageDescription')));
      expect(iosInfoPlist, isNot(contains('<key>UIBackgroundModes</key>')));
    });

    test('declares Android foreground location permissions only', () {
      expect(androidManifest, contains('android.permission.ACCESS_FINE_LOCATION'));
      expect(androidManifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
      expect(androidManifest, isNot(contains('android.permission.ACCESS_BACKGROUND_LOCATION')));
      expect(androidManifest, isNot(contains('android.permission.FOREGROUND_SERVICE')));
      expect(androidManifest, isNot(contains('android.permission.FOREGROUND_SERVICE_LOCATION')));
      expect(androidManifest, isNot(contains('android.permission.POST_NOTIFICATIONS')));
    });

    test('declares required-reason APIs in the iOS privacy manifest', () {
      expect(iosPrivacyManifestFile.existsSync(), isTrue);
      expect(iosPrivacyManifest, contains('NSPrivacyAccessedAPICategoryFileTimestamp'));
      expect(iosPrivacyManifest, contains('C617.1'));
      expect(iosPrivacyManifest, contains('NSPrivacyAccessedAPICategoryUserDefaults'));
      expect(iosPrivacyManifest, contains('CA92.1'));
      expect(iosProject, contains('PrivacyInfo.xcprivacy in Resources'));
    });
  });
}
