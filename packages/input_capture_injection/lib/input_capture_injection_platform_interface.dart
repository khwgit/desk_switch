import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'input_capture_injection_method_channel.dart';
import 'models/input.dart';

abstract class InputCaptureInjectionPlatform extends PlatformInterface {
  /// Constructs a InputCaptureInjectionPlatform.
  InputCaptureInjectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static InputCaptureInjectionPlatform _instance =
      MethodChannelInputCaptureInjection();

  /// The default instance of [InputCaptureInjectionPlatform] to use.
  ///
  /// Defaults to [MethodChannelInputCaptureInjection].
  static InputCaptureInjectionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InputCaptureInjectionPlatform] when
  /// they register themselves.
  static set instance(InputCaptureInjectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Requests permission to capture and inject input events.
  /// When [type] is null, requests all input capture and injection permissions.
  Future<bool> requestPermission([InputType? type]) {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  /// Checks if permission is granted.
  /// When [type] is null, returns false if any input capture and injection permission is not granted.
  Future<bool> isPermissionGranted([InputType? type]) {
    throw UnimplementedError('isPermissionGranted() has not been implemented.');
  }

  /// Stream of captured keyboard events.
  Stream<KeyboardInput> keyboardInputs() {
    throw UnimplementedError('keyboardInputs() has not been implemented.');
  }

  /// Stream of captured mouse events.
  Stream<MouseInput> mouseInputs() {
    throw UnimplementedError('mouseInputs() has not been implemented.');
  }

  /// Stream of all input events (keyboard and mouse).
  Stream<Input> inputs() {
    throw UnimplementedError('inputs() has not been implemented.');
  }

  /// Injects a mouse event.
  Future<void> injectMouseInput(MouseInput input) {
    throw UnimplementedError('injectMouseInput() has not been implemented.');
  }

  /// Injects a keyboard event.
  Future<void> injectKeyboardInput(KeyboardInput input) {
    throw UnimplementedError('injectKeyboardInput() has not been implemented.');
  }

  /// Injects an input event.
  Future<void> injectInput(Input input) {
    throw UnimplementedError('injectInput() has not been implemented.');
  }

  /// Sets whether input should be blocked.
  /// When [type] is null, blocks all inputs.
  Future<bool> setInputBlocked(bool blocked, [InputType? type]) {
    throw UnimplementedError('setInputBlocked() has not been implemented.');
  }

  /// Checks if input is blocked.
  /// When [type] is null, returns true if any input is blocked.
  Future<bool> isInputBlocked([InputType? type]) {
    throw UnimplementedError('isInputBlocked() has not been implemented.');
  }
}
