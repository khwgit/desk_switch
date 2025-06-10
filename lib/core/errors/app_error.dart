import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

/// Base error class for the application
@freezed
sealed class AppError with _$AppError {
  const factory AppError.network({
    required String message,
    String? code,
    @Default(false) bool isConnectionError,
  }) = NetworkError;

  const factory AppError.authentication({
    required String message,

    String? code,
  }) = AuthenticationError;

  const factory AppError.permission({
    required String message,
    String? code,
  }) = PermissionError;

  const factory AppError.validation({
    required String message,
    String? code,
    Map<String, String>? fieldErrors,
  }) = ValidationError;

  const factory AppError.unknown({
    required String message,
    String? code,
    dynamic originalError,
  }) = UnknownError;

  const factory AppError.platform({
    required String message,
    String? code,
    String? platform,
  }) = PlatformError;
}

// /// Extension methods for AppError
// extension AppErrorX on AppError {
//   String get userFriendlyMessage {
//     return when(
//       network: (message, _, isConnectionError) => isConnectionError
//           ? 'Connection error: Please check your network connection and try again.'
//           : message,
//       authentication: (message, _) => 'Authentication error: $message',
//       permission: (message, _) => 'Permission error: $message',
//       validation: (message, _, _) => 'Validation error: $message',
//       unknown: (message, _, _) => 'An unexpected error occurred: $message',
//       platform: (message, _, platform) =>
//           'Platform error (${platform ?? 'unknown'}): $message',
//     );
//   }

//   bool get isConnectionError => maybeWhen(
//     network: (_, __, isConnectionError) => isConnectionError,
//     orElse: () => false,
//   );

//   bool get isAuthenticationError =>
//       maybeWhen(authentication: (_, __) => true, orElse: () => false);

//   bool get isPermissionError =>
//       maybeWhen(permission: (_, __) => true, orElse: () => false);

//   bool get isValidationError =>
//       maybeWhen(validation: (_, __, ___) => true, orElse: () => false);

//   bool get isPlatformError =>
//       maybeWhen(platform: (_, __, ___) => true, orElse: () => false);
// }
