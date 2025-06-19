import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desk_switch/core/states/app_state.dart';
import 'package:desk_switch/models/server_config.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_service.g.dart';

@riverpod
class ServerService extends _$ServerService {
  // UDP Discovery
  static const _discoveryPort = 12345;
  static const _multicastAddress = '239.255.255.250';
  static const _broadcastAddress = '255.255.255.255';

  // WebSocket Server
  HttpServer? _wsServer;
  final List<WebSocket> _clients = [];
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  RawDatagramSocket? _socket;
  Timer? _signalTimer;
  bool _isRunning = false;

  @override
  Stream<String> build() {
    // By default, no messages
    return _messageController.stream;
  }

  /// Start UDP broadcast and WebSocket server
  Future<void> start() async {
    if (_isRunning) return;
    final serverInfo = _getCurrentServerInfo();
    if (serverInfo == null) {
      throw Exception('No active server profile/config found');
    }
    // UDP broadcast
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );
    _socket!.broadcastEnabled = true;
    _signalTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _sendServerSignal(serverInfo);
    });
    // WebSocket server
    _wsServer = await HttpServer.bind(InternetAddress.anyIPv4, serverInfo.port);
    _wsServer!.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final ws = await WebSocketTransformer.upgrade(request);
        _clients.add(ws);
        ws.listen(
          (data) {
            if (data is String) {
              _messageController.add(data);
            }
            // Optionally handle binary data
          },
          onDone: () => _clients.remove(ws),
          onError: (_) => _clients.remove(ws),
          cancelOnError: true,
        );
      } else {
        // Not a websocket request
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
      }
    });
    _isRunning = true;
  }

  /// Stop UDP broadcast and WebSocket server
  Future<void> stop() async {
    if (!_isRunning) return;
    _signalTimer?.cancel();
    _signalTimer = null;
    _socket?.close();
    _socket = null;
    await _wsServer?.close(force: true);
    _wsServer = null;
    for (final ws in _clients) {
      await ws.close();
    }
    _clients.clear();
    _isRunning = false;
    await _messageController.close();
  }

  /// Whether the service is running
  bool get isRunning => _isRunning;

  /// Send a server signal (multicast and broadcast)
  void _sendServerSignal(ServerInfo serverInfo, {RawDatagramSocket? socket}) {
    final s = socket ?? _socket;
    if (s == null) return;
    final signalMessage = {
      'type': 'DESK_SWITCH_SERVER_MULTICAST',
      'server': serverInfo.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    final message = jsonEncode(signalMessage);
    final data = message.codeUnits;
    // Multicast
    s.send(data, InternetAddress(_multicastAddress), _discoveryPort);
    // Broadcast
    s.send(data, InternetAddress(_broadcastAddress), _discoveryPort);
  }

  /// Get the current server info from app state
  ServerInfo? _getCurrentServerInfo() {
    return ServerInfo(
      id: '1',
      name: 'test',
      ipAddress: '127.0.0.1',
      port: 12345,
      isOnline: true,
      lastSeen: DateTime.now().toIso8601String(),
    );

    final appState = ref.read(appStateProvider);
    final profile = appState.serverConfig.profile;
    if (profile == null) return null;
    return ServerInfo(
      id: profile.id,
      name: profile.displayName,
      ipAddress: profile.networkInterface ?? '127.0.0.1',
      port: profile.port,
      isOnline: true,
      lastSeen: DateTime.now().toIso8601String(),
    );
  }

  /// Send a message to all connected clients
  void send(String message) {
    for (final ws in _clients) {
      if (ws.readyState == WebSocket.open) {
        ws.add(message);
      }
    }
  }
}
