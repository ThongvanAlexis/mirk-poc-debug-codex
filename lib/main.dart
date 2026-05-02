// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';

void main() {
  runApp(const MirkPocApp());
}

class MirkPocApp extends StatelessWidget {
  const MirkPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MirkFall POC',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MirkPocHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MirkPocHome extends StatelessWidget {
  const MirkPocHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('MirkFall POC foundation ready')));
  }
}
