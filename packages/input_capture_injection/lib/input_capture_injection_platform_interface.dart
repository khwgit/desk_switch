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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Initializes the plugin and prepares for input capture/injection.
  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Requests permission to capture keyboard and mouse events.
  Future<bool> requestInputCapture() {
    throw UnimplementedError('requestInputCapture() has not been implemented.');
  }

  /// Checks if input capture permission is required (not yet granted).
  Future<bool> isInputCaptureRequested() {
    throw UnimplementedError(
      'isInputCaptureRequested() has not been implemented.',
    );
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

  /// Requests permission to inject keyboard and mouse events.
  Future<bool> requestInputInjection() {
    throw UnimplementedError(
      'requestInputInjection() has not been implemented.',
    );
  }

  /// Checks if input injection permission is required (not yet granted).
  Future<bool> isInputInjectionRequested() {
    throw UnimplementedError(
      'isInputInjectionRequested() has not been implemented.',
    );
  }

  /// Injects a mouse event.
  Future<void> injectMouseInput(MouseInput input) {
    throw UnimplementedError('injectMouseInput() has not been implemented.');
  }

  /// Injects a keyboard event.
  Future<void> injectKeyboardInput(KeyboardInput input) {
    throw UnimplementedError('injectKeyboardInput() has not been implemented.');
  }
}
