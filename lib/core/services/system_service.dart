import 'dart:io';

import 'package:desk_switch/core/utils/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_service.g.dart';

enum SystemServiceState {
  initializing,
  ready,
}

/// System service for getting machine-specific information
///
/// Usage:
/// ```dart
/// // In a widget
/// final machineId = ref.watch(systemServiceProvider);
///
/// // Or call the method directly
/// final systemService = ref.read(systemServiceProvider.notifier);
/// final id = await systemService.getMachineId();
/// ```
@Riverpod(keepAlive: true)
class SystemService extends _$SystemService {
  String? _cachedMachineId;

  @override
  SystemServiceState build() {
    return SystemServiceState.ready;
  }

  /// Get a unique machine identifier
  Future<String> getMachineId() async {
    return _cachedMachineId ??= await _generateMachineId();
  }

  Future<String> _generateMachineId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isMacOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        return macOsInfo.systemGUID ?? macOsInfo.computerName;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.machineId ?? linuxInfo.name;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? iosInfo.name;
      }
    } catch (e) {
      logger.error('Error getting device info: $e');
    }

    return await _getFallbackId();
  }

  Future<String> _getFallbackId() async {
    // Fallback to hostname + timestamp
    final hostname = Platform.localHostname;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${hostname}_$timestamp';
  }
}
