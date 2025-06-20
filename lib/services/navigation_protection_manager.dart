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

    // Get current route from screen capture service
    String? currentRoute = _screenCaptureService.getCurrentRoute();
    if (currentRoute != null) {
      // CRITICAL: Await the navigation start to ensure protection is applied BEFORE animation
      await _screenCaptureService.onNavigationStart(currentRoute, routeName);
    } else {
      // Fallback: enable protection if target route needs it
      if (_screenCaptureService.isProtectionEnabledForRoute(routeName)) {
        await _screenCaptureService.enableProtection();
      }
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
    // Get current route to determine protection strategy
    String? currentRoute = _screenCaptureService.getCurrentRoute();
    bool fromProtected = currentRoute != null &&
        _screenCaptureService.isProtectionEnabledForRoute(currentRoute);
    bool toProtected =
        _screenCaptureService.isProtectionEnabledForRoute(routeName);

    // CRITICAL SECURITY: If transitioning from protected to unprotected,
    // show black screen during transition to prevent content exposure
    bool needsProtectionShield = fromProtected && !toProtected;

    // Monitor animation status
    animation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          // Transition starting - ensure protection is active
          if (needsProtectionShield || fromProtected) {
            _screenCaptureService.enableProtectionSynchronous();
          }
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

    Widget transitionChild = SlideTransition(
      position: slideTween.animate(curvedAnimation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );

    // SECURITY SHIELD: If transitioning from protected content to unprotected,
    // overlay a black screen during the transition to prevent any content exposure
    if (needsProtectionShield) {
      return Stack(
        children: [
          transitionChild,
          // Black overlay that fades out as we approach the unprotected destination
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              // Keep black screen for first 80% of animation, then fade out
              double opacity =
                  animation.value < 0.8 ? 1.0 : (1.0 - animation.value) * 5;
              opacity = opacity.clamp(0.0, 1.0);

              return opacity > 0
                  ? Container(
                      color: Colors.black.withOpacity(opacity),
                      child: Center(
                        child: opacity > 0.5
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.security,
                                      color: Colors.white, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Protected Content Transition',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
      );
    }

    return transitionChild;
  }

  // Get currently active transitions
  Set<String> getActiveTransitions() => Set.from(_activeTransitions);

  // Check if any transition is currently active
  bool get hasActiveTransitions => _activeTransitions.isNotEmpty;
}
