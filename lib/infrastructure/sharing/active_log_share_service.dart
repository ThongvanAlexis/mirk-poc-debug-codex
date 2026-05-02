// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../logging/file_logger.dart';

typedef ActiveLogPathProvider = String? Function();
typedef ShareLogInvoker = Future<ShareResult> Function(ShareParams params);

enum ShareLogOutcome { success, dismissed, unavailable, failure }

class ActiveLogShareService {
  ActiveLogShareService({ActiveLogPathProvider? activeLogPathProvider, ShareLogInvoker? share, Logger? logger})
    : _activeLogPathProvider = activeLogPathProvider ?? (() => FileLogger.activeLogFilePath),
      _share = share ?? SharePlus.instance.share,
      _log = logger ?? Logger('infrastructure.sharing.active_log');

  final ActiveLogPathProvider _activeLogPathProvider;
  final ShareLogInvoker _share;
  final Logger _log;

  Future<ShareLogOutcome> shareActiveLog() async {
    final String? activePath = _activeLogPathProvider();
    if (activePath == null || activePath.isEmpty) {
      _log.warning('share_log_unavailable reason=missing_active_log_path');
      return ShareLogOutcome.unavailable;
    }
    if (!File(activePath).existsSync()) {
      _log.warning('share_log_unavailable reason=active_log_file_missing basename=${p.basename(activePath)}');
      return ShareLogOutcome.unavailable;
    }

    _log.info('share_log_start basename=${p.basename(activePath)}');
    try {
      final ShareResult result = await _share(ShareParams(files: <XFile>[XFile(activePath)]));
      final ShareLogOutcome outcome = switch (result.status) {
        ShareResultStatus.success => ShareLogOutcome.success,
        ShareResultStatus.dismissed => ShareLogOutcome.dismissed,
        ShareResultStatus.unavailable => ShareLogOutcome.unavailable,
      };
      _log.info('share_log_result status=${result.status.name} raw=${result.raw}');
      return outcome;
    } on Object catch (error, stackTrace) {
      _log.warning('share_log_failure basename=${p.basename(activePath)}', error, stackTrace);
      return ShareLogOutcome.failure;
    }
  }
}
