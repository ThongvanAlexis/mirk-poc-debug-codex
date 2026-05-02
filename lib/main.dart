// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'domain/location/geo_fix.dart';
import 'domain/map/map_screen_services.dart';
import 'infrastructure/location/foreground_location_service.dart';
import 'infrastructure/logging/file_logger.dart';
import 'infrastructure/logging/file_logger_lifecycle_observer.dart';
import 'infrastructure/permissions/location_permission_service.dart';
import 'infrastructure/pmtiles/flutter_pmtiles_asset_copier.dart';
import 'infrastructure/sharing/active_log_share_service.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/permission_gate_screen.dart';
import 'presentation/widgets/share_log_button.dart';

typedef PmtilesPathLoader = Future<String> Function();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FileLogger.bootstrap();
  } on Object catch (error, stackTrace) {
    developer.log('FileLogger bootstrap failed; continuing without file logging', name: 'app.bootstrap', error: error, stackTrace: stackTrace);
  }
  WidgetsBinding.instance.addObserver(FileLoggerLifecycleObserver());
  runApp(MirkPocApp(pmtilesPathLoader: ensureFlutterPmtilesAssetCopied));
}

class MirkPocApp extends StatelessWidget {
  MirkPocApp({
    Future<String>? pmtilesPathFuture,
    PmtilesPathLoader? pmtilesPathLoader,
    LocationPermissionService? permissionService,
    ForegroundLocationService? locationService,
    ActiveLogShareService? shareLogService,
    super.key,
  }) : assert(pmtilesPathFuture == null || pmtilesPathLoader == null, 'Use either pmtilesPathFuture or pmtilesPathLoader, not both.'),
       _pmtilesPathLoader = pmtilesPathLoader ?? (() => pmtilesPathFuture ?? ensureFlutterPmtilesAssetCopied()),
       _permissionService = permissionService ?? LocationPermissionService(),
       _locationService = locationService ?? ForegroundLocationService(),
       _shareLogService = shareLogService ?? ActiveLogShareService();

  final PmtilesPathLoader _pmtilesPathLoader;
  final LocationPermissionService _permissionService;
  final ForegroundLocationService _locationService;
  final ActiveLogShareService _shareLogService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MirkFall POC',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: PermissionGateScreen(
        permissionService: _permissionService,
        grantedBuilder: (BuildContext context) =>
            MirkRuntimeScreen(pmtilesPathLoader: _pmtilesPathLoader, locationService: _locationService, shareLogService: _shareLogService),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MirkRuntimeScreen extends StatefulWidget {
  const MirkRuntimeScreen({required this.pmtilesPathLoader, required this.locationService, required this.shareLogService, super.key});

  final PmtilesPathLoader pmtilesPathLoader;
  final ForegroundLocationService locationService;
  final ActiveLogShareService shareLogService;

  @override
  State<MirkRuntimeScreen> createState() => _MirkRuntimeScreenState();
}

class _MirkRuntimeScreenState extends State<MirkRuntimeScreen> with WidgetsBindingObserver {
  late final Future<String> _pmtilesPathFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pmtilesPathFuture = widget.pmtilesPathLoader();
    widget.locationService.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      widget.locationService.start();
      return;
    }
    widget.locationService.stop(reason: 'lifecycle_${state.name}').ignore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.locationService.dispose().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PmtilesBootstrapScreen(
      pmtilesPathFuture: _pmtilesPathFuture,
      latestFixStream: widget.locationService.fixes,
      shareActiveLog: widget.shareLogService.shareActiveLog,
    );
  }
}

class PmtilesBootstrapScreen extends StatelessWidget {
  const PmtilesBootstrapScreen({required this.pmtilesPathFuture, this.latestFixStream, this.shareActiveLog, super.key});

  final Future<String> pmtilesPathFuture;
  final Stream<GeoFix>? latestFixStream;
  final ShareActiveLogCallback? shareActiveLog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<String>(
          future: pmtilesPathFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Text('Preparing Melun map');
            }
            if (snapshot.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Map data could not open. Restart the app or share the active log for diagnosis.'),
                  if (shareActiveLog != null) ...<Widget>[const SizedBox(height: 16), ShareLogButton(onShareLog: shareActiveLog)],
                ],
              );
            }
            return MapScreen(
              services: MapScreenServices(pmtilesPath: snapshot.requireData, latestFixStream: latestFixStream, shareActiveLog: shareActiveLog),
            );
          },
        ),
      ),
    );
  }
}
