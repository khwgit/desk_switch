import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:desk_switch/core/states/app_state.dart';
import 'package:desk_switch/models/server_config.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_service.g.dart';

@riverpod
class ServerService extends _$ServerService {
  // Bonsoir for service advertisement
  BonsoirBroadcast? _broadcast;

  // WebSocket Server
  HttpServer? _wsServer;
  final List<WebSocket> _clients = [];
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  bool _isRunning = false;

  @override
  Stream<String> build() {
    // By default, no messages
    return _messageController.stream;
  }

  /// Start Bonsoir advertisement and WebSocket server
  Future<void> start() async {
    if (_isRunning) return;
    final serverInfo = _getCurrentServerInfo();
    if (serverInfo == null) {
      throw Exception('No active server profile/config found');
    }
    // Bonsoir advertisement
    final service = BonsoirService(
      name: serverInfo.name,
      type: '_deskswitch._udp',
      port: serverInfo.port,
      // You can add attributes if needed
      attributes: {
        'id': serverInfo.id,
        'ip': serverInfo.ipAddress,
      },
    );

    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.ready;
    await _broadcast!.start();
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

  /// Stop Bonsoir advertisement and WebSocket server
  Future<void> stop() async {
    if (!_isRunning) return;
    await _broadcast?.stop();
    _broadcast = null;
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
