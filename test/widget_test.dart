// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/main.dart';

void main() {
  testWidgets('renders the Phase 1 app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MirkPocApp());

    expect(find.text('MirkFall POC foundation ready'), findsOneWidget);
  });
}
