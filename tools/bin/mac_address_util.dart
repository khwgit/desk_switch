import 'dart:io';

/// Utility class for creating unique server IDs
class ServerIdUtil {
  /// Creates a unique server ID based on hostname and timestamp
  static String createServerId() {
    try {
      final hostname = Platform.isWindows
          ? Platform.environment['COMPUTERNAME'] ?? 'unknown'
          : Platform.environment['HOSTNAME'] ?? 'unknown';

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final hex = timestamp.toRadixString(16).padLeft(12, '0');

      // Create a unique ID: hostname_timestamp
      return '${hostname.toLowerCase()}_$hex';
    } catch (e) {
      print('Warning: Could not create server ID: $e');
      return _generateFallbackId();
    }
  }

  /// Generates a fallback ID based on current timestamp
  static String _generateFallbackId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hex = timestamp.toRadixString(16).padLeft(12, '0');
    return 'server_$hex';
  }

  /// Alternative method that tries to get a more hardware-based ID
  static Future<String> createHardwareBasedId() async {
    try {
      final interfaces = await NetworkInterface.list();

      // Find the first non-loopback interface
      for (final interface in interfaces) {
        if (interface.name.startsWith('lo') ||
            interface.name.startsWith('docker') ||
            interface.name.startsWith('veth') ||
            interface.name.startsWith('br-')) {
          continue;
        }

        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 &&
              !address.address.startsWith('127.') &&
              !address.address.startsWith('169.254.')) {
            // Use interface name and IP address to create a unique ID
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final hex = timestamp.toRadixString(16).padLeft(8, '0');
            return '${interface.name}_${address.address.replaceAll('.', '')}_$hex';
          }
        }
      }

      // Fallback to hostname-based ID
      return createServerId();
    } catch (e) {
      print('Warning: Could not create hardware-based ID: $e');
      return createServerId();
    }
  }
}
