import 'dart:async';
import 'dart:io';

import 'package:desk_switch/core/services/broadcast_service.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'server_service.g.dart';

enum ServerServiceState {
  stopped,
  starting,
  running,
  stopping,
}

@Riverpod(keepAlive: true)
class ServerService extends _$ServerService {
  // WebSocket Server
  HttpServer? _wsServer;
  ServerInfo? _serverInfo;
  final List<WebSocket> _clients = [];
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  @override
  ServerServiceState build() {
    return ServerServiceState.stopped;
  }

  /// Get the message stream
  Stream<String> messages() {
    return _messageController.stream;
  }

  /// Start WebSocket server and broadcast service
  Future<ServerInfo?> start() async {
    if (state == ServerServiceState.running) {
      logger.info('🖥️ Server already running');
      return _serverInfo;
    }

    state = ServerServiceState.starting;

    try {
      // Start WebSocket server
      _wsServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        0, // TODO: get port from config
      );
      _wsServer!.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final ws = await WebSocketTransformer.upgrade(request);
          _clients.add(ws);
          logger.info('🔌 Client connected: ${_clients.length} total');

          ws.listen(
            (data) {
              if (data is String) {
                _messageController.add(data);
              }
              // Optionally handle binary data
            },
            onDone: () {
              _clients.remove(ws);
              logger.info(
                '🔌 Client disconnected: ${_clients.length} remaining',
              );
            },
            onError: (error) {
              logger.error('❌ WebSocket error: $error');
              _clients.remove(ws);
            },
            cancelOnError: true,
          );
        } else {
          // Not a websocket request
          request.response.statusCode = HttpStatus.badRequest;
          await request.response.close();
        }
      });

      _serverInfo = ServerInfo(
        id: const Uuid().v4(),
        name: Platform.localHostname,
        port: _wsServer!.port,
        host: _wsServer!.address.address,
      );
      state = ServerServiceState.running;
      logger.info(
        '🖥️ Server started: ${_serverInfo?.name} (${_serverInfo?.host}:${_serverInfo?.port})',
      );
    } catch (error) {
      logger.error('❌ Failed to start server: $error');
      state = ServerServiceState.stopped;
      rethrow;
    }

    return _serverInfo;
  }

  /// Stop WebSocket server and broadcast service
  Future<void> stop() async {
    if (state == ServerServiceState.stopped) {
      return;
    }

    state = ServerServiceState.stopping;

    try {
      // Stop broadcast service
      final broadcastService = ref.read(broadcastServiceProvider.notifier);
      await broadcastService.stop();

      // Stop WebSocket server
      await _wsServer?.close(force: true);
      _wsServer = null;
      _serverInfo = null;

      // Close all client connections
      for (final ws in _clients) {
        await ws.close();
      }
      _clients.clear();

      state = ServerServiceState.stopped;
      logger.info('🛑 Server stopped');
    } catch (error) {
      logger.error('❌ Error stopping server: $error');
      state = ServerServiceState.stopped;
      rethrow;
    }
  }

  /// Send a message to all connected clients
  void send(String message) {
    for (final ws in _clients) {
      if (ws.readyState == WebSocket.open) {
        ws.add(message);
      }
    }
  }

  /// Get the number of connected clients
  int get clientCount => _clients.length;
}
