import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';
import '../services/navigation_protection_manager.dart';
import '../widgets/screen_protector_wrapper.dart';
import 'page2.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  @override
  Widget build(BuildContext context) {
    return ScreenProtectorWrapper(
      routeName: '/page1',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Secure Page 1'),
          centerTitle: true,
          backgroundColor: Colors.red.shade100,
          actions: [
            IconButton(
              icon: Icon(
                _screenCaptureService.isProtectionEnabledForRoute('/page1')
                    ? Icons.security
                    : Icons.security_update_warning,
              ),
              onPressed: () {
                setState(() {
                  _screenCaptureService.toggleProtectionForRoute('/page1');
                  _screenCaptureService.applyProtectionForRoute('/page1');
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 100,
                color:
                    _screenCaptureService.isProtectionEnabledForRoute('/page1')
                        ? Colors.red
                        : Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'Page 1 - Sensitive Content',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🔐 Confidential Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This page contains sensitive data that should not be captured or shared.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _screenCaptureService
                                  .isProtectionEnabledForRoute('/page1')
                              ? Icons.shield
                              : Icons.shield_outlined,
                          color: _screenCaptureService
                                  .isProtectionEnabledForRoute('/page1')
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _screenCaptureService
                                  .isProtectionEnabledForRoute('/page1')
                              ? 'Protected'
                              : 'Unprotected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _screenCaptureService
                                    .isProtectionEnabledForRoute('/page1')
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _screenCaptureService.toggleProtectionForRoute('/page1');
                    _screenCaptureService.applyProtectionForRoute('/page1');
                  });
                },
                icon: Icon(
                  _screenCaptureService.isProtectionEnabledForRoute('/page1')
                      ? Icons.lock_open
                      : Icons.lock,
                ),
                label: Text(
                  _screenCaptureService.isProtectionEnabledForRoute('/page1')
                      ? 'Disable Protection'
                      : 'Enable Protection',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _screenCaptureService
                          .isProtectionEnabledForRoute('/page1')
                      ? Colors.orange
                      : Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // CRITICAL SECURITY FIX: Apply protection IMMEDIATELY before navigation
                  // This ensures zero gap between user action and protection
                  final screenService = ScreenCaptureService();

                  // Synchronously enable protection before any navigation starts
                  if (!screenService.isProtected) {
                    screenService.enableProtectionSynchronous();
                  }

                  // Small delay to ensure protection is fully active
                  await Future.delayed(Duration(milliseconds: 10));

                  // Now navigate with protection already active
                  NavigationProtectionManager.pushWithProtection(
                    context,
                    '/page2',
                    const Page2(),
                  );
                },
                child: const Text('Go to Page 2 (Protected)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
