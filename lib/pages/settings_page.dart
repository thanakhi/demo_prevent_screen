import 'package:flutter/material.dart';
import '../services/screen_capture_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  @override
  Widget build(BuildContext context) {
    final routeSettings = _screenCaptureService.getAllRouteSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Protection Settings'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Icon(
              Icons.settings_applications,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Screen Capture Protection',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Control screen capture protection for each page',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Protection Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _screenCaptureService.isProtected
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _screenCaptureService.isProtected
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _screenCaptureService.isProtected
                                ? Icons.shield
                                : Icons.shield_outlined,
                            color: _screenCaptureService.isProtected
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _screenCaptureService.isProtected
                                ? 'Currently Protected'
                                : 'Currently Unprotected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _screenCaptureService.isProtected
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.route,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Route Protection Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...routeSettings.entries.map((entry) {
                      String routeName = entry.key;
                      bool isProtected = entry.value;
                      String displayName = _getRouteDisplayName(routeName);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isProtected
                            ? Colors.red.shade50
                            : Colors.grey.shade50,
                        child: SwitchListTile(
                          title: Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Route: $routeName',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          secondary: Icon(
                            isProtected ? Icons.lock : Icons.lock_open,
                            color: isProtected ? Colors.red : Colors.grey,
                          ),
                          value: isProtected,
                          activeColor: Colors.red,
                          onChanged: (bool value) {
                            setState(() {
                              if (value) {
                                _screenCaptureService
                                    .enableProtectionForRoute(routeName);
                              } else {
                                _screenCaptureService
                                    .disableProtectionForRoute(routeName);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Enable protection for routes with sensitive content\n'
                      '• When you navigate to a protected route, screen capture will be blocked\n'
                      '• Protection is automatically disabled when leaving protected routes\n'
                      '• Each route can be individually configured',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRouteDisplayName(String routeName) {
    switch (routeName) {
      case '/':
        return 'Home Page';
      case '/page1':
        return 'Secure Page 1';
      case '/page2':
        return 'Secure Page 2';
      case '/page3':
        return 'Advanced Page 3';
      default:
        return routeName;
    }
  }
}
