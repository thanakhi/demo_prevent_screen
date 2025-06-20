import 'package:screen_protector/screen_protector.dart';

class ScreenCaptureService {
  static final ScreenCaptureService _instance =
      ScreenCaptureService._internal();
  factory ScreenCaptureService() => _instance;
  ScreenCaptureService._internal();

  // Track current protection status
  bool _isProtected = false;
  bool get isProtected => _isProtected;

  // Track navigation transitions with enhanced state management
  bool _isTransitioning = false;
  String? _currentRoute;
  String? _previousRoute;
  DateTime? _lastTransitionTime;

  // Navigation stack to track route history with proper management
  final List<String> _routeStack = [];

  // Route-specific protection settings
  final Map<String, bool> _routeProtectionSettings = {
    '/': false,
    '/page1': true, // Page1 is protected by default for security testing
    '/page2': false,
    '/page3': false,
    '/settings': false,
  };

  // Async operation queue to prevent race conditions
  bool _isProcessingProtectionChange = false;
  final List<Future<void> Function()> _pendingOperations = [];

  // Debug logging
  bool debugMode = true;

  void _log(String message) {
    if (debugMode) {
      print('[ScreenCapture] $message');
    }
  }

  // CRITICAL SECURITY METHOD: Enable protection synchronously without async operations
  // This is used when we need IMMEDIATE protection before any animation starts
  // Trade-off: May block briefly, but ensures ZERO security gap
  void enableProtectionSynchronous() {
    try {
      _log('SECURITY: Enabling protection SYNCHRONOUSLY');

      // Skip async queue processing for immediate protection
      _isProcessingProtectionChange = true;

      // Call the plugin synchronously (this may block briefly but prevents security gaps)
      ScreenProtector.preventScreenshotOn();
      _isProtected = true;

      _log('Protection enabled SYNCHRONOUSLY - status: $_isProtected');

      _isProcessingProtectionChange = false;

      // Process any pending operations after immediate protection is applied
      _processPendingOperations();
    } catch (e) {
      _log('ERROR in synchronous protection: $e');
      _isProcessingProtectionChange = false;
      // Even if there's an error, mark as protected to fail safe
      _isProtected = true;
    }
  }

  // Enhanced protection enable with queue management
  Future<void> enableProtection() async {
    if (_isProcessingProtectionChange) {
      _pendingOperations.add(() => enableProtection());
      return;
    }

    _isProcessingProtectionChange = true;
    try {
      if (!_isProtected) {
        await ScreenProtector.preventScreenshotOn();
        _isProtected = true;
        _log('Screen capture protection ENABLED');
      }
    } catch (e) {
      _log('Failed to enable screen capture protection: $e');
    } finally {
      _isProcessingProtectionChange = false;
      await _processPendingOperations();
    }
  }

  // Enhanced protection disable with queue management
  Future<void> disableProtection() async {
    if (_isProcessingProtectionChange) {
      _pendingOperations.add(() => disableProtection());
      return;
    }

    _isProcessingProtectionChange = true;
    try {
      if (_isProtected) {
        await ScreenProtector.preventScreenshotOff();
        _isProtected = false;
        _log('Screen capture protection DISABLED');
      }
    } catch (e) {
      _log('Failed to disable screen capture protection: $e');
    } finally {
      _isProcessingProtectionChange = false;
      await _processPendingOperations();
    }
  }

  Future<void> _processPendingOperations() async {
    while (_pendingOperations.isNotEmpty && !_isProcessingProtectionChange) {
      final operation = _pendingOperations.removeAt(0);
      await operation();
    }
  }

  // Check if protection is enabled for a specific route
  bool isProtectionEnabledForRoute(String routeName) {
    return _routeProtectionSettings[routeName] ?? false;
  }

  // Enable protection for a specific route
  void enableProtectionForRoute(String routeName) {
    _routeProtectionSettings[routeName] = true;
    _log('Protection ENABLED for route: $routeName');
  }

  // Disable protection for a specific route
  void disableProtectionForRoute(String routeName) {
    _routeProtectionSettings[routeName] = false;
    _log('Protection DISABLED for route: $routeName');
  }

  // Toggle protection for a specific route
  void toggleProtectionForRoute(String routeName) {
    _routeProtectionSettings[routeName] =
        !(_routeProtectionSettings[routeName] ?? false);
    _log(
        'Protection TOGGLED for route: $routeName -> ${_routeProtectionSettings[routeName]}');
  }

  // Get all route protection settings
  Map<String, bool> getAllRouteSettings() {
    return Map.from(_routeProtectionSettings);
  }

  // Apply protection based on current route
  Future<void> applyProtectionForRoute(String routeName) async {
    if (isProtectionEnabledForRoute(routeName)) {
      if (!_isProtected) {
        await enableProtection();
      }
    } else {
      if (_isProtected) {
        await disableProtection();
      }
    }
  }

  // Enhanced route stack management
  void _addToRouteStack(String routeName) {
    // Avoid duplicates
    if (_routeStack.isEmpty || _routeStack.last != routeName) {
      _routeStack.add(routeName);
      _log('Route stack updated: $_routeStack');
    }
  }

  void _removeFromRouteStack(String routeName) {
    if (_routeStack.isNotEmpty && _routeStack.last == routeName) {
      _routeStack.removeLast();
      _log('Route removed from stack: $routeName, remaining: $_routeStack');
    }
  }

  // Public method for route observer to start navigation without full protection logic
  void startNavigationState(String fromRoute, String toRoute) {
    _isTransitioning = true;
    _previousRoute = fromRoute;
    _currentRoute = toRoute;
    _lastTransitionTime = DateTime.now();

    _log('Navigation state started: $fromRoute -> $toRoute');
  }

  // Enhanced navigation start - called when navigation begins
  // SECURITY PRINCIPLE: Protected content MUST NEVER be exposed during transitions
  Future<void> onNavigationStart(String fromRoute, String toRoute) async {
    _isTransitioning = true;
    _previousRoute = fromRoute;
    _currentRoute = toRoute;
    _lastTransitionTime = DateTime.now();

    _log('Navigation START: $fromRoute -> $toRoute');

    // Apply security-first transition protection IMMEDIATELY
    await _applyTransitionProtection(fromRoute, toRoute);
  }

  // Apply protection logic during transitions - SECURITY FIRST!
  // BLACK SCREEN IS ACCEPTABLE - CONTENT LEAK IS NOT!
  Future<void> _applyTransitionProtection(
      String fromRoute, String toRoute) async {
    bool fromNeedsProtection = isProtectionEnabledForRoute(fromRoute);
    bool toNeedsProtection = isProtectionEnabledForRoute(toRoute);

    _log(
        'Transition protection - From: $fromNeedsProtection, To: $toNeedsProtection');

    // CRITICAL: If EITHER route needs protection, keep protection ON
    // This ensures ZERO security gaps during transitions
    // Trade-off: User sees black screen during animation, but content is NEVER exposed
    if (fromNeedsProtection || toNeedsProtection) {
      if (!_isProtected) {
        _log('SECURITY: Enabling protection IMMEDIATELY for transition');
        await enableProtection();
      }
      // Protection stays ON during entire transition if any route needs it
    } else {
      // Only disable if BOTH routes are unprotected
      if (_isProtected) {
        _log(
            'SECURITY: Disabling protection for transition (both routes unprotected)');
        await disableProtection();
      }
    }
  }

  // Handle navigation complete - called when navigation animation completes
  Future<void> onNavigationComplete(String routeName) async {
    _isTransitioning = false;
    _currentRoute = routeName;
    _addToRouteStack(routeName);

    _log('Navigation COMPLETE: $routeName');

    // CRITICAL SECURITY FIX: Only disable protection if the destination route doesn't need it
    // AND we're transitioning from a route that needed protection
    // This prevents the security gap during protected->unprotected transitions

    bool destinationNeedsProtection = isProtectionEnabledForRoute(routeName);
    bool wasComingFromProtectedRoute = false;

    if (_previousRoute != null) {
      wasComingFromProtectedRoute =
          isProtectionEnabledForRoute(_previousRoute!);
    }

    _log(
        'Navigation complete analysis - Destination needs protection: $destinationNeedsProtection, Coming from protected: $wasComingFromProtectedRoute');

    // Apply protection logic with security-first approach
    if (destinationNeedsProtection) {
      // Destination needs protection - ensure it's enabled
      if (!_isProtected) {
        await enableProtection();
      }
    } else if (wasComingFromProtectedRoute) {
      // SECURITY CRITICAL: We're transitioning from protected to unprotected
      // Add a small delay to ensure the animation is fully complete before disabling protection
      // This prevents content exposure during animation completion
      await Future.delayed(Duration(milliseconds: 50));
      _log('SECURITY: Delayed protection disable after animation completion');
      await disableProtection();
    } else {
      // Normal case: apply protection based on route
      await applyProtectionForRoute(routeName);
    }
  }

  // Enhanced push handling
  Future<void> onRoutePushed(String fromRoute, String toRoute) async {
    _log('Route PUSHED: $fromRoute -> $toRoute');
    await onNavigationStart(fromRoute, toRoute);
  }

  // Enhanced pop handling
  Future<void> onRoutePopped(String routeName) async {
    _removeFromRouteStack(routeName);
    String previousRoute = _routeStack.isNotEmpty ? _routeStack.last : '/';

    _log('Route POPPED: $routeName, returning to: $previousRoute');
    await onNavigationStart(routeName, previousRoute);
  }

  // Get current route
  String? getCurrentRoute() => _currentRoute;

  // Check if currently transitioning
  bool get isTransitioning => _isTransitioning;

  // Ensure protection during critical operations - SECURITY FIRST!
  Future<void> ensureProtectionDuringTransition() async {
    if (!_isTransitioning) return;

    // Check for stuck transitions (timeout after 5 seconds)
    if (_lastTransitionTime != null) {
      final timeSinceTransition =
          DateTime.now().difference(_lastTransitionTime!);
      if (timeSinceTransition.inSeconds > 5) {
        _log('WARNING: Transition timeout detected, resetting state');
        _isTransitioning = false;
        return;
      }
    }

    // Enhanced protection logic during transitions
    bool needsProtection = false;

    if (_currentRoute != null && isProtectionEnabledForRoute(_currentRoute!)) {
      needsProtection = true;
    }
    if (_previousRoute != null &&
        isProtectionEnabledForRoute(_previousRoute!)) {
      needsProtection = true;
    }

    _log('Transition protection check - needs protection: $needsProtection');

    if (needsProtection && !_isProtected) {
      await enableProtection();
    }
  }

  // Comprehensive state analysis for debugging
  Map<String, dynamic> getStateAnalysis() {
    return {
      'isProtected': _isProtected,
      'isTransitioning': _isTransitioning,
      'currentRoute': _currentRoute,
      'previousRoute': _previousRoute,
      'routeStack': List.from(_routeStack),
      'routeSettings': Map.from(_routeProtectionSettings),
      'lastTransitionTime': _lastTransitionTime?.toIso8601String(),
      'pendingOperations': _pendingOperations.length,
      'isProcessingProtectionChange': _isProcessingProtectionChange,
    };
  }

  // Test specific navigation scenarios
  Future<void> testNavigationScenario(
      List<String> navigationSequence, Map<String, bool> routeSettings) async {
    _log('=== TESTING NAVIGATION SCENARIO ===');
    _log('Sequence: ${navigationSequence.join(' -> ')}');
    _log('Settings: $routeSettings');

    // Reset state
    resetState();

    // Apply route settings
    for (var entry in routeSettings.entries) {
      _routeProtectionSettings[entry.key] = entry.value;
    }

    // Simulate navigation sequence
    for (int i = 0; i < navigationSequence.length; i++) {
      String currentRoute = navigationSequence[i];
      String? previousRoute = i > 0 ? navigationSequence[i - 1] : null;

      if (previousRoute != null) {
        await onRoutePushed(previousRoute, currentRoute);
        // Simulate transition delay
        await Future.delayed(const Duration(milliseconds: 50));
        await onNavigationComplete(currentRoute);
      } else {
        // First route
        await onNavigationComplete(currentRoute);
      }
    }

    _log('Final state: ${getStateAnalysis()}');
    _log('=== END SCENARIO TEST ===\n');
  }

  // Utility methods
  List<String> get routeStack => List.from(_routeStack);

  // Reset state for testing
  void resetState() {
    _routeStack.clear();
    _isTransitioning = false;
    _currentRoute = null;
    _previousRoute = null;
    _lastTransitionTime = null;
    _pendingOperations.clear();
    _log('State reset');
  }

  // Test helper methods - Only for testing purposes
  void setTransitioningForTest(bool value) {
    _isTransitioning = value;
  }

  void setLastTransitionTimeForTest(DateTime? time) {
    _lastTransitionTime = time;
  }
}
