import 'package:desk_switch/core/services/client_service.dart';
import 'package:desk_switch/core/services/server_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_providers.g.dart';

// Provider for whether the server is running
@riverpod
bool serverRunning(Ref ref) {
  final state = ref.watch(serverServiceProvider);
  return state == ServerServiceState.running;
}

@riverpod
ClientServiceState clientState(Ref ref) {
  return ref.watch(clientServiceProvider);
}
