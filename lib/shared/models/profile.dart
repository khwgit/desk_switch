import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Profile model representing a KVM server configuration
@freezed
sealed class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    required Map<String, dynamic> settings,
    required DateTime lastModified,
    @Default(false) bool isActive,
  }) = _Profile;

  factory Profile.create({
    required String name,
    required Map<String, dynamic> settings,
  }) {
    return Profile(
      id: const Uuid().v4(),
      name: name,
      settings: settings,
      lastModified: DateTime.now(),
      isActive: false,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

/// Profile settings keys
class ProfileSettings {
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

/// Extension methods for Profile
extension ProfileX on Profile {
  String get displayName =>
      settings[ProfileSettings.displayName] as String? ?? name;
  String? get networkInterface =>
      settings[ProfileSettings.networkInterface] as String?;
  int get port => settings[ProfileSettings.port] as int? ?? 8080;
  bool get autoStart => settings[ProfileSettings.autoStart] as bool? ?? false;
  bool get securityEnabled =>
      settings[ProfileSettings.securityEnabled] as bool? ?? false;
  String? get password => settings[ProfileSettings.password] as String?;
  List<String> get allowedClients =>
      (settings[ProfileSettings.allowedClients] as List<dynamic>?)
          ?.cast<String>() ??
      [];
  String? get keyboardLayout =>
      settings[ProfileSettings.keyboardLayout] as String?;
  double get mouseSensitivity =>
      (settings[ProfileSettings.mouseSensitivity] as num?)?.toDouble() ?? 1.0;
  String get displayMode =>
      settings[ProfileSettings.displayMode] as String? ?? 'extend';
}
