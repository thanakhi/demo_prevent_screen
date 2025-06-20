# Navigation Animation Example

This example demonstrates Flutter navigation push/pop operations with detailed animation tracking.

## 🎯 What You'll Learn

1. **Navigation Events**: Push, Pop, Replace operations
2. **Animation States**: dismissed, forward, reverse, completed
3. **Animation Values**: 0.0 to 1.0 progression
4. **Primary vs Secondary Animations**: Understanding both route animations
5. **Custom Transitions**: How to create custom page transitions

## 🚀 How to Run

### Option 1: Run the standalone example
```bash
flutter run lib/navigation_example_runner.dart
```

### Option 2: Integration with your main app
Add this to your main app's routes or navigate directly:
```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => NavigationAnimationExample()),
);
```

## 📊 What to Watch For

### Animation Status Lifecycle:
1. **DISMISSED (0.0)** - Animation at start position
2. **FORWARD (0.0→1.0)** - Animation running forward 
3. **COMPLETED (1.0)** - Animation at end position
4. **REVERSE (1.0→0.0)** - Animation running backward (for pop)

### Animation Values:
- **0.0** = Starting state (page fully off-screen)
- **0.5** = Halfway through animation
- **1.0** = Ending state (page fully on-screen)

### Primary vs Secondary Animations:
- **Primary**: The new page coming in
- **Secondary**: The previous page being covered/uncovered

## 🔍 Key Features

### Real-time Logs
- See every animation frame and status change
- Color-coded logs for different event types
- Millisecond timestamps for precise timing

### Interactive Testing
- Navigate between multiple pages
- Test custom transitions
- Observe pop animations when going back

### Visual Feedback
- Progress bars showing animation values
- Status displays for all animation types
- Local vs route animation comparison

## 🎨 Understanding the Output

When you press "Page 1", you'll see logs like:
```
🎯 Button pressed: Navigating to /page1
🚀 PUSH: HOME → /page1
📊 PUSH Status: FORWARD (0.0→1.0) (/page1)
📈 PUSH Value: 0.000 (/page1)
📈 PUSH Value: 0.127 (/page1)
📈 PUSH Value: 0.255 (/page1)
...
📈 PUSH Value: 1.000 (/page1)
📊 PUSH Status: COMPLETED (1.0) (/page1)
```

When you press Back:
```
🔙 Page 1: Back button pressed
⬅️ POP: /page1 → HOME
📊 POP_RETURN Status: FORWARD (0.0→1.0) (HOME)
📈 POP_RETURN Value: 0.000 (HOME)
...
📊 POP_RETURN Status: COMPLETED (1.0) (HOME)
```

## 🔧 Customization

You can modify the example to:
- Change animation durations
- Add different transition types
- Track additional animation properties
- Test with your own pages

## 💡 Tips for Your Security Implementation

This understanding helps with screen protection because:
- You know exactly when animations start (Status: FORWARD)
- You can track animation progress (Value: 0.0 → 1.0)
- You know when animations complete (Status: COMPLETED)
- You can apply protection before animation starts (Value: 0.0)
- You can delay protection removal until after animation completes (Status: COMPLETED + delay)
