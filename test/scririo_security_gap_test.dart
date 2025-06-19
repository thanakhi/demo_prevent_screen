import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/main.dart';
import '../lib/services/screen_capture_service.dart';

void main() {
  // Initialize Flutter testing environment
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Scririo Security Gap Tests - Real Scenario Simulation', () {
    setUp(() {
      // Mock the screen protector plugin for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('screen_protector'),
        (MethodCall methodCall) async {
          // Track method calls for verification
          print('📱 Screen Protector Plugin Call: ${methodCall.method}');

          switch (methodCall.method) {
            case 'preventScreenshotOn':
              return null;
            case 'preventScreenshotOff':
              return null;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      // Clean up mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('screen_protector'),
        null,
      );
    });

    testWidgets(
        'CRITICAL: Page1 (protected) -> Page2 (unprotected) animation has NO security gap',
        (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(MyApp());

      // Get service instance and set up protection
      final service = ScreenCaptureService();
      service.resetState();
      service.enableProtectionForRoute('/page1');
      service.disableProtectionForRoute('/page2');

      // Verify we're on the home page initially
      expect(find.text('Screen Capture Prevention Demo'), findsOneWidget);

      // Navigate to Page 1 (protected)
      await tester.tap(find.text('Secure Page 1'));
      await tester.pumpAndSettle(); // Wait for animation to complete

      // Verify we're on Page 1 and protection is enabled
      expect(find.text('Page 1'), findsOneWidget);
      expect(service.isProtected, true,
          reason: 'Should be protected on Page 1');

      print(
          '🔒 ON PAGE 1 (PROTECTED) - Protection Status: ${service.isProtected}');

      // CRITICAL TEST: Tap "Go to Page 2" button but DON'T wait for animation to settle
      // This simulates the exact moment when scririo would capture during animation
      await tester.tap(find.text('Go to Page 2'));

      // IMMEDIATE CHECK: Protection status RIGHT AFTER navigation starts
      // This is the critical moment where scririo found the security gap
      print(
          '🚨 SECURITY CRITICAL MOMENT: Navigation started, checking protection...');
      expect(service.isProtected, true,
          reason:
              'SECURITY CRITICAL: Protection MUST be ON immediately when navigation starts from protected page');

      // Pump a few frames to simulate the beginning of animation
      await tester.pump(); // First frame of animation
      expect(service.isProtected, true,
          reason: 'Protection must stay ON during first frame of animation');

      await tester.pump(Duration(milliseconds: 50)); // Early animation
      expect(service.isProtected, true,
          reason: 'Protection must stay ON during early animation phase');

      await tester.pump(Duration(milliseconds: 100)); // Mid animation
      expect(service.isProtected, true,
          reason: 'Protection must stay ON during mid animation phase');

      print(
          '✅ SECURITY VERIFIED: Protection maintained throughout animation start and middle phases');

      // Complete the animation
      await tester.pumpAndSettle();

      // Verify we're now on Page 2 and protection is properly disabled
      expect(find.text('Page 2'), findsOneWidget);
      expect(service.isProtected, false,
          reason:
              'Protection should be OFF after animation completes on unprotected Page 2');

      print(
          '🔓 ANIMATION COMPLETE - On Page 2 (unprotected), Protection Status: ${service.isProtected}');
      print(
          '✅ SCRIRIO SECURITY GAP TEST PASSED: No content exposure during protected->unprotected transition');
    });

    testWidgets(
        'CRITICAL: Multiple rapid navigation attempts cannot create security gaps',
        (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(MyApp());

      // Get service instance and set up protection
      final service = ScreenCaptureService();
      service.resetState();
      service.enableProtectionForRoute('/page1');
      service.disableProtectionForRoute('/page2');
      service.enableProtectionForRoute('/page3');

      // Navigate to Page 1 (protected)
      await tester.tap(find.text('Secure Page 1'));
      await tester.pumpAndSettle();
      expect(service.isProtected, true);

      print('🔒 Starting rapid navigation test from protected Page 1');

      // Rapid navigation: Page1 -> Page2 -> Page3 without waiting
      await tester.tap(find.text('Go to Page 2'));
      await tester.pump(); // Don't settle, start next navigation immediately

      // Even during rapid navigation, protection must be maintained
      expect(service.isProtected, true,
          reason:
              'Protection must be maintained during rapid navigation from protected page');

      // Navigate to Page 3 (protected) while still animating to Page 2
      await tester.tap(find.text('Go to Page 3'));
      await tester.pump();

      // Protection must still be ON since we're going to a protected page
      expect(service.isProtected, true,
          reason:
              'Protection must be ON when navigating to protected page during rapid navigation');

      // Complete all animations
      await tester.pumpAndSettle();

      // Should end up on Page 3 with protection enabled
      expect(find.text('Page 3'), findsOneWidget);
      expect(service.isProtected, true,
          reason: 'Should be protected on final destination Page 3');

      print(
          '✅ RAPID NAVIGATION TEST PASSED: No security gaps during rapid navigation');
    });
  });
}
