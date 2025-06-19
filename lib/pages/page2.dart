import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';
import '../services/navigation_protection_manager.dart';
import '../widgets/screen_protector_wrapper.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  @override
  Widget build(BuildContext context) {
    return ScreenProtectorWrapper(
      routeName: '/page2',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Secure Page 2'),
          centerTitle: true,
          backgroundColor: Colors.purple.shade100,
          actions: [
            IconButton(
              icon: Icon(
                _screenCaptureService.isProtectionEnabledForRoute('/page2')
                    ? Icons.security
                    : Icons.security_update_warning,
              ),
              onPressed: () {
                setState(() {
                  _screenCaptureService.toggleProtectionForRoute('/page2');
                  _screenCaptureService.applyProtectionForRoute('/page2');
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
                Icons.privacy_tip,
                size: 100,
                color:
                    _screenCaptureService.isProtectionEnabledForRoute('/page2')
                        ? Colors.purple
                        : Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'Page 2 - Private Data',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🔒 Private Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This page contains private user data and financial information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Sample Sensitive Data:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Account: **** **** **** 1234'),
                          const Text('Balance: \$10,000.00'),
                          const Text('SSN: ***-**-5678'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _screenCaptureService
                                  .isProtectionEnabledForRoute('/page2')
                              ? Icons.verified_user
                              : Icons.verified_user_outlined,
                          color: _screenCaptureService
                                  .isProtectionEnabledForRoute('/page2')
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _screenCaptureService
                                  .isProtectionEnabledForRoute('/page2')
                              ? 'Secure Mode'
                              : 'Insecure Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _screenCaptureService
                                    .isProtectionEnabledForRoute('/page2')
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
                    _screenCaptureService.toggleProtectionForRoute('/page2');
                    _screenCaptureService.applyProtectionForRoute('/page2');
                  });
                },
                icon: Icon(
                  _screenCaptureService.isProtectionEnabledForRoute('/page2')
                      ? Icons.lock_open
                      : Icons.lock,
                ),
                label: Text(
                  _screenCaptureService.isProtectionEnabledForRoute('/page2')
                      ? 'Disable Protection'
                      : 'Enable Protection',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _screenCaptureService
                          .isProtectionEnabledForRoute('/page2')
                      ? Colors.orange
                      : Colors.purple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Use protected navigation for back navigation
                  NavigationProtectionManager.popWithProtection(context);
                },
                child: const Text('Back to Page 1'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
