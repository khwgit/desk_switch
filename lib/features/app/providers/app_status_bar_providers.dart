import 'package:desk_switch/core/services/client_service.dart';
import 'package:desk_switch/core/services/server_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_status_bar_providers.g.dart';

/// Provider for client service state
@riverpod
ClientServiceState clientServiceState(Ref ref) {
  return ref.watch(clientServiceProvider);
}

/// Provider for server service state
@riverpod
ServerServiceState serverServiceState(Ref ref) {
  return ref.watch(serverServiceProvider);
}

/// Provider for connected server info
@riverpod
String? connectedServerName(Ref ref) {
  final clientService = ref.watch(clientServiceProvider.notifier);
  return clientService.connectedServer?.name;
}

/// Provider for app mode (client/server)
@riverpod
AppMode appMode(Ref ref) {
  final clientState = ref.watch(clientServiceProvider);
  final serverState = ref.watch(serverServiceProvider);

  // Determine mode based on service states
  if (serverState == ServerServiceState.running) {
    return AppMode.server;
  } else if (clientState == ClientServiceState.connected ||
      clientState == ClientServiceState.connecting) {
    return AppMode.client;
  }

  // Default to client mode if no services are active
  return AppMode.client;
}

/// Provider for overall app status
@riverpod
AppStatus appStatus(Ref ref) {
  final clientState = ref.watch(clientServiceProvider);
  final serverState = ref.watch(serverServiceProvider);
  final connectedServer = ref.watch(connectedServerNameProvider);

  return AppStatus(
    mode: ref.watch(appModeProvider),
    clientState: clientState,
    serverState: serverState,
    connectedServerName: connectedServer,
  );
}

/// App status model
class AppStatus {
  const AppStatus({
    required this.mode,
    required this.clientState,
    required this.serverState,
    this.connectedServerName,
  });

  final AppMode mode;
  final ClientServiceState clientState;
  final ServerServiceState serverState;
  final String? connectedServerName;

  bool get isClientMode => mode == AppMode.client;
  bool get isServerMode => mode == AppMode.server;
  bool get isConnected => clientState == ClientServiceState.connected;
  bool get isConnecting => clientState == ClientServiceState.connecting;
  bool get isServerRunning => serverState == ServerServiceState.running;
  bool get isServerStarting => serverState == ServerServiceState.starting;
}

/// App mode enum
enum AppMode {
  client,
  server,
}
