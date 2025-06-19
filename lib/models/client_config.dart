import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_config.freezed.dart';
part 'client_config.g.dart';

@freezed
abstract class ClientConfig with _$ClientConfig {
  const ClientConfig._();
  const factory ClientConfig() = _ClientConfig;

  factory ClientConfig.fromJson(Map<String, dynamic> json) =>
      _$ClientConfigFromJson(json);
}

// /// Connection status enum
// enum ConnectionStatus {
//   disconnected,
//   connecting,
//   connected,
//   disconnecting,
//   error,
// }

// /// Connection model representing a client-server connection
// @freezed
// abstract class Connection with _$Connection {
//   const factory Connection({
//     required String id,
//     required String serverIp,
//     required int port,
//     required ConnectionStatus status,
//     required DateTime connectedAt,
//     required Map<String, dynamic> settings,
//     String? errorMessage,
//   }) = _Connection;

//   factory Connection.create({
//     required String serverIp,
//     required int port,
//     required Map<String, dynamic> settings,
//   }) {
//     return Connection(
//       id: const Uuid().v4(),
//       serverIp: serverIp,
//       port: port,
//       status: ConnectionStatus.disconnected,
//       connectedAt: DateTime.now(),
//       settings: settings,
//     );
//   }

//   factory Connection.fromJson(Map<String, dynamic> json) =>
//       _$ConnectionFromJson(json);
// }

// /// Connection settings keys
// class ConnectionSettings {
//   static const String displayMode = 'displayMode';
//   static const String keyboardLayout = 'keyboardLayout';
//   static const String mouseSensitivity = 'mouseSensitivity';
//   static const String autoReconnect = 'autoReconnect';
//   static const String reconnectAttempts = 'reconnectAttempts';
//   static const String reconnectDelay = 'reconnectDelay';
//   static const String securityEnabled = 'securityEnabled';
//   static const String password = 'password';
// }

// /// Extension methods for Connection
// extension ConnectionX on Connection {
//   String get displayMode =>
//       settings[ConnectionSettings.displayMode] as String? ?? 'extend';
//   String? get keyboardLayout =>
//       settings[ConnectionSettings.keyboardLayout] as String?;
//   double get mouseSensitivity =>
//       (settings[ConnectionSettings.mouseSensitivity] as num?)?.toDouble() ??
//       1.0;
//   bool get autoReconnect =>
//       settings[ConnectionSettings.autoReconnect] as bool? ?? true;
//   int get reconnectAttempts =>
//       settings[ConnectionSettings.reconnectAttempts] as int? ?? 3;
//   int get reconnectDelay =>
//       settings[ConnectionSettings.reconnectDelay] as int? ?? 5000;
//   bool get securityEnabled =>
//       settings[ConnectionSettings.securityEnabled] as bool? ?? false;
//   String? get password => settings[ConnectionSettings.password] as String?;

//   bool get isConnected => status == ConnectionStatus.connected;
//   bool get isConnecting => status == ConnectionStatus.connecting;
//   bool get isDisconnected => status == ConnectionStatus.disconnected;
//   bool get isDisconnecting => status == ConnectionStatus.disconnecting;
//   bool get hasError => status == ConnectionStatus.error;

//   String get statusText {
//     switch (status) {
//       case ConnectionStatus.connected:
//         return 'Connected';
//       case ConnectionStatus.connecting:
//         return 'Connecting...';
//       case ConnectionStatus.disconnected:
//         return 'Disconnected';
//       case ConnectionStatus.disconnecting:
//         return 'Disconnecting...';
//       case ConnectionStatus.error:
//         return 'Error: ${errorMessage ?? 'Unknown error'}';
//     }
//   }
// }
