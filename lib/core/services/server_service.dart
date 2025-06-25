import 'dart:async';
import 'dart:io';

import 'package:desk_switch/core/services/broadcast_service.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  Future<void> start() async {
    if (state == ServerServiceState.running) {
      logger.info('🖥️ Server already running');
      return;
    }

    state = ServerServiceState.starting;

    try {
      // Start broadcast service first
      final broadcastService = ref.read(broadcastServiceProvider.notifier);
      await broadcastService.start();

      final serverInfo = broadcastService.serverInfo;
      if (serverInfo == null) {
        throw Exception('Failed to get server info from broadcast service');
      }

      // Start WebSocket server
      _wsServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        serverInfo.port ?? 0,
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

      state = ServerServiceState.running;
      logger.info('🖥️ Server started on port ${serverInfo.port ?? "-"}');
    } catch (error) {
      logger.error('❌ Failed to start server: $error');
      state = ServerServiceState.stopped;
      rethrow;
    }
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

  /// Whether the service is currently running
  bool get isRunning => state == ServerServiceState.running;

  /// Whether the service is starting up
  bool get isStarting => state == ServerServiceState.starting;

  /// Whether the service is stopping
  bool get isStopping => state == ServerServiceState.stopping;

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
