import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'broadcast_service.g.dart';

enum BroadcastServiceState {
  idle,
  starting,
  broadcasting,
  stopping,
}

@Riverpod(keepAlive: true)
class BroadcastService extends _$BroadcastService {
  // Bonsoir for service advertisement
  BonsoirBroadcast? _broadcast;

  @override
  BroadcastServiceState build() {
    return BroadcastServiceState.idle;
  }

  /// Start Bonsoir advertisement
  Future<void> start() async {
    if (state == BroadcastServiceState.broadcasting) {
      logger.info('📡 Broadcast already running');
      return;
    }

    state = BroadcastServiceState.starting;

    try {
      // Bonsoir advertisement
      final service = BonsoirService(
        name: Platform.localHostname,
        type: '_deskswitch._tcp',
        port: await _findAvailablePort(), // TODO: get port from config
        attributes: {
          'id': const Uuid().v4(),
        },
      );

      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.ready;
      await _broadcast!.start();

      state = BroadcastServiceState.broadcasting;
      logger.info('📡 Started broadcasting: ${service.name}:${service.port}');
    } catch (error) {
      logger.error('❌ Failed to start broadcast: $error');
      state = BroadcastServiceState.idle;
      rethrow;
    }
  }

  /// Stop Bonsoir advertisement
  Future<void> stop() async {
    if (state == BroadcastServiceState.idle) {
      return;
    }

    state = BroadcastServiceState.stopping;

    try {
      await _broadcast?.stop();
      _broadcast = null;
      state = BroadcastServiceState.idle;
      logger.info('🛑 Stopped broadcasting');
    } catch (error) {
      logger.error('❌ Error stopping broadcast: $error');
      state = BroadcastServiceState.idle;
      rethrow;
    }
  }

  /// Find an available port by binding to port 0
  Future<int> _findAvailablePort() async {
    final socket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }
}
