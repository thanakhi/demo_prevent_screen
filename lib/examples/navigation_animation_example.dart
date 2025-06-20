import 'package:flutter/material.dart';

void main() {
  runApp(NavigationAnimationExample());
}

class NavigationAnimationExample extends StatefulWidget {
  @override
  _NavigationAnimationExampleState createState() => _NavigationAnimationExampleState();
}

class _NavigationAnimationExampleState extends State<NavigationAnimationExample> {
  List<String> _logs = [];
  
  void _addLog(String message) {
    // Defer setState to avoid calling it during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _logs.insert(0, '${DateTime.now().millisecondsSinceEpoch % 100000}ms: $message');
          if (_logs.length > 30) _logs.removeLast();
        });
      }
    });
    print(message);
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Animation Demo',
      navigatorObservers: [
        AnimationTrackingObserver(_addLog),
      ],
      home: HomePage(_addLog, _logs),
      routes: {
        '/page1': (context) => AnimatedPage('Page 1', Colors.red, _addLog),
        '/page2': (context) => AnimatedPage('Page 2', Colors.blue, _addLog),
        '/page3': (context) => AnimatedPage('Page 3', Colors.green, _addLog),
      },
    );
  }
}

// 🔍 Custom Navigator Observer to track ALL navigation events
class AnimationTrackingObserver extends NavigatorObserver {
  final Function(String) onLog;
  
  AnimationTrackingObserver(this.onLog);
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onLog('🚀 PUSH: ${previousRoute?.settings.name ?? 'HOME'} → ${route.settings.name}');
    
    _trackRouteAnimation(route, 'PUSH');
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onLog('⬅️ POP: ${route.settings.name} → ${previousRoute?.settings.name ?? 'HOME'}');
    
    if (previousRoute != null) {
      _trackRouteAnimation(previousRoute, 'POP_RETURN');
    }
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onLog('🔄 REPLACE: ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
  }
  
  void _trackRouteAnimation(Route<dynamic> route, String type) {
    // Cast to ModalRoute to access animation properties
    if (route is ModalRoute && route.animation != null) {
      // 📊 Track animation STATUS changes (dismissed, forward, reverse, completed)
      route.animation!.addStatusListener((status) {
        onLog('📊 $type Status: ${_getStatusName(status)} (${route.settings.name})');
      });
      
      // 📈 Track animation VALUE changes (0.0 to 1.0)
      route.animation!.addListener(() {
        double value = route.animation!.value;
        onLog('📈 $type Value: ${value.toStringAsFixed(3)} (${route.settings.name})');
      });
    }
    
    // 📉 Track SECONDARY animation (for the route being covered/uncovered)
    if (route is ModalRoute && route.secondaryAnimation != null) {
      route.secondaryAnimation!.addStatusListener((status) {
        onLog('📊 $type Secondary Status: ${_getStatusName(status)} (${route.settings.name})');
      });
      
      route.secondaryAnimation!.addListener(() {
        double value = route.secondaryAnimation!.value;
        onLog('📉 $type Secondary Value: ${value.toStringAsFixed(3)} (${route.settings.name})');
      });
    }
  }
  
  String _getStatusName(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed: return 'DISMISSED (0.0)';
      case AnimationStatus.forward: return 'FORWARD (0.0→1.0)';
      case AnimationStatus.reverse: return 'REVERSE (1.0→0.0)';
      case AnimationStatus.completed: return 'COMPLETED (1.0)';
    }
  }
}

// 🏠 Home Page with navigation controls and real-time logs
class HomePage extends StatefulWidget {
  final Function(String) onLog;
  final List<String> logs;
  
  HomePage(this.onLog, this.logs);
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onLog('🏠 HomePage: didChangeDependencies');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Animation Demo'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // 🎮 Navigation Controls
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Text('🎯 Tap buttons to see navigation animations:', 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _navigateToPage('/page1'),
                      child: Text('Page 1'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateToPage('/page2'),
                      child: Text('Page 2'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateToPage('/page3'),
                      child: Text('Page 3'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _navigateWithCustomTransition('/page1'),
                      child: Text('Custom Slide'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    ),
                    ElevatedButton(
                      onPressed: _clearLogs,
                      child: Text('Clear Logs'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 📋 Real-time Animation Logs
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 Real-time Animation Logs:', 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Watch how animations progress from 0.0 to 1.0', 
                       style: TextStyle(color: Colors.grey[600])),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            widget.logs[index],
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: _getLogColor(widget.logs[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToPage(String routeName) {
    widget.onLog('🎯 Button pressed: Navigating to $routeName');
    Navigator.of(context).pushNamed(routeName);
  }
  
  void _navigateWithCustomTransition(String routeName) {
    widget.onLog('🎨 Custom transition to $routeName');
    Navigator.of(context).push(
      CustomSlideRoute(
        page: AnimatedPage('Custom Page', Colors.purple, widget.onLog),
        routeName: '/custom',
        onLog: widget.onLog,
      ),
    );
  }
  
  void _clearLogs() {
    setState(() {
      widget.logs.clear();
    });
  }
  
  Color _getLogColor(String log) {
    if (log.contains('PUSH') || log.contains('🚀')) return Colors.green;
    if (log.contains('POP') || log.contains('⬅️')) return Colors.red;
    if (log.contains('COMPLETED')) return Colors.orange;
    if (log.contains('Status')) return Colors.blue;
    if (log.contains('Value')) return Colors.purple;
    if (log.contains('Button pressed')) return Colors.teal;
    return Colors.black87;
  }
}

// 📱 Animated Page that shows its own animation state in real-time
class AnimatedPage extends StatefulWidget {
  final String title;
  final Color color;
  final Function(String) onLog;
  
  AnimatedPage(this.title, this.color, this.onLog);
  
  @override
  _AnimatedPageState createState() => _AnimatedPageState();
}

class _AnimatedPageState extends State<AnimatedPage> 
    with TickerProviderStateMixin, RouteAware {
  
  late AnimationController _localController;
  late Animation<double> _scaleAnimation;
  double _currentRouteAnimationValue = 0.0;
  String _currentAnimationStatus = 'Unknown';
  double _secondaryAnimationValue = 0.0;
  String _secondaryAnimationStatus = 'Unknown';
  
  @override
  void initState() {
    super.initState();
    widget.onLog('🎬 ${widget.title}: initState() called');
    
    // Create local animation controller for demonstration
    _localController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _localController,
      curve: Curves.elasticOut,
    ));
    
    _localController.forward();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onLog('🔄 ${widget.title}: didChangeDependencies() called');
    
    // 🎭 Track the route's PRIMARY animation (this route coming in)
    final route = ModalRoute.of(context);
    if (route?.animation != null) {
      route!.animation!.addListener(() {
        if (mounted) {
          setState(() {
            _currentRouteAnimationValue = route.animation!.value;
          });
        }
      });
      
      route.animation!.addStatusListener((status) {
        if (mounted) {
          setState(() {
            _currentAnimationStatus = _getStatusName(status);
          });
          widget.onLog('🎭 ${widget.title}: Route animation $status');
        }
      });
    }
    
    // 🎭 Track the route's SECONDARY animation (previous route being covered)
    if (route?.secondaryAnimation != null) {
      route!.secondaryAnimation!.addListener(() {
        if (mounted) {
          setState(() {
            _secondaryAnimationValue = route.secondaryAnimation!.value;
          });
        }
      });
      
      route.secondaryAnimation!.addStatusListener((status) {
        if (mounted) {
          setState(() {
            _secondaryAnimationStatus = _getStatusName(status);
          });
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onLog('🔙 ${widget.title}: Back button pressed');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.color.withOpacity(0.1),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    
                    // 📊 Real-time Animation Status Display
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: widget.color, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: widget.color,
                            ),
                          ),
                          SizedBox(height: 20),
                          
                          // Route Animation Info
                          _buildAnimationInfo(
                            '🎭 Route Animation (This Page)',
                            _currentAnimationStatus,
                            _currentRouteAnimationValue,
                            Colors.blue,
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Secondary Animation Info
                          _buildAnimationInfo(
                            '🎭 Secondary Animation (Previous Page)',
                            _secondaryAnimationStatus,
                            _secondaryAnimationValue,
                            Colors.orange,
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Local Animation Info
                          _buildAnimationInfo(
                            '🎨 Local Animation (Scale Effect)',
                            _localController.status.toString().split('.').last.toUpperCase(),
                            _scaleAnimation.value,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),
                    
                    // 🎮 Navigation Buttons
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Navigate to other pages:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ElevatedButton(
                                onPressed: () => _navigateToOtherPage('/page1'),
                                child: Text('→ Page 1'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                              ElevatedButton(
                                onPressed: () => _navigateToOtherPage('/page2'),
                                child: Text('→ Page 2'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                              ElevatedButton(
                                onPressed: () => _navigateToOtherPage('/page3'),
                                child: Text('→ Page 3'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              widget.onLog('🏠 ${widget.title}: Going back to home');
                              Navigator.of(context).pop();
                            },
                            child: Text('← Back to Home'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAnimationInfo(String title, String status, double value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(status, style: TextStyle(color: color)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Value:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(value.toStringAsFixed(3), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          // Visual progress bar
          SizedBox(height: 5),
          LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
  
  void _navigateToOtherPage(String routeName) {
    if (ModalRoute.of(context)?.settings.name == routeName) {
      widget.onLog('⚠️ ${widget.title}: Already on $routeName');
      return;
    }
    
    widget.onLog('🎯 ${widget.title}: Navigating to $routeName');
    Navigator.of(context).pushNamed(routeName);
  }
  
  String _getStatusName(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed: return 'DISMISSED (0.0)';
      case AnimationStatus.forward: return 'FORWARD (0.0→1.0)';
      case AnimationStatus.reverse: return 'REVERSE (1.0→0.0)';
      case AnimationStatus.completed: return 'COMPLETED (1.0)';
    }
  }
  
  @override
  void dispose() {
    widget.onLog('🗑️ ${widget.title}: dispose() called');
    _localController.dispose();
    super.dispose();
  }
}

// 🎨 Custom Page Route to demonstrate custom transitions
class CustomSlideRoute extends PageRouteBuilder {
  final Widget page;
  final String routeName;
  final Function(String) onLog;
  
  CustomSlideRoute({
    required this.page,
    required this.routeName,
    required this.onLog,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    settings: RouteSettings(name: routeName),
    transitionDuration: Duration(milliseconds: 1000), // Longer to see animation clearly
  );
  
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    
    // Log animation progress
    animation.addListener(() {
      onLog('🎨 Custom transition value: ${animation.value.toStringAsFixed(3)}');
    });
    
    animation.addStatusListener((status) {
      onLog('🎨 Custom transition status: $status');
    });
    
    // Custom slide transition from right to left
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
}
