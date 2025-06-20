import 'package:flutter/material.dart';
import 'examples/navigation_animation_example.dart';
import 'examples/step_by_step_navigation_tutorial.dart';

/// Navigation Learning Hub
/// 
/// Choose between two learning approaches:
/// 1. Step-by-Step Tutorial: Learn concepts one by one
/// 2. Advanced Example: See everything in action with detailed logs
void main() {
  runApp(NavigationLearningHub());
}

class NavigationLearningHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Learning Hub',
      home: LearningHubPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class LearningHubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎓 Navigation Learning Hub'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learn Flutter Navigation',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose your learning path:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              
              Expanded(
                child: Column(
                  children: [
                    // Option 1: Tutorial
                    _buildLearningOption(
                      context,
                      title: '📚 Step-by-Step Tutorial',
                      subtitle: 'Perfect for beginners',
                      description: 'Learn navigation concepts one step at a time:\n'
                                  '• What is Push/Pop?\n'
                                  '• Animation States & Values\n'
                                  '• Primary vs Secondary animations\n'
                                  '• Interactive demos for each concept',
                      color: Colors.green,
                      icon: Icons.school,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StepByStepNavigationTutorial(),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Option 2: Advanced Example
                    _buildLearningOption(
                      context,
                      title: '🔬 Advanced Animation Example',
                      subtitle: 'For detailed analysis',
                      description: 'See everything in action with real-time logs:\n'
                                  '• Live animation tracking\n'
                                  '• Custom transitions\n'
                                  '• Multiple page navigation\n'
                                  '• Detailed event logging',
                      color: Colors.purple,
                      icon: Icons.analytics,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NavigationAnimationExample(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Start with the tutorial if you\'re new to Flutter navigation, '
                        'then try the advanced example to see everything in detail.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color),
              ],
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
