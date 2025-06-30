import 'dart:async';
import 'dart:io';

import 'package:desk_switch/core/services/system_service.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/client_info.dart';
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
  final Map<String, ClientInfo> _clients = {};
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<List<ClientInfo>> _clientsController =
      StreamController<List<ClientInfo>>.broadcast();

  @override
  ServerServiceState build() {
    return ServerServiceState.stopped;
  }

  /// Get the message stream
  Stream<String> messages() {
    return _messageController.stream;
  }

  /// Get the connected clients stream
  Stream<List<ClientInfo>> clients() {
    return _clientsController.stream;
  }

  /// Get the current clients
  List<ClientInfo> get currentClients => _clients.values.toList();

  /// Start WebSocket server
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

          // Create client info
          final clientAddress =
              request.connectionInfo?.remoteAddress.address ?? 'unknown';
          final clientPort = request.connectionInfo?.remotePort ?? 0;

          final clientInfo = ClientInfo(
            id: const Uuid().v4(),
            name: clientAddress,
            port: clientPort,
            socket: ws,
            isActive: true,
          );

          _clients[clientInfo.id] = clientInfo;
          _notifyClientsChanged();

          logger.info(
            '🔌 Client connected: ${clientInfo.name} ([32m${_clients.length}[0m total)',
          );

          ws.listen(
            (data) {
              logger.info(data);
              if (data is String) {
                _messageController.add(data);
              }
              // Optionally handle binary data
            },
            onDone: () {
              _removeClient(clientInfo.id);
            },
            onError: (error) {
              logger.error(
                '❌ WebSocket error from ${clientInfo.name}: $error',
              );
              _removeClient(clientInfo.id);
            },
            cancelOnError: true,
          );
        } else {
          // Not a websocket request
          request.response.statusCode = HttpStatus.badRequest;
          await request.response.close();
        }
      });

      // Get machine ID from system service
      final systemService = ref.read(systemServiceProvider.notifier);

      _serverInfo = ServerInfo(
        id: await systemService.getMachineId(),
        name: await systemService.getMachineName(),
        port: _wsServer!.port,
        host: _wsServer!.address.address,
      );
      state = ServerServiceState.running;
      logger.info(
        '🖥️ Server started: ${_serverInfo?.name} (${_serverInfo?.host}:${_serverInfo?.port}) (Machine ID: ${_serverInfo?.id})',
      );
    } catch (error) {
      logger.error('❌ Failed to start server: $error');
      state = ServerServiceState.stopped;
      rethrow;
    }

    _notifyClientsChanged();
    return _serverInfo;
  }

  /// Stop WebSocket server
  Future<void> stop() async {
    if (state == ServerServiceState.stopped) {
      return;
    }

    state = ServerServiceState.stopping;

    try {
      // Stop WebSocket server
      await _wsServer?.close(force: true);
      _wsServer = null;
      _serverInfo = null;

      // Close all client connections
      _clients.clear();
      _notifyClientsChanged();

      state = ServerServiceState.stopped;
      logger.info('🛑 Server stopped');
    } catch (error) {
      logger.error('❌ Error stopping server: $error');
      state = ServerServiceState.stopped;
      rethrow;
    }
  }

  /// Send a message to all connected clients or a specific client
  void send(String message, [String? clientId]) {
    for (final client in _clients.values) {
      if (clientId == null || client.id == clientId) {
        client.socket?.add(message);
      }
    }
  }

  /// Remove a client from the connected clients list
  void _removeClient(String clientId) {
    final info = _clients.remove(clientId);
    _notifyClientsChanged();
    logger.info(
      '🔌 Client disconnected: ${info?.name} ([31m${_clients.length}[0m remaining)',
    );
  }

  /// Notify listeners that the clients list has changed
  void _notifyClientsChanged() {
    if (!_clientsController.isClosed) {
      _clientsController.add(_clients.values.toList());
    }
  }
}
