import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';
import '../services/navigation_protection_manager.dart';
import '../widgets/screen_protector_wrapper.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  @override
  Widget build(BuildContext context) {
    return ScreenProtectorWrapper(
      routeName: '/page3',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Page 3'),
          centerTitle: true,
          backgroundColor: Colors.purple.shade100,
          actions: [
            IconButton(
              icon: Icon(
                _screenCaptureService.isProtectionEnabledForRoute('/page3')
                    ? Icons.security
                    : Icons.security_update_warning,
              ),
              onPressed: () {
                setState(() {
                  _screenCaptureService.toggleProtectionForRoute('/page3');
                  _screenCaptureService.applyProtectionForRoute('/page3');
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
                Icons.shield,
                size: 100,
                color:
                    _screenCaptureService.isProtectionEnabledForRoute('/page3')
                        ? Colors.purple
                        : Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'Page 3 - Advanced Security',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Screen Capture Protection Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _screenCaptureService
                                  .isProtectionEnabledForRoute('/page3')
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _screenCaptureService
                                  .isProtectionEnabledForRoute('/page3')
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _screenCaptureService
                                  .isProtectionEnabledForRoute('/page3')
                              ? 'PROTECTED'
                              : 'NOT PROTECTED',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _screenCaptureService
                                    .isProtectionEnabledForRoute('/page3')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'This is Page 3 with advanced security features. You can toggle screen capture protection and navigate to other pages.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Current Protection: ${_screenCaptureService.isProtectionEnabledForRoute('/page3') ? 'ON' : 'OFF'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _screenCaptureService
                            .toggleProtectionForRoute('/page3');
                        _screenCaptureService.applyProtectionForRoute('/page3');
                      });
                    },
                    icon: Icon(_screenCaptureService
                            .isProtectionEnabledForRoute('/page3')
                        ? Icons.security_update_warning
                        : Icons.security),
                    label: Text(_screenCaptureService
                            .isProtectionEnabledForRoute('/page3')
                        ? 'Disable'
                        : 'Enable'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _screenCaptureService
                              .isProtectionEnabledForRoute('/page3')
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      foregroundColor: _screenCaptureService
                              .isProtectionEnabledForRoute('/page3')
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      NavigationProtectionManager.popWithProtection(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple.shade700,
                  side: BorderSide(color: Colors.purple.shade300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
