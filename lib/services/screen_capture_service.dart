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
  void onNavigationStart(String fromRoute, String toRoute) {
    _isTransitioning = true;
    _previousRoute = fromRoute;
    _currentRoute = toRoute;
    
    // If either route requires protection, enable it during transition
    if (isProtectionEnabledForRoute(fromRoute) || isProtectionEnabledForRoute(toRoute)) {
      enableProtection();
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

  // Ensure protection during critical operations
  Future<void> ensureProtectionDuringTransition() async {
    if (_isTransitioning) {
      // During transition, apply protection if either route needs it
      bool needsProtection = false;
      if (_currentRoute != null && isProtectionEnabledForRoute(_currentRoute!)) {
        needsProtection = true;
      }
      if (_previousRoute != null && isProtectionEnabledForRoute(_previousRoute!)) {
        needsProtection = true;
      }
      
      if (needsProtection && !_isProtected) {
        await enableProtection();
      }
    }
  }
}
