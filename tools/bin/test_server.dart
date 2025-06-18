import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import 'app_constants.dart';
import 'server_info.dart';

void main() async {
  print('Starting DeskSwitch Test Server...');

  // Create a server info
  final serverInfo = ServerInfo(
    id: const Uuid().v4(),
    name: 'Test Server',
    ipAddress: '127.0.0.1',
    port: AppConstants.defaultPort,
    isOnline: true,
    lastSeen: DateTime.now().toIso8601String(),
  );

  print('Server Info:');
  print('  ID: ${serverInfo.id}');
  print('  Name: ${serverInfo.name}');
  print('  IP: ${serverInfo.ipAddress}');
  print('  Port: ${serverInfo.port}');
  print('  Discovery Port: ${AppConstants.defaultPort}');

  // Get all network interfaces
  final interfaces = await NetworkInterface.list();
  print('\nAvailable network interfaces:');
  for (final interface in interfaces) {
    print(
        '  ${interface.name}: ${interface.addresses.map((a) => a.address).join(', ')}');
  }

  // Create UDP socket for broadcasting
  final broadcastSocket = await RawDatagramSocket.bind(
    InternetAddress.anyIPv4,
    0, // Let the system choose a port for broadcasting
  );
  broadcastSocket.broadcastEnabled = true;

  print('\nBroadcasting server presence...');
  print('Press Ctrl+C to stop the server');

  // Start periodic broadcasting
  Timer.periodic(const Duration(seconds: 2), (timer) {
    _broadcastServerPresence(broadcastSocket, serverInfo, interfaces);
  });

  // Keep the program running
  await Future.delayed(const Duration(days: 365));
}

void _broadcastServerPresence(RawDatagramSocket socket, ServerInfo serverInfo,
    List<NetworkInterface> interfaces) {
  try {
    // Create broadcast message
    final broadcastMessage = {
      'type': 'DESK_SWITCH_SERVER_BROADCAST',
      'server': serverInfo.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    final message = jsonEncode(broadcastMessage);
    final data = message.codeUnits;

    // Broadcast to all network interfaces
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4) {
          try {
            // Get the broadcast address for this interface
            final broadcastAddress = _getBroadcastAddress(address);
            if (broadcastAddress != null) {
              socket.send(
                data,
                broadcastAddress,
                AppConstants.defaultPort,
              );
              print(
                  'Broadcasted to ${interface.name} (${broadcastAddress.address})');
            }
          } catch (e) {
            print('Error broadcasting to ${interface.name}: $e');
          }
        }
      }
    }

    print(
        'Broadcasted server presence: ${serverInfo.name} (${serverInfo.ipAddress}:${serverInfo.port})');
  } catch (e) {
    print('Error broadcasting: $e');
  }
}

InternetAddress? _getBroadcastAddress(InternetAddress address) {
  try {
    // For localhost, use the loopback broadcast
    if (address.address == '127.0.0.1') {
      return InternetAddress('127.255.255.255');
    }

    // For other addresses, try to construct broadcast address
    final parts = address.address.split('.');
    if (parts.length == 4) {
      // Assume /24 subnet (common for home networks)
      return InternetAddress('${parts[0]}.${parts[1]}.${parts[2]}.255');
    }

    // Fallback to general broadcast
    return InternetAddress('255.255.255.255');
  } catch (e) {
    print('Error getting broadcast address for ${address.address}: $e');
    return null;
  }
}
