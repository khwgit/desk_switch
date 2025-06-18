import 'package:desk_switch/shared/models/server_info.dart';
import 'package:desk_switch/shared/services/server_discovery_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final serverDiscoveryServiceProvider = Provider<ServerDiscoveryService>(
  (ref) => ServerDiscoveryService(),
);

final serverDiscoveryProvider = StreamProvider.autoDispose<List<ServerInfo>>((
  ref,
) {
  final service = ref.watch(serverDiscoveryServiceProvider);
  return service.startDiscovery();
});

final serverDiscoveryStateProvider = NotifierProvider(
  ServerDiscoveryNotifier.new,
);

class ServerDiscoveryState {
  const ServerDiscoveryState({
    this.selectedServer,
  });

  final ServerInfo? selectedServer;

  ServerDiscoveryState copyWith({
    ServerInfo? selectedServer,
  }) {
    return ServerDiscoveryState(
      selectedServer: selectedServer ?? this.selectedServer,
    );
  }
}

class ServerDiscoveryNotifier extends Notifier<ServerDiscoveryState> {
  @override
  ServerDiscoveryState build() {
    return const ServerDiscoveryState();
  }

  ServerDiscoveryService get service =>
      ref.read(serverDiscoveryServiceProvider);

  void selectServer(ServerInfo? server) {
    state = state.copyWith(selectedServer: server);
  }
}
