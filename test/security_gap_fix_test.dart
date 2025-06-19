import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/services/screen_capture_service.dart';

void main() {
  // Initialize Flutter testing environment
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Security Gap Fix Tests', () {
    late ScreenCaptureService service;

    setUp(() {
      service = ScreenCaptureService();
      service.resetState();

      // Mock the screen protector plugin for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('screen_protector'),
        (MethodCall methodCall) async {
          // Mock successful protection calls
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

    test('CRITICAL: Protected to unprotected transition has NO security gap',
        () async {
      // Setup: Page1 is protected, Page2 is not protected
      service.enableProtectionForRoute('/page1');
      service.disableProtectionForRoute('/page2');

      // Simulate being on protected page1
      await service.onNavigationComplete('/page1');
      expect(service.isProtected, true, reason: 'Should be protected on page1');

      print('🔒 Starting from protected page1 (protection ON)');

      // CRITICAL TEST: Start navigation from protected page1 to unprotected page2
      // This should IMMEDIATELY keep protection ON during transition
      await service.onNavigationStart('/page1', '/page2');

      // SECURITY VERIFICATION: Protection MUST stay ON during transition
      expect(service.isProtected, true,
          reason:
              'SECURITY CRITICAL: Protection must stay ON during transition from protected to unprotected page');

      print(
          '✅ SECURITY VERIFIED: Protection stays ON during page1->page2 transition');

      // Simulate animation completion - now protection should be disabled
      await service.onNavigationComplete('/page2');
      expect(service.isProtected, false,
          reason:
              'Protection should be OFF after completing navigation to unprotected page2');

      print(
          '✅ Protection correctly disabled after animation completes on unprotected page2');
    });

    test(
        'CRITICAL: Unprotected to protected transition enables protection immediately',
        () async {
      // Setup: Page2 is not protected, Page1 is protected
      service.disableProtectionForRoute('/page2');
      service.enableProtectionForRoute('/page1');

      // Simulate being on unprotected page2
      await service.onNavigationComplete('/page2');
      expect(service.isProtected, false,
          reason: 'Should not be protected on page2');

      print('🔓 Starting from unprotected page2 (protection OFF)');

      // CRITICAL TEST: Start navigation from unprotected page2 to protected page1
      // This should IMMEDIATELY enable protection
      await service.onNavigationStart('/page2', '/page1');

      // SECURITY VERIFICATION: Protection MUST be ON immediately
      expect(service.isProtected, true,
          reason:
              'SECURITY CRITICAL: Protection must be enabled IMMEDIATELY when navigating to protected page');

      print(
          '✅ SECURITY VERIFIED: Protection enabled immediately for page2->page1 transition');

      // Animation completion should maintain protection
      await service.onNavigationComplete('/page1');
      expect(service.isProtected, true,
          reason:
              'Protection should stay ON after completing navigation to protected page1');

      print(
          '✅ Protection correctly maintained after animation completes on protected page1');
    });

    test('CRITICAL: Protected to protected transition maintains protection',
        () async {
      // Setup: Both pages are protected
      service.enableProtectionForRoute('/page1');
      service.enableProtectionForRoute('/page3');

      // Simulate being on protected page1
      await service.onNavigationComplete('/page1');
      expect(service.isProtected, true, reason: 'Should be protected on page1');

      print('🔒 Starting from protected page1 (protection ON)');

      // Start navigation from protected page1 to protected page3
      await service.onNavigationStart('/page1', '/page3');

      // Protection should stay ON throughout
      expect(service.isProtected, true,
          reason:
              'Protection must stay ON during protected->protected transition');

      print('✅ Protection maintained during page1->page3 transition');

      // Animation completion should maintain protection
      await service.onNavigationComplete('/page3');
      expect(service.isProtected, true,
          reason:
              'Protection should stay ON after completing navigation to protected page3');

      print('✅ Protection correctly maintained on protected page3');
    });

    test('CRITICAL: Multiple rapid transitions handle protection correctly',
        () async {
      // Setup mixed protection
      service.enableProtectionForRoute('/page1'); // protected
      service.disableProtectionForRoute('/page2'); // unprotected
      service.enableProtectionForRoute('/page3'); // protected

      // Start on unprotected page
      await service.onNavigationComplete('/page2');
      expect(service.isProtected, false);

      print('🔓 Starting rapid navigation test from unprotected page2');

      // Rapid transition 1: unprotected -> protected
      await service.onNavigationStart('/page2', '/page1');
      expect(service.isProtected, true,
          reason: 'Must be protected immediately');
      print('✅ Transition 1: page2->page1 protection enabled');

      // Rapid transition 2: protected -> protected (before first completes)
      await service.onNavigationStart('/page1', '/page3');
      expect(service.isProtected, true, reason: 'Must stay protected');
      print('✅ Transition 2: page1->page3 protection maintained');

      // Complete final transition
      await service.onNavigationComplete('/page3');
      expect(service.isProtected, true, reason: 'Must be protected on page3');
      print('✅ Final state: protected on page3');
    });

    test('SECURITY AUDIT: Verify no timing gaps in async operations', () async {
      service.enableProtectionForRoute('/page1');
      service.disableProtectionForRoute('/page2');

      // Start with protection ON
      await service.onNavigationComplete('/page1');
      expect(service.isProtected, true);

      // Measure timing of protection during transition
      final stopwatch = Stopwatch()..start();

      await service.onNavigationStart('/page1', '/page2');

      stopwatch.stop();

      // Verify protection was applied immediately (within reasonable time)
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Protection should be applied within 100ms');

      expect(service.isProtected, true,
          reason: 'Protection must be active after async operation completes');

      print(
          '✅ SECURITY AUDIT PASSED: Protection applied in ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
