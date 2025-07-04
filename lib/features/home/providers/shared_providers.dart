import 'dart:async';

import 'package:desk_switch/core/services/broadcast_service.dart';
import 'package:desk_switch/core/services/client_service.dart';
import 'package:desk_switch/core/services/server_service.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:input_capture_injection/input_capture_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_providers.g.dart';

final _inputCapture = InputCaptureInjection();

// Provider for whether the server is running
@riverpod
bool serverRunning(Ref ref) {
  final state = ref.watch(serverServiceProvider);
  return state == ServerServiceState.running;
}

@riverpod
ServerServiceState serverState(Ref ref) {
  return ref.watch(serverServiceProvider);
}

@riverpod
ClientServiceState clientState(Ref ref) {
  return ref.watch(clientServiceProvider);
}

@riverpod
class Server extends _$Server {
  StreamSubscription? _mouseCaptureSubscription;
  StreamSubscription? _keyboardCaptureSubscription;

  @override
  ServerInfo? build() {
    return null;
  }

  Future<void> start() async {
    final serverService = ref.read(serverServiceProvider.notifier);
    final broadcastService = ref.read(broadcastServiceProvider.notifier);
    // final inputCaptureService = ref.watch(inputCaptureServiceProvider.notifier);

    final serverInfo = await serverService.start(
      port: 8080,
      name: null,
    );
    if (serverInfo != null) {
      state = serverInfo;
      await broadcastService.start(serverInfo);

      // Subscribe to input capture and log events
      await _inputCapture.requestPermission();
      _mouseCaptureSubscription?.cancel();
      _mouseCaptureSubscription = _inputCapture.mouseInputs().listen((input) {
        logger.info('🖱️ Captured input: $input');
        serverService.sendInput(input.copyWith(timestamp: null));
      });
      _keyboardCaptureSubscription?.cancel();
      _keyboardCaptureSubscription = _inputCapture.keyboardInputs().listen((
        input,
      ) {
        logger.info('🎹 Captured input: $input');
      });
    }
  }

  Future<void> stop() async {
    final serverService = ref.read(serverServiceProvider.notifier);
    final broadcastService = ref.read(broadcastServiceProvider.notifier);
    // final inputCaptureService = ref.watch(inputCaptureServiceProvider.notifier);

    await broadcastService.stop();
    // await inputCaptureService.stop();
    await serverService.stop();
    // Cancel input capture subscription
    await _mouseCaptureSubscription?.cancel();
    _mouseCaptureSubscription = null;
    await _keyboardCaptureSubscription?.cancel();
    _keyboardCaptureSubscription = null;
  }
}

@riverpod
class Client extends _$Client {
  StreamSubscription? _inputSubscription;

  @override
  ClientServiceState build() {
    return ClientServiceState.disconnected;
  }

  Future<void> connect(ServerInfo server) async {
    final clientService = ref.read(clientServiceProvider.notifier);
    await clientService.connect(server);
    _inputSubscription?.cancel();
    _inputSubscription = clientService.inputs().listen((input) {
      logger.info('🔌 Received input: $input');
      // _inputCapture.injectInput(input);
    });
  }

  Future<void> disconnect() async {
    final clientService = ref.read(clientServiceProvider.notifier);
    await clientService.disconnect();
    _inputSubscription?.cancel();
    _inputSubscription = null;
  }
}
