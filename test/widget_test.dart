// This is a basic Flutter widget test for the Screen Capture Prevention Demo app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/main.dart';

void main() {
  testWidgets('Screen Capture Prevention Demo smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app loads with the correct title.
    expect(find.text('Screen Capture Prevention Demo'), findsOneWidget);

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);

    // Verify that screen protection elements are present.
    expect(find.byIcon(Icons.security_update_warning),
        findsOneWidget); // In app bar
    expect(find.byIcon(Icons.shield_outlined),
        findsOneWidget); // In status display
    expect(find.text('Home Unprotected'), findsOneWidget); // Status text
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Test counter functionality
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    // Test protection toggle using the button
    await tester.tap(find.text('Enable Protection'));
    await tester.pump();

    // After toggling, the status should change to protected state
    expect(find.byIcon(Icons.security), findsOneWidget); // In app bar
    expect(find.byIcon(Icons.shield), findsOneWidget); // In status display
    expect(find.text('Home Protected'), findsOneWidget); // Status text
    expect(
        find.text('Disable Protection'), findsOneWidget); // Button text changed
  });

  testWidgets('Navigation to different pages works',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Test navigation to Page 1 using actual button text
    await tester.tap(find.text('Secure Page 1'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    expect(find.text('Page 1 - Sensitive Content'), findsOneWidget);
    expect(find.text('🔐 Confidential Information'), findsOneWidget);

    // Navigate back using back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Screen Capture Prevention Demo'), findsOneWidget);
  });

  testWidgets('Settings page navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap settings button
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Should be on settings page with correct title
    expect(find.text('Screen Protection Settings'), findsOneWidget);
    expect(find.text('Screen Capture Protection'), findsOneWidget);

    // Navigate back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Screen Capture Prevention Demo'), findsOneWidget);
  });
}
