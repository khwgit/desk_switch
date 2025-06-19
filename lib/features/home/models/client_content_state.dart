import 'package:desk_switch/models/connection.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_content_state.freezed.dart';

@freezed
abstract class ClientContentState with _$ClientContentState {
  const ClientContentState._();
  const factory ClientContentState({
    ServerInfo? selectedServer,
    @Default({}) Set<String> bookmarkedServers,
    Connection? connection,
    @Default(false) bool isDiscoveryRunning,
  }) = _ClientContentState;

  // Computed properties
  bool get isClientRunning => connection is ClientConnection;

  bool isServerConnected(String serverId) {
    final conn = connection;
    if (conn is ClientConnection) {
      return conn.isConnected && conn.connectedServerId == serverId;
    }
    return false;
  }
}
