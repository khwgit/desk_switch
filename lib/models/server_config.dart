import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'server_config.freezed.dart';
part 'server_config.g.dart';

@freezed
abstract class ServerConfig with _$ServerConfig {
  const ServerConfig._();
  const factory ServerConfig({
    ServerProfile? profile,
    @Default([]) List<ServerProfile> profiles,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);
}

/// ServerProfile model representing a KVM server configuration
@freezed
sealed class ServerProfile with _$ServerProfile {
  const factory ServerProfile({
    required String id,
    required String name,
    required Map<String, dynamic> settings,
    required DateTime lastModified,
    @Default(false) bool isActive,
  }) = _ServerProfile;

  factory ServerProfile.create({
    required String name,
    required Map<String, dynamic> settings,
  }) {
    return ServerProfile(
      id: const Uuid().v4(),
      name: name,
      settings: settings,
      lastModified: DateTime.now(),
      isActive: false,
    );
  }

  factory ServerProfile.fromJson(Map<String, dynamic> json) =>
      _$ServerProfileFromJson(json);
}

/// ServerProfile settings keys
class ServerProfileSettings {
  static const String displayName = 'displayName';
  static const String networkInterface = 'networkInterface';
  static const String port = 'port';
  static const String autoStart = 'autoStart';
  static const String securityEnabled = 'securityEnabled';
  static const String password = 'password';
  static const String allowedClients = 'allowedClients';
  static const String keyboardLayout = 'keyboardLayout';
  static const String mouseSensitivity = 'mouseSensitivity';
  static const String displayMode = 'displayMode';
}

/// Extension methods for ServerProfile
extension ServerProfileX on ServerProfile {
  String get displayName =>
      settings[ServerProfileSettings.displayName] as String? ?? name;
  String? get networkInterface =>
      settings[ServerProfileSettings.networkInterface] as String?;
  int get port => settings[ServerProfileSettings.port] as int? ?? 8080;
  bool get autoStart =>
      settings[ServerProfileSettings.autoStart] as bool? ?? false;
  bool get securityEnabled =>
      settings[ServerProfileSettings.securityEnabled] as bool? ?? false;
  String? get password => settings[ServerProfileSettings.password] as String?;
  List<String> get allowedClients =>
      (settings[ServerProfileSettings.allowedClients] as List<dynamic>?)
          ?.cast<String>() ??
      [];
  String? get keyboardLayout =>
      settings[ServerProfileSettings.keyboardLayout] as String?;
  double get mouseSensitivity =>
      (settings[ServerProfileSettings.mouseSensitivity] as num?)?.toDouble() ??
      1.0;
  String get displayMode =>
      settings[ServerProfileSettings.displayMode] as String? ?? 'extend';
}
