import 'package:desk_switch/models/client_config.dart';
import 'package:desk_switch/models/connection.dart';
import 'package:desk_switch/models/server_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state.freezed.dart';
part 'app_state.g.dart';

enum AppMode {
  client,
  server,
}

/// Application state
@freezed
abstract class AppState with _$AppState {
  const AppState._();
  const factory AppState({
    @Default(false) bool isInitialized,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Connection? connection,
    @Default(ServerConfig()) ServerConfig serverConfig,
    @Default(ClientConfig()) ClientConfig clientConfig,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  // bool get isClientMode => mode == AppMode.client;
  // bool get isServerMode => mode == AppMode.server;
}

final appStateProvider = Provider<AppState>((ref) {
  return const AppState();
});

class AppStateProvider extends Notifier<AppState> {
  @override
  AppState build() {
    return const AppState();
  }

  void setInitialized([bool initialized = true]) {
    state = state.copyWith(isInitialized: initialized);
  }
}
