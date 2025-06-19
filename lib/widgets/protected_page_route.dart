import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';

class ProtectedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String routeName;
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  ProtectedPageRoute({
    required this.child,
    required this.routeName,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Ensure protection during the entire transition
    animation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          // Starting transition - enable protection if needed
          _screenCaptureService.ensureProtectionDuringTransition();
          break;
        case AnimationStatus.completed:
          // Transition completed - apply final protection state
          _screenCaptureService.applyProtectionForRoute(routeName);
          break;
        case AnimationStatus.reverse:
        case AnimationStatus.dismissed:
          // Handle reverse transitions
          _screenCaptureService.ensureProtectionDuringTransition();
          break;
      }
    });

    // Use a slide transition with fade for smooth animation
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    final tween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

// Extension to make navigation easier
extension ProtectedNavigation on NavigatorState {
  Future<T?> pushProtected<T extends Object?>(
    String routeName,
    Widget page,
  ) {
    return push<T>(ProtectedPageRoute<T>(
      child: page,
      routeName: routeName,
      settings: RouteSettings(name: routeName),
    ));
  }
}
