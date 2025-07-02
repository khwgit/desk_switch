import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'input_capture_injection_platform_interface.dart';
import 'models/input.dart';

/// An implementation of [InputCaptureInjectionPlatform] that uses method channels.
class MethodChannelInputCaptureInjection extends InputCaptureInjectionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('input_capture_injection');

  static const EventChannel _keyboardEventChannel = EventChannel(
    'input_capture_injection/keyboardInputs',
  );
  static const EventChannel _mouseEventChannel = EventChannel(
    'input_capture_injection/mouseInputs',
  );

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod('initialize');
  }

  @override
  Future<bool> requestInputCapture() async {
    final result = await methodChannel.invokeMethod<bool>(
      'requestInputCapture',
    );
    return result ?? false;
  }

  @override
  Future<bool> isInputCaptureRequested() async {
    final result = await methodChannel.invokeMethod<bool>(
      'isInputCaptureRequested',
    );
    return result ?? false;
  }

  @override
  Stream<KeyboardInput> keyboardInputs() {
    return _keyboardEventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        final map = Map<String, dynamic>.from(event);
        return KeyboardInput.fromJson(map);
      }
      throw ArgumentError('Invalid keyboard event format');
    });
  }

  @override
  Stream<MouseInput> mouseInputs() {
    return _mouseEventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        final map = Map<String, dynamic>.from(event);
        return MouseInput.fromJson(map);
      }
      throw ArgumentError('Invalid mouse event format');
    });
  }

  @override
  Stream<Input> inputs() async* {
    yield* keyboardInputs();
    yield* mouseInputs();
  }

  @override
  Future<bool> requestInputInjection() async {
    final result = await methodChannel.invokeMethod<bool>(
      'requestInputInjection',
    );
    return result ?? false;
  }

  @override
  Future<bool> isInputInjectionRequested() async {
    final result = await methodChannel.invokeMethod<bool>(
      'isInputInjectionRequested',
    );
    return result ?? false;
  }

  @override
  Future<void> injectMouseInput(MouseInput input) async {
    await methodChannel.invokeMethod('injectMouseInput', input.toJson());
  }

  @override
  Future<void> injectKeyboardInput(KeyboardInput input) async {
    await methodChannel.invokeMethod('injectKeyboardInput', input.toJson());
  }
}
