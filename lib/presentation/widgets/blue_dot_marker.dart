// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../config/constants.dart';

class BlueDotMarker {
  const BlueDotMarker._();

  static CircleMarker<Object> build({required LatLng point}) {
    return CircleMarker<Object>(
      point: point,
      radius: kPocBlueDotRadiusPx,
      useRadiusInMeter: false,
      color: const Color(kPocBlueDotFillArgb),
      borderStrokeWidth: kPocBlueDotStrokePx,
      borderColor: Colors.white,
    );
  }
}
