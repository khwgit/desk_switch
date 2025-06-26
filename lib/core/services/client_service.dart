import 'dart:async';

import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

part 'client_service.g.dart';

enum ClientServiceState {
  disconnected,
  connecting,
  connected,
}

@Riverpod(keepAlive: true)
class ClientService extends _$ClientService {
  // WebSocket connection
  WebSocketChannel? _channel;
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
      final uri = Uri.parse(
        'ws://${server.host ?? "localhost"}:${12345}',
      );
      _channel = WebSocketChannel.connect(uri);
      _messageController = StreamController<String>();

      // Listen to incoming messages
      _subscription = _channel!.stream.listen(
        (message) {
          _messageController?.add(message);
        },
        onDone: () {
          state = ClientServiceState.disconnected;
          _connectedServer = null;
          _messageController?.close();
        },
        onError: (error) {
          state = ClientServiceState.disconnected;
          _connectedServer = null;
          _messageController?.addError(error);
        },
        cancelOnError: true,
      );

      state = ClientServiceState.connected;
    } catch (error) {
      state = ClientServiceState.disconnected;
      _connectedServer = null;
      _messageController?.close();
      rethrow;
    }
  }

  /// Disconnect from the server
  void disconnect() {
    state = ClientServiceState.disconnected;
    _connectedServer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _messageController?.close();
    _messageController = null;
  }

  /// Send a message to the server
  void send(String message) {
    if (state == ClientServiceState.connected && _channel != null) {
      _channel!.sink.add(message);
    }
  }

  /// Whether the client is currently connected
  bool get isConnected => state == ClientServiceState.connected;

  /// Whether the client is currently connecting
  bool get isConnecting => state == ClientServiceState.connecting;
}
