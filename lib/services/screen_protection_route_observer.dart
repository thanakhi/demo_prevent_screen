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

        // Start navigation with proper route information for real navigation
        _screenCaptureService.onNavigationStart(previousRouteName!, routeName);

        // Use animation completion callback instead of fixed delay
        _listenToAnimationCompletion(route, routeName);
      }
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

        // Start navigation transition properly
        _screenCaptureService.onNavigationStart(
            poppedRouteName, previousRouteName);

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
        _screenCaptureService.onNavigationStart(oldRouteName, newRouteName);

        // Ensure protection during replace animation
        _screenCaptureService.ensureProtectionDuringTransition();

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
