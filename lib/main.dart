import 'package:flutter/material.dart';
import 'services/screen_capture_service.dart';
import 'services/screen_protection_route_observer.dart';
import 'services/navigation_protection_manager.dart';
import 'widgets/screen_protector_wrapper.dart';
import 'pages/page1.dart';
import 'pages/page2.dart';
import 'pages/page3.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Create route observer instance
  static final ScreenProtectionRouteObserver routeObserver =
      ScreenProtectionRouteObserver();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Capture Prevention Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Screen Capture Demo'),
        '/page1': (context) => const Page1(),
        '/page2': (context) => const Page2(),
        '/page3': (context) => const Page3(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenProtectorWrapper(
      routeName: '/',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            IconButton(
              icon: Icon(
                _screenCaptureService.isProtectionEnabledForRoute('/')
                    ? Icons.security
                    : Icons.security_update_warning,
              ),
              onPressed: () {
                setState(() {
                  _screenCaptureService.toggleProtectionForRoute('/');
                  _screenCaptureService.applyProtectionForRoute('/');
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.phone_iphone,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Screen Capture Prevention Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: _screenCaptureService.isProtectionEnabledForRoute('/')
                      ? Colors.red.shade50
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        _screenCaptureService.isProtectionEnabledForRoute('/')
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _screenCaptureService.isProtectionEnabledForRoute('/')
                              ? Icons.shield
                              : Icons.shield_outlined,
                          color: _screenCaptureService
                                  .isProtectionEnabledForRoute('/')
                              ? Colors.red
                              : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _screenCaptureService.isProtectionEnabledForRoute('/')
                              ? 'Home Protected'
                              : 'Home Unprotected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _screenCaptureService
                                    .isProtectionEnabledForRoute('/')
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Counter Value:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$_counter',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: _screenCaptureService
                                        .isProtectionEnabledForRoute('/')
                                    ? Colors.red
                                    : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _screenCaptureService.toggleProtectionForRoute('/');
                    _screenCaptureService.applyProtectionForRoute('/');
                  });
                },
                icon: Icon(
                  _screenCaptureService.isProtectionEnabledForRoute('/')
                      ? Icons.lock_open
                      : Icons.lock,
                ),
                label: Text(
                  _screenCaptureService.isProtectionEnabledForRoute('/')
                      ? 'Disable Protection'
                      : 'Enable Protection',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _screenCaptureService.isProtectionEnabledForRoute('/')
                          ? Colors.orange
                          : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      NavigationProtectionManager.pushWithProtection(
                        context,
                        '/page1',
                        const Page1(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Secure Page 1'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      NavigationProtectionManager.pushWithProtection(
                        context,
                        '/page2',
                        const Page2(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Secure Page 2'),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          backgroundColor:
              _screenCaptureService.isProtectionEnabledForRoute('/')
                  ? Colors.red
                  : Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
