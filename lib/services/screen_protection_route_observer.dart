import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';

class ScreenProtectionRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  // Track active animation listeners to prevent memory leaks
  final Map<Route, AnimationStatusListener> _animationListeners = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route is PageRoute) {
      String? routeName = route.settings.name;
      String? previousRouteName = previousRoute?.settings.name;

      if (routeName != null) {
        print('Route pushed: $routeName');

        // Handle initial route differently - don't set up navigation transition
        if (previousRoute == null) {
          // This is the initial route, just complete it immediately
          _screenCaptureService.onNavigationComplete(routeName);
          return;
        }

        // CRITICAL SECURITY FIX: Apply protection IMMEDIATELY and SYNCHRONOUSLY
        // We cannot allow ANY delay between navigation start and protection application
        _applyImmediateProtection(previousRouteName!, routeName);

        // Use animation completion callback instead of fixed delay
        _listenToAnimationCompletion(route, routeName);
      }
    }
  }

  // Handle navigation start asynchronously to ensure protection is applied immediately
  void _handleNavigationStart(String fromRoute, String toRoute) async {
    try {
      await _screenCaptureService.onNavigationStart(fromRoute, toRoute);
    } catch (e) {
      print('Error in navigation start: $e');
    }
  }

  // CRITICAL SECURITY FIX: Apply protection immediately and synchronously
  // This method ensures ZERO gap between navigation start and protection application
  void _applyImmediateProtection(String fromRoute, String toRoute) {
    try {
      // Apply protection synchronously BEFORE any animation starts
      bool fromNeedsProtection =
          _screenCaptureService.isProtectionEnabledForRoute(fromRoute);
      bool toNeedsProtection =
          _screenCaptureService.isProtectionEnabledForRoute(toRoute);

      print(
          'SECURITY: Immediate protection check - From: $fromNeedsProtection, To: $toNeedsProtection');

      // CRITICAL: If EITHER route needs protection, enable it IMMEDIATELY
      if (fromNeedsProtection || toNeedsProtection) {
        if (!_screenCaptureService.isProtected) {
          print('SECURITY: Enabling protection IMMEDIATELY (synchronous)');
          _screenCaptureService.enableProtectionSynchronous();
        }
      }

      // Now call the async navigation start method for state management
      // but DON'T let it override the synchronous protection decision
      _handleNavigationStartPreserveProtection(
          fromRoute, toRoute, fromNeedsProtection || toNeedsProtection);
    } catch (e) {
      print('CRITICAL ERROR in immediate protection: $e');
      // Fail-safe: Enable protection if there's any doubt
      if (!_screenCaptureService.isProtected) {
        _screenCaptureService.enableProtectionSynchronous();
      }
    }
  }

  // Handle navigation start but preserve synchronous protection decision
  void _handleNavigationStartPreserveProtection(
      String fromRoute, String toRoute, bool shouldKeepProtection) async {
    try {
      // Set navigation state using public method
      _screenCaptureService.startNavigationState(fromRoute, toRoute);

      print(
          'Navigation START: $fromRoute -> $toRoute (preserving protection: $shouldKeepProtection)');

      // Skip the transition protection logic if we already applied synchronous protection
      if (!shouldKeepProtection) {
        // Apply async protection for cases where no immediate protection was needed
        await _screenCaptureService.applyProtectionForRoute(toRoute);
      }
    } catch (e) {
      print('Error in navigation start: $e');
    }
  }

  // Listen to route animation completion using proper animation callbacks
  void _listenToAnimationCompletion(Route route, String routeName) {
    if (route is ModalRoute && route.animation != null) {
      late AnimationStatusListener listener;

      listener = (AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          // Animation completed - now safe to apply final protection state
          _screenCaptureService.onNavigationComplete(routeName);

          // Clean up listener to prevent memory leaks
          route.animation!.removeStatusListener(listener);
          _animationListeners.remove(route);
        } else if (status == AnimationStatus.dismissed ||
            status == AnimationStatus.reverse) {
          // Route was dismissed or reversed - clean up listener
          route.animation!.removeStatusListener(listener);
          _animationListeners.remove(route);
        }
      };

      // Store listener reference for cleanup
      _animationListeners[route] = listener;
      route.animation!.addStatusListener(listener);
    } else {
      // Fallback for routes without animation - call immediately
      _screenCaptureService.onNavigationComplete(routeName);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if (route is PageRoute && previousRoute is PageRoute) {
      String? poppedRouteName = route.settings.name;
      String? previousRouteName = previousRoute.settings.name;

      if (poppedRouteName != null && previousRouteName != null) {
        print(
            'Route popped: $poppedRouteName, returning to: $previousRouteName');

        // CRITICAL SECURITY FIX: Apply protection IMMEDIATELY for pop transitions
        _applyImmediateProtection(poppedRouteName, previousRouteName);

        // Use animation completion callback for the previous route
        _listenToPopAnimationCompletion(previousRoute, previousRouteName);
      }
    }
  }

  // Listen to pop animation completion
  void _listenToPopAnimationCompletion(Route previousRoute, String routeName) {
    if (previousRoute is ModalRoute && previousRoute.animation != null) {
      late AnimationStatusListener listener;

      listener = (AnimationStatus status) {
        // For pop animations, we need to listen for the reverse animation completion
        // The previous route's animation goes from 0 to 1 when it becomes visible again
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.forward) {
          // Pop animation completed - apply protection for the route we're returning to
          _screenCaptureService.onNavigationComplete(routeName);

          // Clean up listener
          previousRoute.animation!.removeStatusListener(listener);
          _animationListeners.remove(previousRoute);
        }
      };

      // Store listener reference for cleanup
      _animationListeners[previousRoute] = listener;
      previousRoute.animation!.addStatusListener(listener);
    } else {
      // Fallback for routes without animation
      _screenCaptureService.onNavigationComplete(routeName);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (newRoute is PageRoute && oldRoute is PageRoute) {
      String? newRouteName = newRoute.settings.name;
      String? oldRouteName = oldRoute.settings.name;

      if (newRouteName != null && oldRouteName != null) {
        print('Route replaced: $oldRouteName with $newRouteName');

        // CRITICAL SECURITY FIX: Apply protection IMMEDIATELY for replace transitions
        _applyImmediateProtection(oldRouteName, newRouteName);

        // Use animation completion callback for replace operations
        _listenToAnimationCompletion(newRoute, newRouteName);
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    // Clean up any animation listeners for the removed route
    _cleanupAnimationListener(route);

    if (route is PageRoute && previousRoute is PageRoute) {
      String? removedRouteName = route.settings.name;
      String? previousRouteName = previousRoute.settings.name;

      if (removedRouteName != null && previousRouteName != null) {
        print(
            'Route removed: $removedRouteName, active route: $previousRouteName');
        _screenCaptureService.onNavigationComplete(previousRouteName);
      }
    }
  }

  // Clean up animation listener for a specific route
  void _cleanupAnimationListener(Route route) {
    final listener = _animationListeners.remove(route);
    if (listener != null && route is ModalRoute && route.animation != null) {
      route.animation!.removeStatusListener(listener);
    }
  }

  // Clean up all animation listeners (call when disposing)
  void dispose() {
    for (final entry in _animationListeners.entries) {
      final route = entry.key;
      final listener = entry.value;
      if (route is ModalRoute && route.animation != null) {
        route.animation!.removeStatusListener(listener);
      }
    }
    _animationListeners.clear();
  }

  // Getter for testing purposes
  @visibleForTesting
  int get activeListenerCount => _animationListeners.length;
}
