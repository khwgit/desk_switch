import 'dart:async';

import 'package:desk_switch/core/services/discovery_service.dart';
import 'package:desk_switch/core/services/system_service.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_content_providers.g.dart';

// Provider for the list of online servers (future: combine with pins)
@riverpod
Stream<List<ServerInfo>> servers(Ref ref) async* {
  final discoveryService = ref.watch(discoveryServiceProvider.notifier);
  final systemService = ref.watch(systemServiceProvider.notifier);
  final currentMachineId = await systemService.getMachineId();
  final discoveredServers = discoveryService.discover();

  ref.onDispose(() {
    discoveryService.stop();
  });

  await for (final serverList in discoveredServers) {
    // Filter out the current machine from the discovered servers
    final filteredServers = serverList
        .where(
          (server) => server.id != currentMachineId,
        )
        .toList();

    yield filteredServers;
  }
}

// Notifier for selected server with availability checking
@riverpod
class SelectedServer extends _$SelectedServer {
  @override
  ServerInfo? build() {
    // Watch the servers stream to check availability
    ref.listen(serversProvider, (previous, next) {
      state = next.when(
        data: (servers) {
          // Get the current selected server from the previous state
          final currentServer = state;

          // If no server is selected, return null
          if (currentServer == null) return null;

          // Check if the current server is still available and online
          final isStillAvailable = servers.any(
            (server) => server.id == currentServer.id,
          );

          // If server is no longer available, return null (unselect it)
          if (!isStillAvailable) return null;

          // Server is still available, keep it selected
          return currentServer;
        },
        loading: () => state, // Keep current state while loading
        error: (error, stackTrace) => null, // Unselect on error
      );
    });

    return null;
  }

  void select(ServerInfo? server) => state = server;
}

// Notifier for pinned server IDs
@riverpod
class PinnedServers extends _$PinnedServers {
  @override
  Set<String> build() => <String>{};

  void pin(String serverId) {
    state = <String>{...state, serverId};
  }

  void unpin(String serverId) {
    state = <String>{...state}..remove(serverId);
  }

  bool isPinned(String serverId) => state.contains(serverId);
}
