import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_info.freezed.dart';
part 'client_info.g.dart';

@freezed
abstract class ClientInfo with _$ClientInfo {
  const ClientInfo._();
  const factory ClientInfo({
    required String id,
    required String name,
    int? port,
    @Default(false) bool isActive,
    @JsonKey(includeToJson: false, includeFromJson: false) WebSocket? socket,
  }) = _ClientInfo;

  factory ClientInfo.fromJson(Map<String, dynamic> json) =>
      _$ClientInfoFromJson(json);
}
