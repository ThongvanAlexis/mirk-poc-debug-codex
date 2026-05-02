// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';

import '../../domain/map/map_screen_services.dart';

class MapModeToggle extends StatelessWidget {
  const MapModeToggle({required this.mode, required this.onChanged, super.key});

  final MapDisplayMode mode;
  final ValueChanged<MapDisplayMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SegmentedButton<MapDisplayMode>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const WidgetStatePropertyAll<Size>(Size(62, 36)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 8)),
        ),
        segments: const <ButtonSegment<MapDisplayMode>>[
          ButtonSegment<MapDisplayMode>(value: MapDisplayMode.mapOnly, icon: Icon(Icons.map_outlined, size: 18), label: Text('Map')),
          ButtonSegment<MapDisplayMode>(value: MapDisplayMode.mapWithFog, icon: Icon(Icons.layers_outlined, size: 18), label: Text('Fog')),
        ],
        selected: <MapDisplayMode>{mode},
        onSelectionChanged: (Set<MapDisplayMode> selected) {
          if (selected.isNotEmpty) {
            onChanged(selected.first);
          }
        },
      ),
    );
  }
}
