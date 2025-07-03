import 'input_capture_injection_platform_interface.dart';
import 'models/input.dart';

export 'models/input.dart';

class InputCaptureInjection {
  Future<bool> requestPermission([InputType? type]) {
    return InputCaptureInjectionPlatform.instance.requestPermission(type);
  }

  Future<bool> isPermissionGranted([InputType? type]) {
    return InputCaptureInjectionPlatform.instance.isPermissionGranted(type);
  }

  Stream<KeyboardInput> keyboardInputs() {
    return InputCaptureInjectionPlatform.instance.keyboardInputs();
  }

  Stream<MouseInput> mouseInputs() {
    return InputCaptureInjectionPlatform.instance.mouseInputs();
  }

  Stream<Input> inputs() {
    return InputCaptureInjectionPlatform.instance.inputs();
  }

  Future<void> injectMouseInput(MouseInput input) {
    return InputCaptureInjectionPlatform.instance.injectMouseInput(input);
  }

  Future<void> injectKeyboardInput(KeyboardInput input) {
    return InputCaptureInjectionPlatform.instance.injectKeyboardInput(input);
  }

  Future<void> injectInput(Input input) {
    return InputCaptureInjectionPlatform.instance.injectInput(input);
  }

  Future<bool> setInputBlocked(bool blocked, [InputType? type]) {
    return InputCaptureInjectionPlatform.instance.setInputBlocked(
      blocked,
      type,
    );
  }

  Future<bool> isInputBlocked([InputType? type]) {
    return InputCaptureInjectionPlatform.instance.isInputBlocked(type);
  }
}
