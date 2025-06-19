import 'dart:async';
import '../lib/services/screen_capture_service.dart';

// Comprehensive test runner for all navigation scenarios
// Tests the animation-based navigation protection system
class NavigationTestRunner {
  final ScreenCaptureService service = ScreenCaptureService();

  Future<void> runAllTests() async {
    print('🚀 STARTING COMPREHENSIVE NAVIGATION PROTECTION TESTS\n');

    // Test all the specified use cases with our animation-based system
    await testBasicPushScenarios();
    await testComplexPushScenarios();
    await testPopScenarios();
    await testMixedNavigationScenarios();
    await testAnimationBasedProtection();

    print('\n✅ ALL TESTS COMPLETED');
  }

  // Test basic push scenarios (all false except one)
  Future<void> testBasicPushScenarios() async {
    print('📋 TESTING BASIC PUSH SCENARIOS\n');

    // Test scenario 1: All false
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': false,
      '/pageA': false,
      '/pageB': false,
      '/pageC': false,
      '/pageD': false
    });
    await _validateFinalState(false, 'All routes false');

    // Test scenario 2: Only pageA true
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': false,
      '/pageA': true,
      '/pageB': false,
      '/pageC': false,
      '/pageD': false
    });
    await _validateFinalState(false, 'Only pageA true, ending at pageD false');

    // Test scenario 3: Only pageB true
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': false,
      '/pageA': false,
      '/pageB': true,
      '/pageC': false,
      '/pageD': false
    });
    await _validateFinalState(false, 'Only pageB true, ending at pageD false');

    // Test scenario 4: Only pageC true
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': false,
      '/pageA': false,
      '/pageB': false,
      '/pageC': true,
      '/pageD': false
    });
    await _validateFinalState(false, 'Only pageC true, ending at pageD false');

    // Test scenario 5: Only pageD true
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': false,
      '/pageA': false,
      '/pageB': false,
      '/pageC': false,
      '/pageD': true
    });
    await _validateFinalState(true, 'Only pageD true, ending at pageD true');
  }

  // Test complex push scenarios (multiple true routes)
  Future<void> testComplexPushScenarios() async {
    print('📋 TESTING COMPLEX PUSH SCENARIOS\n');

    // Scenario: pageA and pageB true
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': false,
      '/pageA': true,
      '/pageB': true,
      '/pageC': false,
      '/pageD': false
    });
    await _validateFinalState(
        false, 'pageA and pageB true, ending at pageD false');

    // Scenario: pageA and pageD true
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': false,
      '/pageA': true,
      '/pageB': false,
      '/pageC': false,
      '/pageD': true
    });
    await _validateFinalState(
        true, 'pageA and pageD true, ending at pageD true');

    // Scenario: All true
    await _simulateNavigationSequence([
      '/',
      '/pageA',
      '/pageB',
      '/pageC',
      '/pageD'
    ], {
      '/': true,
      '/pageA': true,
      '/pageB': true,
      '/pageC': true,
      '/pageD': true
    });
    await _validateFinalState(true, 'All routes true, ending at pageD true');
  }

  // Test pop scenarios
  Future<void> testPopScenarios() async {
    print('📋 TESTING POP SCENARIOS\n');

    // Setup: Navigate to pageB, then pop back to pageA
    _resetServiceState();
    service.enableProtectionForRoute('/pageA');
    service.disableProtectionForRoute('/pageB');

    // Simulate navigation sequence: / -> /pageA -> /pageB
    service.onNavigationStart('/', '/pageA');
    await service.onNavigationComplete('/pageA');
    service.onNavigationStart('/pageA', '/pageB');
    await service.onNavigationComplete('/pageB');

    // Now pop back to /pageA
    service.onNavigationStart('/pageB', '/pageA');
    await service.onNavigationComplete('/pageA');

    // Validate that we're back on protected pageA
    await _validateFinalState(true, 'Popped back to protected pageA');

    print('✅ Pop scenario completed successfully');
  }

  // Test mixed navigation scenarios
  Future<void> testMixedNavigationScenarios() async {
    print('📋 TESTING MIXED NAVIGATION SCENARIOS\n');

    // Complex scenario: Navigate, pop, navigate again
    _resetServiceState();
    service.enableProtectionForRoute('/pageA');
    service.enableProtectionForRoute('/pageC');
    service.disableProtectionForRoute('/pageB');

    // / -> /pageA (protected)
    service.onNavigationStart('/', '/pageA');
    await service.onNavigationComplete('/pageA');
    print(
        '   After navigating to /pageA: ${service.isProtected ? "PROTECTED" : "UNPROTECTED"}');

    // /pageA -> /pageB (unprotected)
    service.onNavigationStart('/pageA', '/pageB');
    await service.onNavigationComplete('/pageB');
    print(
        '   After navigating to /pageB: ${service.isProtected ? "PROTECTED" : "UNPROTECTED"}');

    // /pageB -> /pageC (protected)
    service.onNavigationStart('/pageB', '/pageC');
    await service.onNavigationComplete('/pageC');
    print(
        '   After navigating to /pageC: ${service.isProtected ? "PROTECTED" : "UNPROTECTED"}');

    // Pop back to /pageB (unprotected)
    service.onNavigationStart('/pageC', '/pageB');
    await service.onNavigationComplete('/pageB');
    print(
        '   After popping to /pageB: ${service.isProtected ? "PROTECTED" : "UNPROTECTED"}');

    // Final validation
    await _validateFinalState(
        false, 'Mixed navigation ending at unprotected pageB');

    print('✅ Mixed navigation scenario completed successfully');
  }

  // Test animation-based protection (new functionality)
  Future<void> testAnimationBasedProtection() async {
    print('📋 TESTING ANIMATION-BASED PROTECTION\n');

    // Test that transitions are properly tracked
    _resetServiceState();
    service.enableProtectionForRoute('/pageA');
    service.enableProtectionForRoute('/pageB');

    // Start navigation
    service.onNavigationStart('/', '/pageA');
    print(
        '   During transition: ${service.isTransitioning ? "TRANSITIONING" : "NOT TRANSITIONING"}');

    // Complete navigation
    await service.onNavigationComplete('/pageA');
    print(
        '   After completion: ${service.isTransitioning ? "TRANSITIONING" : "NOT TRANSITIONING"}');
    print('   Current route: ${service.getCurrentRoute()}');
    print(
        '   Protection status: ${service.isProtected ? "PROTECTED" : "UNPROTECTED"}');

    // Validate transition handling
    if (!service.isTransitioning &&
        service.getCurrentRoute() == '/pageA' &&
        service.isProtected) {
      print('✅ Animation-based protection working correctly');
    } else {
      print('❌ Animation-based protection failed');
    }
  }

  // Helper method to simulate navigation sequence
  Future<void> _simulateNavigationSequence(
      List<String> routes, Map<String, bool> protectionSettings) async {
    _resetServiceState();

    // Configure protection settings for all routes
    for (final entry in protectionSettings.entries) {
      if (entry.value) {
        service.enableProtectionForRoute(entry.key);
      } else {
        service.disableProtectionForRoute(entry.key);
      }
    }

    // Simulate navigation through all routes
    for (int i = 1; i < routes.length; i++) {
      String fromRoute = routes[i - 1];
      String toRoute = routes[i];

      service.onNavigationStart(fromRoute, toRoute);
      await service.onNavigationComplete(toRoute);

      print(
          '   Navigated: $fromRoute -> $toRoute (${service.isProtected ? "PROTECTED" : "UNPROTECTED"})');
    }
  }

  // Helper method to validate final state
  Future<void> _validateFinalState(
      bool expectedProtection, String description) async {
    final actualProtection = service.isProtected;
    final status = actualProtection == expectedProtection ? '✅' : '❌';

    print('   $status $description');
    print('   Expected: ${expectedProtection ? "PROTECTED" : "UNPROTECTED"}');
    print('   Actual: ${actualProtection ? "PROTECTED" : "UNPROTECTED"}');

    if (actualProtection != expectedProtection) {
      print('   ⚠️  TEST FAILED: Protection state mismatch!');
    }

    print(''); // Add blank line for readability
  }

  // Helper method to reset service state
  void _resetServiceState() {
    // Reset all route protection settings to false
    final routes = ['/', '/pageA', '/pageB', '/pageC', '/pageD'];
    for (final route in routes) {
      service.disableProtectionForRoute(route);
    }
  }
}

// Entry point to run the tests
void main() async {
  final runner = NavigationTestRunner();
  await runner.runAllTests();
}
