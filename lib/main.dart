// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';

import 'infrastructure/pmtiles/flutter_pmtiles_asset_copier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MirkPocApp(pmtilesPathFuture: ensureFlutterPmtilesAssetCopied()));
}

class MirkPocApp extends StatelessWidget {
  const MirkPocApp({required this.pmtilesPathFuture, super.key});

  final Future<String> pmtilesPathFuture;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MirkFall POC',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: PmtilesBootstrapScreen(pmtilesPathFuture: pmtilesPathFuture),
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
              return const Text('Preparing Melun PMTiles');
            }
            if (snapshot.hasError) {
              return const Text('PMTiles copy failed');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[const Text('PMTiles ready'), const SizedBox(height: 8), SelectableText(snapshot.requireData)],
            );
          },
        ),
      ),
    );
  }
}
