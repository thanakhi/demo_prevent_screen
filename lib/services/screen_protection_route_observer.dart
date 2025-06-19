import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';

class ScreenProtectionRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route is PageRoute) {
      String? routeName = route.settings.name;
      if (routeName != null) {
        print('Route pushed: $routeName');
        _screenCaptureService.onRoutePushed(routeName);

        // Ensure protection during push animation
        _screenCaptureService.ensureProtectionDuringTransition();

        // Apply protection after a short delay to ensure route is fully loaded
        Future.delayed(const Duration(milliseconds: 100), () {
          _screenCaptureService.onNavigationComplete(routeName);
        });
      }
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
        _screenCaptureService.onRoutePopped(poppedRouteName);

        // Ensure protection during pop animation
        _screenCaptureService.ensureProtectionDuringTransition();

        // Apply protection for the route we're returning to
        Future.delayed(const Duration(milliseconds: 100), () {
          _screenCaptureService.onNavigationComplete(previousRouteName);
        });
      }
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

        Future.delayed(const Duration(milliseconds: 100), () {
          _screenCaptureService.onNavigationComplete(newRouteName);
        });
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

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
}
