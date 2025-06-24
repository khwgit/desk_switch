import 'dart:async';

import 'package:desk_switch/core/services/client_service.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_content_providers.g.dart';

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
@riverpod
Stream<List<ServerInfo>> servers(Ref ref) {
  final clientService = ref.watch(clientServiceProvider.notifier);
  // final pinnedIds = ref.watch(pinnedServersProvider);
  return clientService.discover();
}
