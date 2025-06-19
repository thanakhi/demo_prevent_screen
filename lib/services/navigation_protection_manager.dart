import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';

class NavigationProtectionManager {
  static final NavigationProtectionManager _instance =
      NavigationProtectionManager._internal();
  factory NavigationProtectionManager() => _instance;
  NavigationProtectionManager._internal();

  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();
  final Set<String> _activeTransitions = <String>{};

  // Override Navigator.push to ensure protection during transitions
  static Future<T?> pushWithProtection<T extends Object?>(
    BuildContext context,
    String routeName,
    Widget page,
  ) async {
    final manager = NavigationProtectionManager();
    await manager._prepareForNavigation(routeName);

    final route = PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return manager._buildProtectedTransition(
            context, animation, secondaryAnimation, child, routeName);
      },
    );

    try {
      final result = await Navigator.of(context).push(route);
      return result;
    } finally {
      await manager._completeNavigation(routeName);
    }
  }

  // Override Navigator.pop to ensure protection during pop transitions
  static void popWithProtection<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) {
    final manager = NavigationProtectionManager();
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute != null) {
      manager._prepareForPop(currentRoute);
    }

    Navigator.of(context).pop(result);
  }

  Future<void> _prepareForNavigation(String routeName) async {
    _activeTransitions.add(routeName);

    // If the target route or any currently active route needs protection, enable it
    bool needsProtection =
        _screenCaptureService.isProtectionEnabledForRoute(routeName);

    // Check if any active transitions require protection
    for (String activeRoute in _activeTransitions) {
      if (_screenCaptureService.isProtectionEnabledForRoute(activeRoute)) {
        needsProtection = true;
        break;
      }
    }

    if (needsProtection) {
      await _screenCaptureService.enableProtection();
    }
  }

  Future<void> _completeNavigation(String routeName) async {
    _activeTransitions.remove(routeName);

    // Apply protection for the final route
    await _screenCaptureService.applyProtectionForRoute(routeName);
  }

  void _prepareForPop(String routeName) {
    _activeTransitions.add('pop_$routeName');

    // Ensure protection during pop if needed
    if (_screenCaptureService.isProtectionEnabledForRoute(routeName)) {
      _screenCaptureService.enableProtection();
    }
  }

  Widget _buildProtectedTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    String routeName,
  ) {
    // Monitor animation status
    animation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          // Transition starting
          _screenCaptureService.ensureProtectionDuringTransition();
          break;
        case AnimationStatus.completed:
          // Transition completed
          _completeNavigation(routeName);
          break;
        case AnimationStatus.reverse:
          // Transition reversing (pop)
          _screenCaptureService.ensureProtectionDuringTransition();
          break;
        case AnimationStatus.dismissed:
          // Transition dismissed
          _activeTransitions.remove('pop_$routeName');
          break;
      }
    });

    // Use slide transition
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    final slideTween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return SlideTransition(
      position: slideTween.animate(curvedAnimation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  // Get currently active transitions
  Set<String> getActiveTransitions() => Set.from(_activeTransitions);

  // Check if any transition is currently active
  bool get hasActiveTransitions => _activeTransitions.isNotEmpty;
}
