import 'package:flutter/material.dart';

/// 📚 Step-by-Step Navigation Tutorial
/// 
/// This example breaks down navigation concepts into clear, understandable steps:
/// 1. What is Push/Pop?
/// 2. How do animations work? 
/// 3. What are animation states?
/// 4. What are animation values?
/// 5. Primary vs Secondary animations
void main() {
  runApp(StepByStepNavigationTutorial());
}

class StepByStepNavigationTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Tutorial',
      home: TutorialHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class TutorialHomePage extends StatefulWidget {
  @override
  _TutorialHomePageState createState() => _TutorialHomePageState();
}

class _TutorialHomePageState extends State<TutorialHomePage> {
  String _currentStep = "Ready to start";
  List<String> _events = [];

  void _addEvent(String event) {
    // Defer setState to avoid calling it during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _events.insert(0, "${DateTime.now().millisecondsSinceEpoch % 10000}: $event");
          if (_events.length > 15) _events.removeLast();
        });
      }
    });
  }

  void _setStep(String step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentStep = step;
        });
      }
    });
    _addEvent("📋 $step");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📚 Navigation Tutorial'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Current Step Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Text('Current Step:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text(_currentStep, 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
              ],
            ),
          ),
          
          // Tutorial Steps
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      "1️⃣ What is PUSH?",
                      "Push adds a new page ON TOP of the current page stack.",
                      [
                        "• Like adding a card to a deck",
                        "• Animation: New page slides in (0.0 → 1.0)",
                        "• Old page stays underneath",
                      ],
                      () => _demonstratePush(),
                      Colors.green,
                    ),
                    
                    _buildSection(
                      "2️⃣ What is POP?",
                      "Pop removes the top page FROM the stack, revealing the page underneath.",
                      [
                        "• Like removing the top card from a deck",
                        "• Animation: Current page slides out (1.0 → 0.0)",
                        "• Previous page becomes visible again",
                      ],
                      () => _demonstratePop(),
                      Colors.red,
                    ),
                    
                    _buildSection(
                      "3️⃣ Animation States",
                      "Animations go through 4 states during their lifecycle:",
                      [
                        "• DISMISSED: Animation at start (value = 0.0)",
                        "• FORWARD: Animation running forward (0.0 → 1.0)",
                        "• COMPLETED: Animation at end (value = 1.0)",
                        "• REVERSE: Animation running backward (1.0 → 0.0)",
                      ],
                      () => _demonstrateAnimationStates(),
                      Colors.orange,
                    ),
                    
                    _buildSection(
                      "4️⃣ Animation Values",
                      "Animation values show the progress from 0.0 to 1.0:",
                      [
                        "• 0.0 = Start position (page off-screen)",
                        "• 0.25 = 25% of the way",
                        "• 0.5 = Halfway point",
                        "• 0.75 = 75% complete",
                        "• 1.0 = End position (page fully visible)",
                      ],
                      () => _demonstrateAnimationValues(),
                      Colors.purple,
                    ),
                    
                    _buildSection(
                      "5️⃣ Primary vs Secondary",
                      "Each navigation has TWO animations running simultaneously:",
                      [
                        "• PRIMARY: The new page coming in",
                        "• SECONDARY: The old page being covered",
                        "• Both have their own states and values",
                        "• This creates smooth transitions",
                      ],
                      () => _demonstratePrimarySecondary(),
                      Colors.teal,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Event Log
          Container(
            height: 200,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📋 Event Log:', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _events[index],
                        style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _events.clear()),
                  child: Text('Clear Log'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, List<String> points, 
                      VoidCallback onDemo, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                ...points.map((point) => Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(point, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                )),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onDemo,
                  child: Text('Try This Demo'),
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _demonstratePush() {
    _setStep("Demonstrating PUSH - Adding new page to stack");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DemoPage(
          title: "PUSH Demo",
          explanation: "This page was PUSHED onto the navigation stack.\n\n"
                      "• The push animation ran from 0.0 → 1.0\n"
                      "• This page slid in from the right\n"
                      "• The home page is still underneath\n"
                      "• Press back to POP this page off the stack",
          color: Colors.green,
          onEvent: _addEvent,
        ),
      ),
    ).then((_) {
      _setStep("PUSH demo completed - Page was popped back");
    });
  }

  void _demonstratePop() {
    _setStep("To see POP, we first need to push a page");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DemoPage(
          title: "POP Demo",
          explanation: "Now press the back button to see POP in action:\n\n"
                      "• This page will animate out (1.0 → 0.0)\n"
                      "• The home page will be revealed underneath\n"
                      "• The pop animation slides this page away\n"
                      "• This is the REVERSE of the push animation",
          color: Colors.red,
          onEvent: _addEvent,
          showPopButton: true,
        ),
      ),
    ).then((_) {
      _setStep("POP demo completed - Page was removed from stack");
    });
  }

  void _demonstrateAnimationStates() {
    _setStep("Opening Animation States demo");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnimationStatesDemo(onEvent: _addEvent),
      ),
    ).then((_) {
      _setStep("Animation States demo completed");
    });
  }

  void _demonstrateAnimationValues() {
    _setStep("Opening Animation Values demo");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnimationValuesDemo(onEvent: _addEvent),
      ),
    ).then((_) {
      _setStep("Animation Values demo completed");
    });
  }

  void _demonstratePrimarySecondary() {
    _setStep("Opening Primary vs Secondary demo");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrimarySecondaryDemo(onEvent: _addEvent),
      ),
    ).then((_) {
      _setStep("Primary vs Secondary demo completed");
    });
  }
}

class DemoPage extends StatelessWidget {
  final String title;
  final String explanation;
  final Color color;
  final Function(String) onEvent;
  final bool showPopButton;

  const DemoPage({
    Key? key,
    required this.title,
    required this.explanation,
    required this.color,
    required this.onEvent,
    this.showPopButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color),
              ),
              child: Text(
                explanation,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            if (showPopButton) ...[
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    onEvent("🔙 Manually triggering POP");
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text('POP This Page'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AnimationStatesDemo extends StatefulWidget {
  final Function(String) onEvent;

  const AnimationStatesDemo({Key? key, required this.onEvent}) : super(key: key);

  @override
  _AnimationStatesDemoState createState() => _AnimationStatesDemoState();
}

class _AnimationStatesDemoState extends State<AnimationStatesDemo> 
    with TickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;
  String _currentState = "DISMISSED";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    
    _controller.addStatusListener((status) {
      setState(() {
        switch (status) {
          case AnimationStatus.dismissed:
            _currentState = "DISMISSED (0.0)";
            break;
          case AnimationStatus.forward:
            _currentState = "FORWARD (0.0→1.0)";
            break;
          case AnimationStatus.completed:
            _currentState = "COMPLETED (1.0)";
            break;
          case AnimationStatus.reverse:
            _currentState = "REVERSE (1.0→0.0)";
            break;
        }
      });
      widget.onEvent("🎭 Animation state: $status");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animation States Demo'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Watch the animation state change as you control the animation:',
                 style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  Text('Current State:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_currentState, style: TextStyle(fontSize: 24, color: Colors.orange)),
                  SizedBox(height: 20),
                  
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          Text('Animation Value: ${_animation.value.toStringAsFixed(3)}'),
                          SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: _animation.value,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(_animation.value),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _animation.value.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onEvent("▶️ Starting FORWARD animation");
                    _controller.forward();
                  },
                  child: Text('Forward'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onEvent("⏸️ Stopping animation");
                    _controller.stop();
                  },
                  child: Text('Stop'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onEvent("◀️ Starting REVERSE animation");
                    _controller.reverse();
                  },
                  child: Text('Reverse'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onEvent("🔄 Resetting animation to DISMISSED");
                _controller.reset();
              },
              child: Text('Reset to DISMISSED'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimationValuesDemo extends StatefulWidget {
  final Function(String) onEvent;

  const AnimationValuesDemo({Key? key, required this.onEvent}) : super(key: key);

  @override
  _AnimationValuesDemoState createState() => _AnimationValuesDemoState();
}

class _AnimationValuesDemoState extends State<AnimationValuesDemo> 
    with TickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
    
    _animation.addListener(() {
      setState(() {
        _currentValue = _animation.value;
      });
      // Only log every 10th frame to avoid spam
      if ((_currentValue * 100).round() % 5 == 0) {
        widget.onEvent("📈 Animation value: ${_currentValue.toStringAsFixed(3)}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animation Values Demo'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Watch how animation values change from 0.0 to 1.0:',
                 style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple),
              ),
              child: Column(
                children: [
                  Text('Current Value: $_currentValue', 
                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple)),
                  SizedBox(height: 20),
                  
                  // Visual representation of the value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0.0', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(
                            value: _currentValue,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      Text('1.0', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Visual element that changes with animation
                  Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        // Background
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Animated fill
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 200 * _currentValue,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Value text
                        Center(
                          child: Text(
                            '${(_currentValue * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _currentValue > 0.5 ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Value milestones
                  Text('Key Milestones:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildMilestone(0.0, 'Start', _currentValue >= 0.0),
                  _buildMilestone(0.25, 'Quarter', _currentValue >= 0.25),
                  _buildMilestone(0.5, 'Half', _currentValue >= 0.5),
                  _buildMilestone(0.75, 'Three-quarters', _currentValue >= 0.75),
                  _buildMilestone(1.0, 'Complete', _currentValue >= 1.0),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onEvent("🎬 Starting smooth animation 0.0→1.0");
                    _controller.forward(from: 0.0);
                  },
                  child: Text('Animate'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onEvent("🔄 Resetting to 0.0");
                    _controller.reset();
                  },
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(double value, String label, bool reached) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            reached ? Icons.check_circle : Icons.radio_button_unchecked,
            color: reached ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Text('$value - $label', 
               style: TextStyle(
                 color: reached ? Colors.green : Colors.grey,
                 fontWeight: reached ? FontWeight.bold : FontWeight.normal,
               )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PrimarySecondaryDemo extends StatefulWidget {
  final Function(String) onEvent;

  const PrimarySecondaryDemo({Key? key, required this.onEvent}) : super(key: key);

  @override
  _PrimarySecondaryDemoState createState() => _PrimarySecondaryDemoState();
}

class _PrimarySecondaryDemoState extends State<PrimarySecondaryDemo> {
  double _primaryValue = 0.0;
  double _secondaryValue = 0.0;
  String _primaryStatus = "Unknown";
  String _secondaryStatus = "Unknown";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final route = ModalRoute.of(context);
    
    // Track PRIMARY animation (this page coming in)
    if (route?.animation != null) {
      route!.animation!.addListener(() {
        if (mounted) {
          setState(() {
            _primaryValue = route.animation!.value;
          });
        }
      });
      
      route.animation!.addStatusListener((status) {
        if (mounted) {
          setState(() {
            _primaryStatus = _getStatusName(status);
          });
          widget.onEvent("🔵 PRIMARY: $status");
        }
      });
    }
    
    // Track SECONDARY animation (previous page being covered)
    if (route?.secondaryAnimation != null) {
      route!.secondaryAnimation!.addListener(() {
        if (mounted) {
          setState(() {
            _secondaryValue = route.secondaryAnimation!.value;
          });
        }
      });
      
      route.secondaryAnimation!.addStatusListener((status) {
        if (mounted) {
          setState(() {
            _secondaryStatus = _getStatusName(status);
          });
          widget.onEvent("🟠 SECONDARY: $status");
        }
      });
    }
  }

  String _getStatusName(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed: return 'DISMISSED';
      case AnimationStatus.forward: return 'FORWARD';
      case AnimationStatus.reverse: return 'REVERSE';
      case AnimationStatus.completed: return 'COMPLETED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primary vs Secondary'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This page shows TWO animations running simultaneously:',
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            
            // Primary Animation
            _buildAnimationDisplay(
              'PRIMARY Animation',
              'This page sliding IN',
              _primaryStatus,
              _primaryValue,
              Colors.blue,
              Icons.arrow_forward,
            ),
            
            SizedBox(height: 20),
            
            // Secondary Animation  
            _buildAnimationDisplay(
              'SECONDARY Animation',
              'Previous page being COVERED',
              _secondaryStatus,
              _secondaryValue,
              Colors.orange,
              Icons.visibility_off,
            ),
            
            SizedBox(height: 30),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 Key Points:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• PRIMARY animation controls this page coming in'),
                  Text('• SECONDARY animation controls the home page being covered'),
                  Text('• Both animations run at the same time'),
                  Text('• When you press back, the roles reverse!'),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onEvent("🔄 Pushing another page to see the effect");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DemoPage(
                        title: "Another Page",
                        explanation: "Notice:\n• This page is now the PRIMARY animation\n"
                                   "• The previous page is now the SECONDARY animation\n"
                                   "• Press back to see the reverse effect",
                        color: Colors.indigo,
                        onEvent: widget.onEvent,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add),
                label: Text('Push Another Page'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationDisplay(String title, String description, String status, 
                               double value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status: $status', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Value: ${value.toStringAsFixed(3)}', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
