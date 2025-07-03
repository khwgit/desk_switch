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
  Future<bool> requestPermission([Set<InputType>? types]) async {
    final result = await methodChannel.invokeMethod<bool>('requestPermission', {
      'types': types?.map((type) => type.name).toList(),
    });
    return result ?? false;
  }

  @override
  Future<bool> isPermissionGranted([Set<InputType>? types]) async {
    final result = await methodChannel.invokeMethod<bool>(
      'isPermissionGranted',
      {'types': types?.map((type) => type.name).toList()},
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
  Future<bool> setInputBlocked(bool blocked, [Set<InputType>? types]) async {
    final result = await methodChannel.invokeMethod<bool>('setInputBlocked', {
      'blocked': blocked,
      'types': types?.map((type) => type.name).toList(),
    });
    return result ?? false;
  }

  @override
  Future<bool> isInputBlocked([Set<InputType>? types]) async {
    final inputs = await getBlockedInputs();
    return types == null
        ? inputs.isNotEmpty
        : inputs.any((type) => types.contains(type));
  }

  @override
  Future<Set<InputType>> getBlockedInputs() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getBlockedInputs',
    );
    if (result == null) {
      return <InputType>{};
    }

    final blockedTypes = <InputType>{};
    for (final typeName in result) {
      if (typeName is String) {
        final inputType = InputType.values.firstWhere(
          (type) => type.name == typeName,
          orElse: () => InputType.keyboard, // fallback, shouldn't happen
        );
        blockedTypes.add(inputType);
      }
    }
    return blockedTypes;
  }
}
