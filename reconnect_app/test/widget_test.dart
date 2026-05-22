import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reconnect_app/app/app.dart';

void main() {
  testWidgets('App should render without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MindHealthApp());

    // Verify that our login screen text is present.
    expect(find.text('Re-Connect\nPlatform'), findsOneWidget);
  });
}
