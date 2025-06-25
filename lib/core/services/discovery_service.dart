import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:desk_switch/core/utils/logger.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discovery_service.g.dart';

enum DiscoveryServiceState {
  stopped,
  discovering,
}

@Riverpod(keepAlive: true)
class DiscoveryService extends _$DiscoveryService {
  BonsoirDiscovery? _discovery;
  StreamController<List<ServerInfo>>? _discoveryController;
  StreamSubscription? _discoverySubscription;
  final Map<String, ServerInfo> _discoveredServers = {};

  @override
  DiscoveryServiceState build() {
    return DiscoveryServiceState.stopped;
  }

  /// Get the discovered servers stream
  Stream<List<ServerInfo>> discover() async* {
    if (state == DiscoveryServiceState.discovering) {
      logger.info('🔍 Discovery already running, returning existing stream');
      yield* _discoveryController!.stream;
      return;
    }

    void stop() {
      logger.info('🛑 Stopping discovery');
      state = DiscoveryServiceState.stopped;
      _discoverySubscription?.cancel();
      _discoverySubscription = null;
      _discoveryController?.close();
      _discoveryController = null;
      _discovery?.stop();
      _discovery = null;
      _discoveredServers.clear();
    }

    logger.info('🚀 Starting discovery');
    _discoveryController = StreamController<List<ServerInfo>>(
      onCancel: () {
        stop();
      },
    );
    state = DiscoveryServiceState.discovering;
    _discovery = BonsoirDiscovery(type: '_deskswitch._tcp');
    await _discovery!.ready;
    _discoverySubscription = _discovery!.eventStream?.listen((event) {
      final service = event.service;
      switch (event.type) {
        case BonsoirDiscoveryEventType.discoveryServiceFound:
          if (service != null) {
            // logger.info(
            //   '📡 Found server: ${service.name} (${service.attributes['ip'] ?? 'unknown IP'}:${service.port})',
            // );
            logger.info('📡 Found server: ${service.toJson()}');
            // Use id if available, otherwise fallback to name
            final id = service.attributes['id'] ?? service.name;
            final serverInfo = ServerInfo(
              id: id,
              name: service.name,
              host: service.attributes['host'] ?? '',
              port: service.port == 0 ? null : service.port,
              isOnline: true,
            );
            _discoveredServers[id] = serverInfo;
            _discoveryController?.add(_discoveredServers.values.toList());
            service.resolve(_discovery!.serviceResolver);
          }
          break;
        case BonsoirDiscoveryEventType.discoveryServiceLost:
          if (service != null) {
            logger.info('❌ Lost server: ${service.name}');
            _discoveredServers.remove(service.name);
            _discoveryController?.add(_discoveredServers.values.toList());
          }
          break;
        case BonsoirDiscoveryEventType.discoveryServiceResolved:
          logger.info('🔍 Service resolved: ${service?.toJson()}');
          if (service is ResolvedBonsoirService) {
            // Use id if available, otherwise fallback to name
            final id = service.attributes['id'] ?? service.name;
            final updatedServer = ServerInfo(
              id: id,
              name: service.name,
              host: service.host,
              port: service.port == 0 ? null : service.port,
              isOnline: true,
            );
            _discoveredServers[id] = updatedServer;
            _discoveryController?.add(_discoveredServers.values.toList());
          }
          break;
        case BonsoirDiscoveryEventType.discoveryStarted:
          logger.info('🚀 Discovery started');
          break;
        case BonsoirDiscoveryEventType.discoveryStopped:
          logger.info('🛑 Discovery stopped');
          break;
        case BonsoirDiscoveryEventType.discoveryServiceResolveFailed:
          logger.info(
            '❌ Service resolve failed: ${service?.name ?? 'unknown'}',
          );
          break;
        case BonsoirDiscoveryEventType.unknown:
          logger.info(
            '❓ Unknown discovery event for service: ${service?.name ?? 'unknown'}',
          );
          break;
      }
    });

    await _discovery!.start();
    _discoveryController?.add([]); // Emit empty list when ready
    yield* _discoveryController!.stream;
  }

  /// Stop discovery
  void stop() {
    if (state == DiscoveryServiceState.discovering) {
      _discoverySubscription?.cancel();
      _discoverySubscription = null;
      _discoveryController?.close();
      _discoveryController = null;
      _discovery?.stop();
      _discovery = null;
      _discoveredServers.clear();
      state = DiscoveryServiceState.stopped;
    }
  }

  /// Whether discovery is currently running
  bool get isDiscovering => state == DiscoveryServiceState.discovering;
}
