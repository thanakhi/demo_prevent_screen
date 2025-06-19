import 'package:screen_protector/screen_protector.dart';
import 'package:flutter/material.dart';

class ScreenCaptureService {
  static final ScreenCaptureService _instance =
      ScreenCaptureService._internal();
  factory ScreenCaptureService() => _instance;
  ScreenCaptureService._internal();

  // Track current protection status
  bool _isProtected = false;
  bool get isProtected => _isProtected;

  // Track navigation transitions
  bool _isTransitioning = false;
  String? _currentRoute;
  String? _previousRoute;

  // Navigation stack to track route history
  final List<String> _routeStack = [];

  // Route-specific protection settings
  final Map<String, bool> _routeProtectionSettings = {
    '/': false,
    '/page1': false,
    '/page2': false,
    '/page3': false,
  };

  // Enable screen capture prevention
  Future<void> enableProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      _isProtected = true;
      print('Screen capture protection enabled');
    } catch (e) {
      print('Failed to enable screen capture protection: $e');
    }
  }

  // Disable screen capture prevention
  Future<void> disableProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      _isProtected = false;
      print('Screen capture protection disabled');
    } catch (e) {
      print('Failed to disable screen capture protection: $e');
    }
  }

  // Check if protection is enabled for a specific route
  bool isProtectionEnabledForRoute(String routeName) {
    return _routeProtectionSettings[routeName] ?? false;
  }

  // Enable protection for a specific route
  void enableProtectionForRoute(String routeName) {
    _routeProtectionSettings[routeName] = true;
  }

  // Disable protection for a specific route
  void disableProtectionForRoute(String routeName) {
    _routeProtectionSettings[routeName] = false;
  }

  // Toggle protection for a specific route
  void toggleProtectionForRoute(String routeName) {
    _routeProtectionSettings[routeName] =
        !(_routeProtectionSettings[routeName] ?? false);
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

  // Handle navigation start - called when navigation begins
  // SECURITY PRINCIPLE: Protected content MUST NEVER be exposed during transitions
  void onNavigationStart(String fromRoute, String toRoute) {
    _isTransitioning = true;
    _previousRoute = fromRoute;
    _currentRoute = toRoute;

    // Apply security-first transition protection
    _applyTransitionProtection(fromRoute, toRoute);
  }

  // Apply protection logic during transitions - SECURITY FIRST!
  // BLACK SCREEN IS ACCEPTABLE - CONTENT LEAK IS NOT!
  void _applyTransitionProtection(String fromRoute, String toRoute) {
    bool fromNeedsProtection = isProtectionEnabledForRoute(fromRoute);
    bool toNeedsProtection = isProtectionEnabledForRoute(toRoute);

    // CRITICAL: If EITHER route needs protection, keep protection ON
    // This ensures ZERO security gaps during transitions
    // Trade-off: User sees black screen during animation, but content is NEVER exposed
    if (fromNeedsProtection || toNeedsProtection) {
      if (!_isProtected) {
        enableProtection();
      }
      // Protection stays ON during entire transition if any route needs it
    } else {
      // Only disable if BOTH routes are unprotected
      if (_isProtected) {
        disableProtection();
      }
    }
  }

  // Handle navigation complete - called when navigation animation completes
  Future<void> onNavigationComplete(String routeName) async {
    _isTransitioning = false;
    _currentRoute = routeName;
    _routeStack.add(routeName);

    // Apply appropriate protection for the new route
    await applyProtectionForRoute(routeName);
  }

  // Handle route push
  void onRoutePushed(String routeName) {
    _routeStack.add(routeName);
    onNavigationStart(_currentRoute ?? '/', routeName);
  }

  // Handle route popped
  void onRoutePopped(String routeName) {
    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }

    String previousRoute = _routeStack.isNotEmpty ? _routeStack.last : '/';
    onNavigationStart(routeName, previousRoute);
  }

  // Get current route
  String? getCurrentRoute() => _currentRoute;

  // Check if currently transitioning
  bool get isTransitioning => _isTransitioning;

  // Ensure protection during critical operations - SECURITY FIRST!
  Future<void> ensureProtectionDuringTransition() async {
    if (_isTransitioning && _previousRoute != null && _currentRoute != null) {
      // During transition, protection must be ON if ANY route needs it
      bool anyRouteNeedsProtection =
          isProtectionEnabledForRoute(_previousRoute!) ||
              isProtectionEnabledForRoute(_currentRoute!);

      if (anyRouteNeedsProtection && !_isProtected) {
        await enableProtection();
      }
    }
  }
}
