import 'package:flutter_test/flutter_test.dart';
import '../lib/services/screen_capture_service.dart';

void main() {
  group('Screen Capture Service Debug Tests', () {
    test('Direct method calls work correctly', () {
      final service = ScreenCaptureService();

      // Test direct method calls
      print('Initial state: isTransitioning=${service.isTransitioning}');

      service.onNavigationStart('/', '/test');
      print(
          'After onNavigationStart: isTransitioning=${service.isTransitioning}');

      expect(service.isTransitioning, true);
      expect(service.getCurrentRoute(), '/test');

      service.onNavigationComplete('/test');
      print(
          'After onNavigationComplete: isTransitioning=${service.isTransitioning}');

      expect(service.isTransitioning, false);
      expect(service.getCurrentRoute(), '/test');
    });

    test('Route push sequence works correctly', () {
      final service = ScreenCaptureService();

      // Simulate route push sequence
      print('Initial state: isTransitioning=${service.isTransitioning}');

      // First, we need to set an initial route
      service.onNavigationComplete('/');
      print(
          'After setting initial route: currentRoute=${service.getCurrentRoute()}');

      // Now push a new route
      service.onNavigationStart('/', '/test');
      print(
          'After onNavigationStart: isTransitioning=${service.isTransitioning}');

      expect(service.isTransitioning, true);

      service.onNavigationComplete('/test');
      print(
          'After onNavigationComplete: isTransitioning=${service.isTransitioning}');

      expect(service.isTransitioning, false);
      expect(service.getCurrentRoute(), '/test');
    });
  });
}
