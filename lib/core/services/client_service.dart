import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/input.dart';
import 'package:desk_switch/models/input.pb.dart' as pb;
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_service.g.dart';

enum ClientServiceState {
  disconnecting,
  disconnected,
  connecting,
  connected,
}

@Riverpod(keepAlive: true)
class ClientService extends _$ClientService {
  // WebSocket connection
  WebSocket? _socket;
  StreamController<Input>? _inputController;
  StreamSubscription? _subscription;
  ServerInfo? _connectedServer;

  @override
  ClientServiceState build() {
    return ClientServiceState.disconnected;
  }

  /// Get the input stream
  Stream<Input> inputs() {
    return _inputController?.stream ?? const Stream.empty();
  }

  /// Get the currently connected server
  ServerInfo? get connectedServer => _connectedServer;

  /// Connect to a server using WebSocket
  Future<void> connect(ServerInfo server) async {
    disconnect(); // Clean up any previous connection

    state = ClientServiceState.connecting;
    _connectedServer = server;

    try {
      final uri = Uri.parse('ws://${server.host}:${server.port}');

      logger.info(
        '🔌 Connecting to server: ${server.name} at \\${uri.host}:\\${uri.port}',
      );

      _socket = await WebSocket.connect(uri.toString());
      _inputController = StreamController();

      // Listen to incoming messages
      _subscription = _socket!.listen(
        (data) {
          logger.info(data);
          if (data is List<int> || data is Uint8List) {
            try {
              final pbInput = pb.Input.fromBuffer(data as List<int>);
              _inputController?.add(pbInput.toModel());
            } catch (e) {
              // Handle parse error
            }
          }
        },
        onDone: () {
          logger.info('🔌 Disconnected from server: \\${server.name}');
          state = ClientServiceState.disconnected;
          _connectedServer = null;
          _inputController?.close();
        },
        onError: (error) {
          logger.error('❌ Connection error to \\${server.name}: $error');
          state = ClientServiceState.disconnected;
          _connectedServer = null;
          _inputController?.addError(error);
        },
        cancelOnError: true,
      );

      state = ClientServiceState.connected;
      logger.info('✅ Successfully connected to server: \\${server.name}');
    } catch (error) {
      logger.error('❌ Failed to connect to server \\${server.name}: $error');
      state = ClientServiceState.disconnected;
      _connectedServer = null;
      _inputController?.close();
      rethrow;
    }
  }

  /// Disconnect from the server
  Future<void> disconnect() async {
    if (state == ClientServiceState.disconnecting) {
      logger.info('🔌 Already disconnecting, returning');
      return;
    }

    if (state == ClientServiceState.disconnected) {
      logger.info('🔌 Already disconnected, returning');
      return;
    }

    if (_connectedServer != null) {
      logger.info('🔌 Disconnecting from server: \\${_connectedServer!.name}');
    }

    state = ClientServiceState.disconnecting;
    _connectedServer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close(WebSocketStatus.goingAway);
    _socket = null;
    await _inputController?.close();
    _inputController = null;
    state = ClientServiceState.disconnected;
  }

  /// Send a message to the server
  void send(String message) {
    if (state == ClientServiceState.connected && _socket != null) {
      _socket!.add(message);
    }
  }
}
