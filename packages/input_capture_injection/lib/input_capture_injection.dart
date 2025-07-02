import 'input_capture_injection_platform_interface.dart';
import 'models/input.dart';

export 'models/input.dart';

class InputCaptureInjection {
  Future<String?> getPlatformVersion() {
    return InputCaptureInjectionPlatform.instance.getPlatformVersion();
  }

  Future<void> initialize() {
    return InputCaptureInjectionPlatform.instance.initialize();
  }

  Future<bool> requestInputCapture() {
    return InputCaptureInjectionPlatform.instance.requestInputCapture();
  }

  Future<bool> isInputCaptureRequested() {
    return InputCaptureInjectionPlatform.instance.isInputCaptureRequested();
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

  Future<bool> requestInputInjection() {
    return InputCaptureInjectionPlatform.instance.requestInputInjection();
  }

  Future<bool> isInputInjectionRequested() {
    return InputCaptureInjectionPlatform.instance.isInputInjectionRequested();
  }

  Future<void> injectMouseInput(MouseInput input) {
    return InputCaptureInjectionPlatform.instance.injectMouseInput(input);
  }

  Future<void> injectKeyboardInput(KeyboardInput input) {
    return InputCaptureInjectionPlatform.instance.injectKeyboardInput(input);
  }
}
