// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';

import '../../domain/map/map_screen_services.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({required this.services, super.key});

  final MapScreenServices services;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Opening Melun map')));
  }
}
