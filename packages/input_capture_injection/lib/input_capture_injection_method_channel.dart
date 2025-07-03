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
  Future<bool> requestPermission([InputType? type]) async {
    final result = await methodChannel.invokeMethod<bool>('requestPermission', {
      'type': type?.name,
    });
    return result ?? false;
  }

  @override
  Future<bool> isPermissionGranted([InputType? type]) async {
    final result = await methodChannel.invokeMethod<bool>(
      'isPermissionGranted',
      {'type': type?.name},
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
  Future<void> injectMouseInput(MouseInput input) async {
    await methodChannel.invokeMethod('injectMouseInput', input.toJson());
  }

  @override
  Future<void> injectKeyboardInput(KeyboardInput input) async {
    await methodChannel.invokeMethod('injectKeyboardInput', input.toJson());
  }

  @override
  Future<void> injectInput(Input input) async {
    await switch (input) {
      MouseInput() => injectMouseInput(input),
      KeyboardInput() => injectKeyboardInput(input),
    };
  }

  @override
  Future<bool> setInputBlocked(bool blocked, [InputType? type]) async {
    final result = await methodChannel.invokeMethod<bool>('setInputBlocked', {
      'blocked': blocked,
      'type': type?.name,
    });
    return result ?? false;
  }

  @override
  Future<bool> isInputBlocked([InputType? type]) async {
    final result = await methodChannel.invokeMethod<bool>('isInputBlocked', {
      'type': type?.name,
    });
    return result ?? false;
  }
}
