import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_capture_injection/input_capture_injection_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelInputCaptureInjection platform =
      MethodChannelInputCaptureInjection();
  const MethodChannel channel = MethodChannel('input_capture_injection');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('platform instantiation', () async {
    expect(platform, isNotNull);
  });
}
