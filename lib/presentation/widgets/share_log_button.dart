// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';

import 'package:flutter/material.dart';

class ShareLogButton extends StatelessWidget {
  const ShareLogButton({required this.onShareLog, super.key});

  final Future<void> Function()? onShareLog;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Share active log',
      child: Tooltip(
        message: 'Share active log',
        child: SizedBox.square(
          dimension: 44,
          child: IconButton.filledTonal(
            onPressed: onShareLog == null
                ? null
                : () {
                    unawaited(onShareLog!());
                  },
            icon: const Icon(Icons.ios_share),
          ),
        ),
      ),
    );
  }
}
