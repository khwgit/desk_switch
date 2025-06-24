import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

typedef LogFunction =
    void Function(
      dynamic message, {
      Object? error,
      StackTrace? stackTrace,
      DateTime? time,
    });

/// Application-wide logging utility
class AppLogger {
  const AppLogger();

  static final Logger _logger = Logger(
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      noBoxingByDefault: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  LogFunction get trace => _logger.t;
  LogFunction get debug => _logger.d;
  LogFunction get info => _logger.i;
  LogFunction get warning => _logger.w;
  LogFunction get error => _logger.e;
  LogFunction get fatal => _logger.f;

  void Function(
    Level level,
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  })
  get log => _logger.log;
}

const _logger = AppLogger();
AppLogger get logger => _logger;

// mixin LoggerMixin {
//   AppLogger get logger => _logger;
// }
