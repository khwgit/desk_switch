import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_config.freezed.dart';
part 'network_config.g.dart';

/// Network configuration model for server mode
@freezed
sealed class NetworkConfig with _$NetworkConfig {
  const factory NetworkConfig({
    required String interface,
    required String ipAddress,
    required int port,
    @Default(true) bool autoDetect,
    @Default([]) List<String> allowedClients,
    @Default(false) bool securityEnabled,
    String? password,
  }) = _NetworkConfig;

  factory NetworkConfig.defaultConfig({
    required String interface,
    required String ipAddress,
  }) {
    return NetworkConfig(
      interface: interface,
      ipAddress: ipAddress,
      port: 8080,
      autoDetect: true,
      allowedClients: [],
      securityEnabled: false,
    );
  }

  factory NetworkConfig.fromJson(Map<String, dynamic> json) =>
      _$NetworkConfigFromJson(json);
}

/// Extension methods for NetworkConfig
extension NetworkConfigX on NetworkConfig {
  String get displayName => '$ipAddress:$port';

  bool get hasSecurity =>
      securityEnabled && password != null && password!.isNotEmpty;

  bool isClientAllowed(String clientIp) {
    if (allowedClients.isEmpty) return true;
    return allowedClients.contains(clientIp);
  }

  NetworkConfig copyWithSecurity({bool? securityEnabled, String? password}) {
    return copyWith(
      securityEnabled: securityEnabled ?? this.securityEnabled,
      password: password ?? this.password,
    );
  }

  NetworkConfig copyWithAllowedClients(List<String> clients) {
    return copyWith(allowedClients: clients);
  }
}
