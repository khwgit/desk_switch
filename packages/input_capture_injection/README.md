# input_capture_injection

A Flutter plugin for capturing and injecting keyboard and mouse events on desktop platforms.

## Features

- **Input Capture**: Capture global keyboard and mouse events
- **Input Injection**: Inject keyboard and mouse events
- **Permission Management**: Handle accessibility permissions automatically
- **Event Streaming**: Real-time event streams for keyboard and mouse events

## Supported Platforms

- macOS (requires Accessibility permissions)
- Windows (planned)
- Linux (planned)

## Installation

Add this plugin to your `pubspec.yaml`:

```yaml
dependencies:
  input_capture_injection:
    path: packages/input_capture_injection
```

## Usage

### Basic Setup

```dart
import 'package:input_capture_injection/input_capture_injection.dart';
import 'package:input_capture_injection/models/key_event.dart';
import 'package:input_capture_injection/models/mouse_event.dart';

final plugin = InputCaptureInjection();

// Initialize the plugin
await plugin.initialize();
```

### Requesting Permissions

```dart
// Request input capture permissions
bool captureGranted = await plugin.requestInputCapture();
if (!captureGranted) {
  // User needs to enable Accessibility permissions in System Preferences
  print('Please enable Accessibility permissions');
}

// Request input injection permissions
bool injectionGranted = await plugin.requestInputInjection();
if (!injectionGranted) {
  // User needs to enable Accessibility permissions in System Preferences
  print('Please enable Accessibility permissions');
}
```

### Checking Permissions

```dart
// Check if input capture permissions are granted
bool captureRequested = await plugin.isInputCaptureRequested();

// Check if input injection permissions are granted
bool injectionRequested = await plugin.isInputInjectionRequested();
```

### Listening to Events

```dart
// Listen to keyboard events
plugin.keyInputs().listen((KeyEvent event) {
  print('Key: ${event.code}, Type: ${event.type}, Modifiers: ${event.modifiers}');
});

// Listen to mouse events
plugin.mouseInputs().listen((MouseEvent event) {
  print('Mouse: ${event.type} at (${event.x}, ${event.y})');
});
```

### Injecting Events

```dart
// Inject a keyboard event
await plugin.injectKeyInput(KeyEvent(
  code: 0x00, // Key code for 'A'
  type: KeyEventType.keyDown,
  modifiers: [KeyModifier.shift],
  character: 'A',
  timestamp: DateTime.now().millisecondsSinceEpoch,
));

// Inject a mouse event
await plugin.injectMouseInput(MouseEvent(
  x: 100.0,
  y: 200.0,
  type: MouseEventType.leftMouseDown,
  button: MouseButton.left,
  clickCount: 1,
  deltaX: 0.0,
  deltaY: 0.0,
  deltaZ: 0.0,
  timestamp: DateTime.now().millisecondsSinceEpoch,
));
```

## Data Models

### KeyEvent

```dart
@freezed
class KeyEvent with _$KeyEvent {
  const factory KeyEvent({
    required int code,
    required KeyEventType type,
    required List<KeyModifier> modifiers,
    required String? character,
    required int timestamp,
  }) = _KeyEvent;
}
```

### MouseEvent

```dart
@freezed
class MouseEvent with _$MouseEvent {
  const factory MouseEvent({
    required double x,
    required double y,
    required MouseEventType type,
    required MouseButton button,
    required int clickCount,
    required double deltaX,
    required double deltaY,
    required double deltaZ,
    required int timestamp,
  }) = _MouseEvent;
}
```

## Permissions

### macOS

This plugin requires Accessibility permissions to capture and inject input events. When you call `requestInputCapture()` or `requestInputInjection()`, the plugin will:

1. Check if Accessibility permissions are granted
2. If not granted, open System Preferences to the Accessibility section
3. Return `false` until permissions are manually enabled by the user

To enable permissions:
1. Go to System Preferences > Security & Privacy > Privacy > Accessibility
2. Add your application to the list
3. Check the checkbox next to your application

## API Reference

### Methods

- `initialize()` - Initialize the plugin
- `requestInputCapture()` - Request input capture permissions
- `isInputCaptureRequested()` - Check if input capture permissions are granted
- `requestInputInjection()` - Request input injection permissions
- `isInputInjectionRequested()` - Check if input injection permissions are granted
- `injectKeyInput(KeyEvent event)` - Inject a keyboard event
- `injectMouseInput(MouseEvent event)` - Inject a mouse event

### Streams

- `keyInputs()` - Stream of captured keyboard events
- `mouseInputs()` - Stream of captured mouse events

## License

This project is licensed under the MIT License.

