import 'package:desk_switch/shared/models/client_config.dart';
import 'package:desk_switch/shared/models/connection.dart';
import 'package:desk_switch/shared/models/network_config.dart';
import 'package:desk_switch/shared/models/server_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';

/// Application state
@freezed
abstract class AppState with _$AppState {
  const AppState._();
  const factory AppState({
    Connection? connection,
    ServerConfig? serverConfig,
    ClientConfig? clientConfig,
    NetworkConfig? networkConfig,
    @Default(false) bool isInitialized,
    // String? error,
  }) = _AppState;

  bool get isClientMode => connection is ClientConnection;
  bool get isServerMode => connection is ServerConnection;
  // bool get hasError => error != null;
}
