import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'server_service.g.dart';

@Riverpod(keepAlive: true)
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
    final serverInfo = ServerInfo(
      id: const Uuid().v4(),
      name: _getCurrentHostName(),
      ip: await _getLocalIpAddress(),
      port: 12345,
      isOnline: true,
    );
    // Bonsoir advertisement
    final service = BonsoirService(
      name: serverInfo.name,
      type: '_deskswitch._tcp',
      port: serverInfo.port,
      attributes: {
        'id': serverInfo.id,
        'ip': serverInfo.ip,
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

  /// Get the local IP address of the device
  Future<String> _getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      logger.info('🔍 Interface: ${interface.name}');
      for (final addr in interface.addresses) {
        if (!addr.isLoopback && !addr.address.startsWith('169.254.')) {
          return addr.address;
        }
      }
    }
    return '127.0.0.1';
  }

  /// Get the current desktop/PC name (hostname) in the workgroup
  String _getCurrentHostName() {
    return Platform.localHostname;
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
