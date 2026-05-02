// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

typedef LocationPermissionStatusReader = Future<LocationPermissionState> Function();
typedef LocationPermissionRequester = Future<LocationPermissionState> Function();
typedef LocationPermissionSettingsOpener = Future<bool> Function();

enum LocationPermissionState {
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  provisional;

  bool get canEnterMap => this == LocationPermissionState.granted;
  bool get needsRecovery => this != LocationPermissionState.granted;
}

class LocationPermissionService {
  LocationPermissionService({
    LocationPermissionStatusReader? statusReader,
    LocationPermissionRequester? requestWhenInUse,
    LocationPermissionSettingsOpener? openSettings,
    Logger? logger,
  }) : _statusReader = statusReader ?? _defaultStatusReader,
       _requestWhenInUse = requestWhenInUse ?? _defaultRequestWhenInUse,
       _openSettings = openSettings ?? permissions.openAppSettings,
       _log = logger ?? Logger('infrastructure.permissions.location');

  final LocationPermissionStatusReader _statusReader;
  final LocationPermissionRequester _requestWhenInUse;
  final LocationPermissionSettingsOpener _openSettings;
  final Logger _log;

  Future<LocationPermissionState> status() async {
    final LocationPermissionState state = await _statusReader();
    _log.info('location_permission_status state=${state.name}');
    return state;
  }

  Future<LocationPermissionState> requestWhenInUse() async {
    _log.info('location_permission_request_start permission=locationWhenInUse');
    final LocationPermissionState state = await _requestWhenInUse();
    _log.info('location_permission_request_result state=${state.name}');
    return state;
  }

  Future<bool> openSettings() async {
    _log.info('location_permission_open_settings_start');
    final bool opened = await _openSettings();
    _log.info('location_permission_open_settings_result opened=$opened');
    return opened;
  }

  static Future<LocationPermissionState> _defaultStatusReader() async {
    return _fromPermissionHandlerStatus(await permissions.Permission.locationWhenInUse.status);
  }

  static Future<LocationPermissionState> _defaultRequestWhenInUse() async {
    return _fromPermissionHandlerStatus(await permissions.Permission.locationWhenInUse.request());
  }

  static LocationPermissionState _fromPermissionHandlerStatus(permissions.PermissionStatus status) {
    return switch (status) {
      permissions.PermissionStatus.denied => LocationPermissionState.denied,
      permissions.PermissionStatus.granted => LocationPermissionState.granted,
      permissions.PermissionStatus.restricted => LocationPermissionState.restricted,
      permissions.PermissionStatus.limited => LocationPermissionState.limited,
      permissions.PermissionStatus.permanentlyDenied => LocationPermissionState.permanentlyDenied,
      permissions.PermissionStatus.provisional => LocationPermissionState.provisional,
    };
  }
}
