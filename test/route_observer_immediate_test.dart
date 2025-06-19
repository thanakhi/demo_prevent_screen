import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../lib/services/screen_capture_service.dart';
import '../lib/services/screen_protection_route_observer.dart';

void main() {
  // Initialize Flutter testing environment
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Route Observer Synchronous Protection Tests', () {
    late ScreenCaptureService service;
    late ScreenProtectionRouteObserver observer;

    setUp(() {
      service = ScreenCaptureService();
      service.resetState();
      observer = ScreenProtectionRouteObserver();

      // Mock the screen protector plugin for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('screen_protector'),
        (MethodCall methodCall) async {
          print('📱 Plugin Call: ${methodCall.method}');

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

    test('CRITICAL: Route observer applies protection IMMEDIATELY on didPush',
        () {
      // Setup: Page1 is protected, Page2 is not protected
      service.enableProtectionForRoute('/page1');
      service.disableProtectionForRoute('/page2');

      // Simulate being on protected page1
      final page1Route = PageRouteBuilder(
        settings: RouteSettings(name: '/page1'),
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
      );

      final page2Route = PageRouteBuilder(
        settings: RouteSettings(name: '/page2'),
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
      );

      // Simulate initial route
      observer.didPush(page1Route, null);
      expect(service.isProtected, true, reason: 'Should be protected on page1');

      print(
          '🔒 INITIAL STATE: On page1 (protected) - Protection: ${service.isProtected}');

      // CRITICAL TEST: Simulate navigation from protected page1 to unprotected page2
      // The observer should apply protection IMMEDIATELY in didPush
      print(
          '🚨 CRITICAL MOMENT: Calling observer.didPush for page1->page2 transition');

      observer.didPush(page2Route, page1Route);

      // IMMEDIATE VERIFICATION: Protection must be ON right after didPush
      print(
          '🔍 IMMEDIATE CHECK: Protection status after didPush: ${service.isProtected}');
      expect(service.isProtected, true,
          reason:
              'SECURITY CRITICAL: Protection MUST be ON immediately after didPush from protected page');

      print(
          '✅ SECURITY VERIFIED: Route observer applies protection immediately');
    });

    test('CRITICAL: Route observer applies protection IMMEDIATELY on didPop',
        () {
      // Setup: Page1 is protected, Page2 is not protected
      service.enableProtectionForRoute('/page1');
      service.disableProtectionForRoute('/page2');

      // Simulate being on unprotected page2
      final page1Route = PageRouteBuilder(
        settings: RouteSettings(name: '/page1'),
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
      );

      final page2Route = PageRouteBuilder(
        settings: RouteSettings(name: '/page2'),
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
      );

      // Simulate initial state: on page2 (unprotected)
      observer.didPush(page2Route, page1Route);
      // Complete the navigation to page2
      service.onNavigationComplete('/page2');
      expect(service.isProtected, false,
          reason: 'Should not be protected on page2');

      print(
          '🔓 INITIAL STATE: On page2 (unprotected) - Protection: ${service.isProtected}');

      // CRITICAL TEST: Simulate popping back to protected page1
      print(
          '🚨 CRITICAL MOMENT: Calling observer.didPop for page2->page1 transition');

      observer.didPop(page2Route, page1Route);

      // IMMEDIATE VERIFICATION: Protection must be ON right after didPop
      print(
          '🔍 IMMEDIATE CHECK: Protection status after didPop: ${service.isProtected}');
      expect(service.isProtected, true,
          reason:
              'SECURITY CRITICAL: Protection MUST be ON immediately after didPop to protected page');

      print(
          '✅ SECURITY VERIFIED: Route observer applies protection immediately on pop');
    });

    test('VERIFICATION: Synchronous protection method works correctly', () {
      expect(service.isProtected, false, reason: 'Should start unprotected');

      // Test synchronous protection
      service.enableProtectionSynchronous();
      expect(service.isProtected, true,
          reason: 'Should be protected after synchronous enable');

      print('✅ Synchronous protection method verified');
    });
  });
}
