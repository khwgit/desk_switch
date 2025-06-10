import 'package:desk_switch/shared/models/connection.dart';
import 'package:desk_switch/shared/models/network_config.dart';
import 'package:desk_switch/shared/models/profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'app_state.freezed.dart';

/// Application mode enum
enum AppMode { client, server }

/// Application state
@freezed
sealed class AppState with _$AppState {
  const factory AppState({
    required AppMode mode,
    @Default([]) List<Profile> profiles,
    Profile? activeProfile,
    Connection? currentConnection,
    NetworkConfig? networkConfig,
    @Default(false) bool isInitialized,
    String? error,
  }) = _AppState;

  const AppState._();

  bool get isClientMode => mode == AppMode.client;
  bool get isServerMode => mode == AppMode.server;
  bool get isConnected => currentConnection?.isConnected ?? false;
  bool get isConnecting => currentConnection?.isConnecting ?? false;
  bool get hasError => error != null;
}

/// Application state notifier
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState(mode: AppMode.client));

  /// Switch application mode
  void switchMode(AppMode mode) {
    state = state.copyWith(mode: mode, currentConnection: null, error: null);
  }

  /// Set active profile
  void setActiveProfile(Profile? profile) {
    state = state.copyWith(activeProfile: profile, error: null);
  }

  /// Add a new profile
  void addProfile(Profile profile) {
    state = state.copyWith(profiles: [...state.profiles, profile], error: null);
  }

  /// Update an existing profile
  void updateProfile(Profile profile) {
    final index = state.profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      final updatedProfiles = List<Profile>.from(state.profiles);
      updatedProfiles[index] = profile;
      state = state.copyWith(
        profiles: updatedProfiles,
        activeProfile: state.activeProfile?.id == profile.id
            ? profile
            : state.activeProfile,
        error: null,
      );
    }
  }

  /// Delete a profile
  void deleteProfile(String profileId) {
    state = state.copyWith(
      profiles: state.profiles.where((p) => p.id != profileId).toList(),
      activeProfile: state.activeProfile?.id == profileId
          ? null
          : state.activeProfile,
      error: null,
    );
  }

  /// Set current connection
  void setConnection(Connection? connection) {
    state = state.copyWith(currentConnection: connection, error: null);
  }

  /// Set network configuration
  void setNetworkConfig(NetworkConfig? config) {
    state = state.copyWith(networkConfig: config, error: null);
  }

  /// Set application error
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Mark application as initialized
  void setInitialized(bool initialized) {
    state = state.copyWith(isInitialized: initialized);
  }
}

/// Application state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});
