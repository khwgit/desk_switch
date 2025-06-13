import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection.freezed.dart';

/// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// Connection type enum
enum ConnectionType {
  client,
  server,
}

/// Connection model representing a client-server connection
@freezed
sealed class Connection with _$Connection {
  /// Client connection
  const factory Connection.client({
    required String id,
    @Default(ConnectionStatus.disconnected) ConnectionStatus status,
  }) = ClientConnection;

  /// Server connection
  const factory Connection.server({
    required String id,
  }) = ServerConnection;

  ConnectionType get type;
}

@freezed
abstract class ClientConnection with _$ClientConnection implements Connection {
  const ClientConnection._();
  const factory ClientConnection({
    required String id,
    @Default(ConnectionStatus.disconnected) ConnectionStatus status,
  }) = _ClientConnection;

  @override
  ConnectionType get type => ConnectionType.client;

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isConnecting => status == ConnectionStatus.connecting;
  bool get isDisconnected => status == ConnectionStatus.disconnected;
  bool get isDisconnecting => status == ConnectionStatus.disconnecting;
  bool get isError => status == ConnectionStatus.error;
}

@freezed
abstract class ServerConnection with _$ServerConnection implements Connection {
  const ServerConnection._();
  const factory ServerConnection({
    required String id,
  }) = _ServerConnection;

  @override
  ConnectionType get type => ConnectionType.server;
}
