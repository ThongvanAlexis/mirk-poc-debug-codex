// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'domain/map/map_screen_services.dart';
import 'infrastructure/logging/file_logger.dart';
import 'infrastructure/logging/file_logger_lifecycle_observer.dart';
import 'infrastructure/permissions/location_permission_service.dart';
import 'infrastructure/pmtiles/flutter_pmtiles_asset_copier.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/permission_gate_screen.dart';

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
  MirkPocApp({Future<String>? pmtilesPathFuture, PmtilesPathLoader? pmtilesPathLoader, LocationPermissionService? permissionService, super.key})
    : assert(pmtilesPathFuture == null || pmtilesPathLoader == null, 'Use either pmtilesPathFuture or pmtilesPathLoader, not both.'),
      _pmtilesPathLoader = pmtilesPathLoader ?? (() => pmtilesPathFuture ?? ensureFlutterPmtilesAssetCopied()),
      _permissionService = permissionService ?? LocationPermissionService();

  final PmtilesPathLoader _pmtilesPathLoader;
  final LocationPermissionService _permissionService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MirkFall POC',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: PermissionGateScreen(
        permissionService: _permissionService,
        grantedBuilder: (BuildContext context) => PmtilesBootstrapScreen(pmtilesPathFuture: _pmtilesPathLoader()),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PmtilesBootstrapScreen extends StatelessWidget {
  const PmtilesBootstrapScreen({required this.pmtilesPathFuture, super.key});

  final Future<String> pmtilesPathFuture;

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
              return const Text('Map data could not open. Restart the app or share the active log for diagnosis.');
            }
            return MapScreen(services: MapScreenServices(pmtilesPath: snapshot.requireData));
          },
        ),
      ),
    );
  }
}
