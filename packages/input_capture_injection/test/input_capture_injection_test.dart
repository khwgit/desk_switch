import 'package:flutter_test/flutter_test.dart';
import 'package:input_capture_injection/input_capture_injection.dart';
import 'package:input_capture_injection/input_capture_injection_method_channel.dart';
import 'package:input_capture_injection/input_capture_injection_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInputCaptureInjectionPlatform
    with MockPlatformInterfaceMixin
    implements InputCaptureInjectionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> injectKeyboardInput(KeyboardInput input) {
    // TODO: implement injectKeyboardInput
    throw UnimplementedError();
  }

  @override
  Future<void> injectMouseInput(MouseInput input) {
    // TODO: implement injectMouseInput
    throw UnimplementedError();
  }

  @override
  Future<bool> isInputCaptureRequested() {
    // TODO: implement isInputCaptureRequested
    throw UnimplementedError();
  }

  @override
  Future<bool> isInputInjectionRequested() {
    // TODO: implement isInputInjectionRequested
    throw UnimplementedError();
  }

  @override
  Stream<KeyboardInput> keyboardInputs() {
    // TODO: implement keyInputs
    throw UnimplementedError();
  }

  @override
  Stream<MouseInput> mouseInputs() {
    // TODO: implement mouseInputs
    throw UnimplementedError();
  }

  @override
  Stream<Input> inputs() {
    // TODO: implement inputs
    throw UnimplementedError();
  }

  @override
  Future<bool> requestInputCapture() {
    // TODO: implement requestInputCapture
    throw UnimplementedError();
  }

  @override
  Future<bool> requestInputInjection() {
    // TODO: implement requestInputInjection
    throw UnimplementedError();
  }
}

void main() {
  final InputCaptureInjectionPlatform initialPlatform =
      InputCaptureInjectionPlatform.instance;

  test('$MethodChannelInputCaptureInjection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInputCaptureInjection>());
  });

  test('getPlatformVersion', () async {
    InputCaptureInjection inputCaptureInjectionPlugin = InputCaptureInjection();
    MockInputCaptureInjectionPlatform fakePlatform =
        MockInputCaptureInjectionPlatform();
    InputCaptureInjectionPlatform.instance = fakePlatform;

    expect(await inputCaptureInjectionPlugin.getPlatformVersion(), '42');
  });
}
