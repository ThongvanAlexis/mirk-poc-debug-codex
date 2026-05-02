// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mirk_poc_debug/infrastructure/sharing/active_log_share_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test/test.dart';

void main() {
  test('shares the active log through SharePlus ShareParams files API', () async {
    final File logFile = File('${Directory.systemTemp.createTempSync('share_log_test_').path}/active_logs.txt')..writeAsStringSync('log');
    ShareParams? capturedParams;
    final service = ActiveLogShareService(
      activeLogPathProvider: () => logFile.path,
      share: (ShareParams params) async {
        capturedParams = params;
        return const ShareResult('mail', ShareResultStatus.success);
      },
      logger: Logger('test.share_log'),
    );

    expect(await service.shareActiveLog(), ShareLogOutcome.success);
    expect(capturedParams, isNotNull);
    expect(capturedParams!.files, hasLength(1));
    expect(capturedParams!.files!.single.path, logFile.path);

    logFile.parent.deleteSync(recursive: true);
  });

  test('handles missing active log without calling share sheet', () async {
    var shareWasCalled = false;
    final service = ActiveLogShareService(
      activeLogPathProvider: () => null,
      share: (ShareParams params) async {
        shareWasCalled = true;
        return ShareResult.unavailable;
      },
      logger: Logger('test.share_log'),
    );

    expect(await service.shareActiveLog(), ShareLogOutcome.unavailable);
    expect(shareWasCalled, isFalse);
  });

  test('does not use deprecated share_plus APIs', () {
    final String source = File('lib/infrastructure/sharing/active_log_share_service.dart').readAsStringSync();

    expect(source, contains('SharePlus.instance.share'));
    expect(source, contains('ShareParams(files: <XFile>[XFile(activePath)])'));
    expect(source, isNot(contains('Share.shareXFiles')));
    expect(source, isNot(contains('Share.share(')));
  });
}
