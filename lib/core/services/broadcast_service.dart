import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'broadcast_service.g.dart';

enum BroadcastServiceState {
  stopped,
  starting,
  broadcasting,
  stopping,
}

@Riverpod(keepAlive: true)
class BroadcastService extends _$BroadcastService {
  // Bonsoir for service advertisement
  BonsoirBroadcast? _broadcast;
  ServerInfo? _serverInfo;

  @override
  BroadcastServiceState build() {
    return BroadcastServiceState.stopped;
  }

  /// Get the current server info being broadcast
  ServerInfo? get serverInfo => _serverInfo;

  /// Start Bonsoir advertisement
  Future<void> start() async {
    if (state == BroadcastServiceState.broadcasting) {
      logger.info('📡 Broadcast already running');
      return;
    }

    state = BroadcastServiceState.starting;

    try {
      _serverInfo = ServerInfo(
        id: const Uuid().v4(),
        name: _getCurrentHostName(),
        ip: await _getLocalIpAddress(),
        port: 12345,
        isOnline: true,
      );

      // Bonsoir advertisement
      final service = BonsoirService(
        name: _serverInfo!.name,
        type: '_deskswitch._tcp',
        port: _serverInfo!.port,
        attributes: {
          'id': _serverInfo!.id,
          'ip': _serverInfo!.ip,
        },
      );

      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.ready;
      await _broadcast!.start();

      state = BroadcastServiceState.broadcasting;
      logger.info(
        '📡 Started broadcasting: ${_serverInfo!.name} (${_serverInfo!.ip}:${_serverInfo!.port})',
      );
    } catch (error) {
      logger.error('❌ Failed to start broadcast: $error');
      state = BroadcastServiceState.stopped;
      _serverInfo = null;
      rethrow;
    }
  }

  /// Stop Bonsoir advertisement
  Future<void> stop() async {
    if (state == BroadcastServiceState.stopped) {
      return;
    }

    state = BroadcastServiceState.stopping;

    try {
      await _broadcast?.stop();
      _broadcast = null;
      _serverInfo = null;
      state = BroadcastServiceState.stopped;
      logger.info('🛑 Stopped broadcasting');
    } catch (error) {
      logger.error('❌ Error stopping broadcast: $error');
      state = BroadcastServiceState.stopped;
      rethrow;
    }
  }

  /// Whether the service is currently broadcasting
  bool get isBroadcasting => state == BroadcastServiceState.broadcasting;

  /// Whether the service is starting up
  bool get isStarting => state == BroadcastServiceState.starting;

  /// Whether the service is stopping
  bool get isStopping => state == BroadcastServiceState.stopping;

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
}
