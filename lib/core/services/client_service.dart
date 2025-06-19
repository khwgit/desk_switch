import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  // Discovery
  static const _discoveryPort = 12345;
  static const _multicastAddress = '239.255.255.250';
  RawDatagramSocket? _discoverySocket;
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

  /// Start discovering servers (UDP multicast)
  Stream<ServerInfo> discover() {
    /// Stop discovering servers
    void stop() {
      _isDiscovering = false;
      _discoverySubscription?.cancel();
      _discoverySubscription = null;
      _discoveryController?.close();
      _discoveryController = null;
      if (_discoverySocket != null) {
        try {
          final multicastGroup = InternetAddress(_multicastAddress);
          _discoverySocket!.leaveMulticast(multicastGroup);
        } catch (_) {}
        _discoverySocket!.close();
        _discoverySocket = null;
      }
    }

    _discoveryController = StreamController<ServerInfo>(
      onCancel: () {
        stop();
      },
    );
    _isDiscovering = true;
    RawDatagramSocket.bind(InternetAddress.anyIPv4, _discoveryPort).then((
      socket,
    ) {
      _discoverySocket = socket;
      try {
        final multicastGroup = InternetAddress(_multicastAddress);
        socket.joinMulticast(multicastGroup);
      } catch (_) {}
      _discoverySubscription = socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram == null) return;
          final message = String.fromCharCodes(datagram.data);
          if (message.startsWith('{')) {
            try {
              final json = jsonDecode(message) as Map<String, dynamic>;
              final type = json['type'] as String?;
              if (type == 'DESK_SWITCH_SERVER_BROADCAST' ||
                  type == 'DESK_SWITCH_SERVER_MULTICAST') {
                final serverJson = json['server'] as Map<String, dynamic>;
                final serverInfo = ServerInfo.fromJson(serverJson).copyWith(
                  ipAddress: datagram.address.address,
                  isOnline: true,
                  lastSeen: DateTime.now().toIso8601String(),
                );
                _discoveryController?.add(serverInfo);
              }
            } catch (_) {}
          }
        }
      });
    });
    return _discoveryController!.stream;
  }

  bool get isDiscovering => _isDiscovering;
}
