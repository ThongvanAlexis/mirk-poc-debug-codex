// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirk_poc_debug/presentation/widgets/share_log_button.dart';

void main() {
  testWidgets('uses a compact accessible share active log control', (WidgetTester tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShareLogButton(
            onShareLog: () async {
              tapCount++;
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('Share active log'), findsOneWidget);
    final SizedBox sizedBox = tester.widget<SizedBox>(
      find.descendant(of: find.byType(ShareLogButton), matching: find.byWidgetPredicate((Widget widget) => widget is SizedBox && widget.width == 44)),
    );
    expect(sizedBox.width, 44);
    expect(sizedBox.height, 44);

    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pump();
    expect(tapCount, 1);
  });
}
