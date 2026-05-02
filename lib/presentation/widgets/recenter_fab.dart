// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';

import '../../domain/location/geo_fix.dart';

class RecenterFab extends StatelessWidget {
  const RecenterFab({required this.latestFix, required this.onRecenter, super.key});

  final GeoFix? latestFix;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'poc_recenter_latest_fix',
      tooltip: 'Recenter to latest fix',
      onPressed: latestFix == null ? null : onRecenter,
      child: const Icon(Icons.my_location),
    );
  }
}
