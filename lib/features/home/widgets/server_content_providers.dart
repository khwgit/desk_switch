import 'package:desk_switch/core/services/server_service.dart';
import 'package:desk_switch/core/services/system_service.dart';
import 'package:desk_switch/models/client_info.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:desk_switch/core/services/broadcast_service.dart';
export 'package:desk_switch/core/services/server_service.dart';

part 'server_content_providers.g.dart';

// Provider for clients
@riverpod
Stream<List<ClientInfo>> clients(Ref ref) async* {
  final serverService = ref.watch(serverServiceProvider.notifier);
  yield serverService.currentClients;
  yield* serverService.clients();
}

// Provider for whether the server is running
@riverpod
bool serverRunning(Ref ref) {
  final state = ref.watch(serverServiceProvider);
  return state == ServerServiceState.running;
}

// Provider for server name state
@riverpod
class ServerProfile extends _$ServerProfile {
  @override
  Future<ServerInfo> build() async {
    final systemService = ref.watch(systemServiceProvider.notifier);
    return ServerInfo(
      id: await systemService.getMachineId(),
      name: await systemService.getMachineName(),
      // host: 'localhost',
      port: 8080,
      isOnline: false,
    );
  }
}

// Provider for port configuration state
@riverpod
class PortConfiguration extends _$PortConfiguration {
  @override
  ({bool isAuto, int? manualPort, int? currentPort}) build() {
    return (isAuto: true, manualPort: 8080, currentPort: null);
  }

  void setAutoMode(bool isAuto) {
    state = (
      isAuto: isAuto,
      manualPort: state.manualPort,
      currentPort: state.currentPort,
    );
  }

  void setManualPort(int port) {
    state = (
      isAuto: state.isAuto,
      manualPort: port,
      currentPort: state.currentPort,
    );
  }

  void setCurrentPort(int? port) {
    state = (
      isAuto: state.isAuto,
      manualPort: state.manualPort,
      currentPort: port,
    );
  }
}

// Provider for monitor configuration
@riverpod
class MonitorConfiguration extends _$MonitorConfiguration {
  @override
  List<({String name, String resolution, bool enabled})> build() {
    return [
      (name: 'Primary Display', resolution: '1920x1080', enabled: true),
      (name: 'Secondary Display', resolution: '2560x1440', enabled: true),
      (name: 'External Monitor', resolution: '1366x768', enabled: false),
    ];
  }

  void toggleMonitor(int index) {
    // final monitors = List.from(state);
    // monitors[index] = (
    //   name: monitors[index].name,
    //   resolution: monitors[index].resolution,
    //   enabled: !monitors[index].enabled,
    // );
    // state = monitors;
  }

  void refreshMonitors() {
    // TODO: Implement actual monitor detection
    // For now, just keep the current state
  }
}
