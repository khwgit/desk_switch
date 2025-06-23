import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

part 'client_service.g.dart';

@riverpod
class ClientService extends _$ClientService {
  // WebSocket connection
  WebSocketChannel? _channel;
  StreamController<String>? _messageController;
  StreamSubscription? _subscription;
  bool _isConnected = false;

  // Bonsoir Discovery
  BonsoirDiscovery? _discovery;
  StreamController<ServerInfo>? _discoveryController;
  StreamSubscription? _discoverySubscription;
  bool _isDiscovering = false;

  @override
  Stream<String> build() {
    // By default, no connection/messages
    return _messageController?.stream ?? Stream.empty();
  }

  /// Connect to a server using WebSocket
  Future<void> connect(ServerInfo server) async {
    disconnect(); // Clean up any previous connection

    final uri = Uri.parse('ws://${server.ipAddress}:${server.port}');
    _channel = WebSocketChannel.connect(uri);
    _messageController = StreamController<String>();
    _isConnected = true;

    // Listen to incoming messages
    _subscription = _channel!.stream.listen(
      (message) {
        _messageController?.add(message);
      },
      onDone: () {
        _isConnected = false;
        _messageController?.close();
      },
      onError: (error) {
        _isConnected = false;
        _messageController?.addError(error);
      },
      cancelOnError: true,
    );
    // No need to update state directly; stream will update
  }

  /// Disconnect from the server
  void disconnect() {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _messageController?.close();
    _messageController = null;
    // No need to update state directly; stream will update
  }

  /// Send a message to the server
  void send(String message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(message);
    }
  }

  /// Whether the client is currently connected
  bool get isConnected => _isConnected;

  /// Start discovering servers (using Bonsoir)
  Stream<ServerInfo> discover() {
    void stop() {
      _isDiscovering = false;
      _discoverySubscription?.cancel();
      _discoverySubscription = null;
      _discoveryController?.close();
      _discoveryController = null;
      _discovery?.stop();
      _discovery = null;
    }

    _discoveryController = StreamController<ServerInfo>(
      onCancel: () {
        stop();
      },
    );
    _isDiscovering = true;
    _discovery = BonsoirDiscovery(type: '_deskswitch._tcp');
    _discovery!.ready.then((_) => _discovery!.start());
    _discoverySubscription = _discovery!.eventStream?.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        final service = event.service;
        final serverInfo = ServerInfo(
          id: service?.attributes['id'] ?? service?.name ?? '',
          name: service?.name ?? '',
          ipAddress: service?.attributes['ip'] ?? '',
          port: service?.port ?? 0,
          isOnline: true,
          lastSeen: DateTime.now().toIso8601String(),
        );
        _discoveryController?.add(serverInfo);
      }
    });
    return _discoveryController!.stream;
  }

  bool get isDiscovering => _isDiscovering;
}
