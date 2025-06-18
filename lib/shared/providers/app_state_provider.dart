import 'package:desk_switch/shared/models/app_state.dart';
import 'package:desk_switch/shared/models/connection.dart';
import 'package:desk_switch/shared/models/server_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

final appStateProvider = NotifierProvider(AppStateNotifier.new);

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return const AppState();
  }

  void startClient() {
    state = state.copyWith(
      connection: ClientConnection(id: const Uuid().v4()),
    );
  }

  void connectToServer(String serverId) {
    // Ensure client is started first
    if (state.connection is! ClientConnection) {
      startClient();
    }

    if (state.connection is ClientConnection) {
      final clientConnection = state.connection as ClientConnection;
      state = state.copyWith(
        connection: clientConnection.copyWith(
          status: ConnectionStatus.connected,
          connectedServerId: serverId,
        ),
      );
    }
  }

  void stopClient() {
    if (state.connection is ClientConnection) {
      final clientConnection = state.connection as ClientConnection;
      state = state.copyWith(
        connection: clientConnection.copyWith(
          status: ConnectionStatus.disconnected,
          connectedServerId: null,
        ),
      );
    }
  }

  void startServer() {
    state = state.copyWith(
      connection: ServerConnection(id: const Uuid().v4()),
    );
  }

  void stopServer() {}

  void setActiveProfile(ServerProfile? profile) {
    // For editing, not running
  }

  // void addProfile(ServerProfile profile) {
  //   state = state.copyWith(profiles: [...state.profiles, profile], error: null);
  // }

  // void updateProfile(ServerProfile profile) {
  //   final index = state.profiles.indexWhere((p) => p.id == profile.id);
  //   if (index != -1) {
  //     final updatedProfiles = List<ServerProfile>.from(state.profiles);
  //     updatedProfiles[index] = profile;
  //     state = state.copyWith(
  //       profiles: updatedProfiles,
  //       error: null,
  //     );
  //   }
  // }

  // void deleteProfile(String profileId) {
  //   state = state.copyWith(
  //     profiles: state.profiles.where((p) => p.id != profileId).toList(),
  //     error: null,
  //   );
  // }

  // void setNetworkConfig(NetworkConfig? config) {
  //   state = state.copyWith(networkConfig: config, error: null);
  // }

  // void setError(String? error) {
  //   state = state.copyWith(error: error);
  // }

  void setInitialized(bool initialized) {
    state = state.copyWith(isInitialized: initialized);
  }
}
