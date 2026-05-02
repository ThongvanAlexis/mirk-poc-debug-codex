// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

import '../../config/constants.dart';
import '../../domain/location/geo_fix.dart';

typedef PositionStreamFactory = Stream<Position> Function(LocationSettings locationSettings);

class ForegroundLocationService {
  ForegroundLocationService({PositionStreamFactory? positionStreamFactory, LocationSettings? locationSettings, Logger? logger})
    : _positionStreamFactory = positionStreamFactory ?? _defaultPositionStreamFactory,
      _locationSettings = locationSettings ?? const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 3),
      _log = logger ?? Logger('infrastructure.location.foreground');

  final PositionStreamFactory _positionStreamFactory;
  final LocationSettings _locationSettings;
  final Logger _log;
  final StreamController<GeoFix> _fixController = StreamController<GeoFix>.broadcast();

  StreamSubscription<Position>? _positionSubscription;
  bool _disposed = false;

  Stream<GeoFix> get fixes => _fixController.stream;

  void start() {
    if (_disposed || _positionSubscription != null) return;
    _log.info('foreground_location_stream_start accuracy=${_locationSettings.accuracy.name} distanceFilter=${_locationSettings.distanceFilter}');
    _positionSubscription = _positionStreamFactory(_locationSettings).listen(_onPosition, onError: _onError, onDone: _onDone, cancelOnError: false);
  }

  Future<void> stop({String reason = 'manual'}) async {
    final StreamSubscription<Position>? subscription = _positionSubscription;
    if (subscription == null) return;
    _positionSubscription = null;
    _log.info('foreground_location_stream_stop reason=$reason');
    await subscription.cancel();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop(reason: 'dispose');
    await _fixController.close();
  }

  void _onPosition(Position position) {
    final GeoFix fix = GeoFix(latitude: position.latitude, longitude: position.longitude, fixedAtUtc: position.timestamp.toUtc());
    if (!fix.hasFiniteCoordinates) {
      _log.warning('foreground_location_fix_rejected reason=non_finite latitude=${position.latitude} longitude=${position.longitude}');
      return;
    }
    if (!fix.isInCoordinateRange) {
      _log.warning('foreground_location_fix_rejected reason=out_of_coordinate_range latitude=${position.latitude} longitude=${position.longitude}');
      return;
    }

    final bool inMelun = _isInMelunBounds(fix);
    if (!inMelun) {
      _log.info('foreground_location_fix_out_of_melun latitude=${fix.latitude} longitude=${fix.longitude}');
    }
    _log.info('foreground_location_fix_accepted latitude=${fix.latitude} longitude=${fix.longitude} accuracy=${position.accuracy} inMelun=$inMelun');
    _fixController.add(fix);
  }

  void _onError(Object error, StackTrace stackTrace) {
    _log.warning('foreground_location_stream_error', error, stackTrace);
  }

  void _onDone() {
    _log.info('foreground_location_stream_done');
    _positionSubscription = null;
  }

  bool _isInMelunBounds(GeoFix fix) {
    return fix.latitude >= kPocMelunBoundsSouth &&
        fix.latitude <= kPocMelunBoundsNorth &&
        fix.longitude >= kPocMelunBoundsWest &&
        fix.longitude <= kPocMelunBoundsEast;
  }

  static Stream<Position> _defaultPositionStreamFactory(LocationSettings locationSettings) {
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
