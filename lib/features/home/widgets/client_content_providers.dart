import 'dart:async';

import 'package:desk_switch/core/services/client_service.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Notifier for selected server
class SelectedServerNotifier extends Notifier<ServerInfo?> {
  @override
  ServerInfo? build() => null;

  void select(ServerInfo? server) => state = server;
}

final selectedServerProvider =
    NotifierProvider<SelectedServerNotifier, ServerInfo?>(
      SelectedServerNotifier.new,
    );

// Notifier for pinned server IDs
class PinnedServersNotifier extends Notifier<Set<String>> {
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

final pinnedServersProvider =
    NotifierProvider<PinnedServersNotifier, Set<String>>(
      PinnedServersNotifier.new,
    );

// Provider for the list of online servers (future: combine with pins)
final serversProvider = StreamProvider.autoDispose<List<ServerInfo>>((ref) {
  final clientService = ref.read(clientServiceProvider.notifier);
  final pinnedIds = ref.watch(pinnedServersProvider);
  final controller = StreamController<List<ServerInfo>>();
  final serverMap = <String, ServerInfo>{};
  const offlineTimeout = Duration(seconds: 5);

  void emitCombinedServers() {
    final now = DateTime.now();
    // Online discovered servers
    final discovered = serverMap.values.where((s) {
      if (!s.isOnline) return false;
      if (s.lastSeen == null) return true;
      final lastSeen = DateTime.tryParse(s.lastSeen!);
      if (lastSeen == null) return true;
      return now.difference(lastSeen) <= offlineTimeout;
    }).toList();
    // Add all pinned servers (even if not discovered or offline)
    final allServers = <String, ServerInfo>{
      for (final s in discovered) s.id: s,
    };
    for (final id in pinnedIds) {
      if (!allServers.containsKey(id)) {
        final known = serverMap[id];
        if (known != null) {
          // Use last known details, but mark as offline
          allServers[id] = known.copyWith(isOnline: false);
        } else {
          // Placeholder for never-seen pinned server
          allServers[id] = ServerInfo(
            id: id,
            name: 'Pinned Server',
            ipAddress: '',
            port: 0,
            isOnline: false,
          );
        }
      }
    }
    controller.add(allServers.values.toList());
  }

  final sub = clientService.discover().listen((server) {
    serverMap[server.id] = server;
    emitCombinedServers();
  });

  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    emitCombinedServers();
  });

  controller.add([]);

  ref.onDispose(() {
    sub.cancel();
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});
