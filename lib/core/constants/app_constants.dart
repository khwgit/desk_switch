import 'package:flutter/foundation.dart';

/// Application-wide constants
class AppConstants {
  // Network
  static const int defaultPort = 12345;
  static const int maxReconnectionAttempts = 3;

  // Platform
  static final bool isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
  static final bool isWindows = defaultTargetPlatform == TargetPlatform.windows;

  // Storage
  static const String storageProfilesKey = 'profiles';
  static const String storageSettingsKey = 'settings';
  static const String storageNetworkConfigKey = 'network_config';
}
