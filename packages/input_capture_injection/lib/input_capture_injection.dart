import 'input_capture_injection_platform_interface.dart';
import 'models/input.dart';

export 'models/input.dart';

class InputCaptureInjection {
  Future<bool> requestPermission([Set<InputType>? types]) {
    return InputCaptureInjectionPlatform.instance.requestPermission(types);
  }

  Future<bool> isPermissionGranted([Set<InputType>? types]) {
    return InputCaptureInjectionPlatform.instance.isPermissionGranted(types);
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

  Future<bool> setInputBlocked(bool blocked, [Set<InputType>? types]) {
    return InputCaptureInjectionPlatform.instance.setInputBlocked(
      blocked,
      types,
    );
  }

  Future<bool> isInputBlocked([Set<InputType>? types]) {
    return InputCaptureInjectionPlatform.instance.isInputBlocked(types);
  }

  Future<Set<InputType>> getBlockedInputs() {
    return InputCaptureInjectionPlatform.instance.getBlockedInputs();
  }
}
