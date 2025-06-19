import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_connection.freezed.dart';

@freezed
abstract class ClientConnection with _$ClientConnection {
  const factory ClientConnection({
    required String id,
  }) = _ClientConnection;
}
