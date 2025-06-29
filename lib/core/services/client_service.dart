import 'dart:async';
import 'dart:io';

import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_service.g.dart';

enum ClientServiceState {
  disconnected,
  connecting,
  connected,
}

@Riverpod(keepAlive: true)
class ClientService extends _$ClientService {
  // WebSocket connection
  WebSocket? _socket;
  StreamController<String>? _messageController;
  StreamSubscription? _subscription;
  ServerInfo? _connectedServer;

  @override
  ClientServiceState build() {
    return ClientServiceState.disconnected;
  }

  /// Get the message stream
  Stream<String> messages() {
    return _messageController?.stream ?? const Stream.empty();
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
      _messageController = StreamController<String>();

      // Listen to incoming messages
      _subscription = _socket!.listen(
        (message) {
          logger.info(message);
          if (message is String) {
            _messageController?.add(message);
          }
        },
        onDone: () {
          logger.info('🔌 Disconnected from server: \\${server.name}');
          state = ClientServiceState.disconnected;
          _connectedServer = null;
          _messageController?.close();
        },
        onError: (error) {
          logger.error('❌ Connection error to \\${server.name}: $error');
          state = ClientServiceState.disconnected;
          _connectedServer = null;
          _messageController?.addError(error);
        },
        cancelOnError: true,
      );

      state = ClientServiceState.connected;
      logger.info('✅ Successfully connected to server: \\${server.name}');
    } catch (error) {
      logger.error('❌ Failed to connect to server \\${server.name}: $error');
      state = ClientServiceState.disconnected;
      _connectedServer = null;
      _messageController?.close();
      rethrow;
    }
  }

  /// Disconnect from the server
  Future<void> disconnect() async {
    if (_connectedServer != null) {
      logger.info('🔌 Disconnecting from server: \\${_connectedServer!.name}');
    }

    state = ClientServiceState.disconnected;
    _connectedServer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close(WebSocketStatus.goingAway);
    _socket = null;
    await _messageController?.close();
    _messageController = null;
  }

  /// Send a message to the server
  void send(String message) {
    if (state == ClientServiceState.connected && _socket != null) {
      _socket!.add(message);
    }
  }
}
