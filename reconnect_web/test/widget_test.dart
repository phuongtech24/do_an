import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reconnect_web/main.dart';

void main() {
  testWidgets('App should render without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ReConnectWeb());

    // Verify that our login screen text is present.
    expect(find.text('Re-Connect Therapist Portal'), findsNothing); // Title is just app title, text is Re-Connect Portal
    expect(find.text('Re-Connect Portal'), findsOneWidget);
  });
}
