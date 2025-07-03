// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:input_capture_injection/input_capture_injection.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin initialization test', (WidgetTester tester) async {
    final InputCaptureInjection plugin = InputCaptureInjection();
    // Test that the plugin can be instantiated without errors
    expect(plugin, isNotNull);
  });
}
