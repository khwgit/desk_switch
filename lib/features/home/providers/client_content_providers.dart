import 'dart:async';

import 'package:collection/collection.dart';
import 'package:desk_switch/core/services/client_service.dart';
import 'package:desk_switch/core/services/discovery_service.dart';
import 'package:desk_switch/core/services/system_service.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_content_providers.g.dart';

// Provider for the list of online servers (future: combine with pins)
@Riverpod(keepAlive: true)
Stream<List<ServerInfo>> servers(Ref ref) async* {
  final discoveryService = ref.watch(discoveryServiceProvider.notifier);
  // final clientService = ref.watch(clientServiceProvider.notifier);
  final systemService = ref.watch(systemServiceProvider.notifier);
  final currentMachineId = await systemService.getMachineId();
  await Future.delayed(const Duration(milliseconds: 100));
  yield* discoveryService.discover().asyncMap((serverList) {
    return Future.value(
      serverList.where((server) => server.id != currentMachineId).toList(),
    );
  });
}

// Notifier for selected server with availability checking
@Riverpod(keepAlive: true)
class SelectedServer extends _$SelectedServer {
  @override
  ServerInfo? build() {
    // Watch the servers stream to check availability
    ref.listen(serversProvider, (previous, next) {
      state = next.when(
        data: (servers) => servers.firstWhereOrNull(
          (server) => server.id == state?.id,
        ),
        loading: () => state, // Keep current state while loading
        error: (error, stackTrace) => null, // Unselect on error
      );
    });

    return null;
  }

  void select(ServerInfo? server) => state = server;
}

@Riverpod(keepAlive: true)
class ConnectedServer extends _$ConnectedServer {
  @override
  ServerInfo? build() {
    final clientService = ref.watch(clientServiceProvider.notifier);
    ref.listen(clientServiceProvider, (previous, next) {
      state = clientService.connectedServer;
    });

    return clientService.connectedServer;
  }
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

// @Riverpod(keepAlive: true)
// class AutoConnectPreferences extends _$AutoConnectPreferences {
//   static const String _prefix = 'auto_connect_';

//   @override
//   Future<Map<String, bool>> build() async {
//     final prefs = await SharedPreferences.getInstance();
//     final keys = prefs.getKeys();
//     final autoConnectKeys = keys.where((key) => key.startsWith(_prefix));

//     final preferences = <String, bool>{};
//     for (final key in autoConnectKeys) {
//       final serverId = key.substring(_prefix.length);
//       preferences[serverId] = prefs.getBool(key) ?? false;
//     }

//     return preferences;
//   }

//   Future<void> setAutoConnect(String serverId, bool enabled) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('$_prefix$serverId', enabled);

//     final currentPreferences = state.value ?? {};
//     state = AsyncValue.data({
//       ...currentPreferences,
//       serverId: enabled,
//     });
//   }

//   Future<bool> getAutoConnect(String serverId) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('$_prefix$serverId') ?? false;
//   }

//   Future<void> removeAutoConnect(String serverId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('$_prefix$serverId');

//     final currentPreferences = state.value ?? {};
//     currentPreferences.remove(serverId);
//     state = AsyncValue.data(Map.from(currentPreferences));
//   }
// }
