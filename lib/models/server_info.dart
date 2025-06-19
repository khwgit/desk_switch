import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_info.freezed.dart';
part 'server_info.g.dart';

@freezed
abstract class ServerInfo with _$ServerInfo {
  const factory ServerInfo({
    required String id,
    required String name,
    required String ipAddress,
    required int port,
    @Default(false) bool isOnline,
    String? lastSeen,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ServerInfo;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
