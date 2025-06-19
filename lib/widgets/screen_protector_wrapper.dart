import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';

class ScreenProtectorWrapper extends StatefulWidget {
  final Widget child;
  final String routeName;

  const ScreenProtectorWrapper({
    super.key,
    required this.child,
    required this.routeName,
  });

  @override
  State<ScreenProtectorWrapper> createState() => _ScreenProtectorWrapperState();
}

class _ScreenProtectorWrapperState extends State<ScreenProtectorWrapper> 
    with RouteAware, TickerProviderStateMixin {
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller to track transition states
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to animation status changes
    _animationController.addStatusListener(_onAnimationStatusChanged);
    
    // Apply initial protection
    _applyProtection();
    
    // Start animation
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ScreenProtectorWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeName != widget.routeName) {
      _applyProtection();
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        // Animation starting - ensure protection during transition
        _screenCaptureService.ensureProtectionDuringTransition();
        break;
      case AnimationStatus.completed:
        // Animation completed - apply final protection state
        _applyProtection();
        break;
      case AnimationStatus.reverse:
        // Animation reversing (e.g., during pop) - maintain protection
        _screenCaptureService.ensureProtectionDuringTransition();
        break;
      case AnimationStatus.dismissed:
        // Animation dismissed - this happens when route is fully popped
        break;
    }
  }

  Future<void> _applyProtection() async {
    await _screenCaptureService.applyProtectionForRoute(widget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return widget.child;
      },
    );
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_onAnimationStatusChanged);
    _animationController.dispose();
    super.dispose();
  }
}
