import 'package:flutter/foundation.dart';

/// Application-wide constants
class AppConstants {
  // Application
  static const String appName = 'DeskSwitch';
  static const String appVersion = '0.1.0';

  // Network
  static const int defaultPort = 8080;
  static const int connectionTimeout = 5000; // milliseconds
  static const int maxReconnectionAttempts = 3;

  // Platform
  static final bool isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
  static final bool isWindows = defaultTargetPlatform == TargetPlatform.windows;

  // Window
  static const double defaultWindowWidth = 1024.0;
  static const double defaultWindowHeight = 768.0;
  static const double minWindowWidth = 800.0;
  static const double minWindowHeight = 600.0;

  // Routes
  static const String routeHome = '/';
  static const String routeClient = '/client';
  static const String routeClientConnect = '/client/connect';
  static const String routeClientSettings = '/client/settings';
  static const String routeServer = '/server';
  static const String routeServerProfiles = '/server/profiles';
  static const String routeServerNetwork = '/server/network';
  static const String routeServerClients = '/server/clients';

  // Storage
  static const String storageProfilesKey = 'profiles';
  static const String storageSettingsKey = 'settings';
  static const String storageNetworkConfigKey = 'network_config';

  // Security
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration connectionTimeoutDuration = Duration(seconds: 5);
}
