import 'package:desk_switch/models/server_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_config.freezed.dart';
part 'server_config.g.dart';

@freezed
abstract class ServerConfig with _$ServerConfig {
  const ServerConfig._();
  const factory ServerConfig({
    ServerInfo? profile,
    @Default([]) List<ServerInfo> profiles,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);
}
