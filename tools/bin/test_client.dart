import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'app_constants.dart';

void main() async {
  print('Starting DeskSwitch Test Client...');
  print('Listening for server broadcasts on port ${AppConstants.defaultPort}');

  // Create UDP socket to listen for broadcasts
  final socket = await RawDatagramSocket.bind(
    InternetAddress.anyIPv4,
    AppConstants.defaultPort,
  );

  print('Client listening...');
  print('Press Ctrl+C to stop');

  // Listen for messages
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram == null) return;

      final message = String.fromCharCodes(datagram.data);
      print(
          '\nReceived message from ${datagram.address.address}:${datagram.port}');
      print('Message: $message');

      // Parse broadcast message
      if (message.startsWith('{')) {
        try {
          final json = jsonDecode(message) as Map<String, dynamic>;
          if (json['type'] == 'DESK_SWITCH_SERVER_BROADCAST') {
            final server = json['server'] as Map<String, dynamic>;
            print('✅ Found DeskSwitch Server:');
            print('  Name: ${server['name']}');
            print('  ID: ${server['id']}');
            print('  IP: ${server['ipAddress']}');
            print('  Port: ${server['port']}');
            print('  Timestamp: ${json['timestamp']}');
          }
        } catch (e) {
          print('❌ Error parsing JSON: $e');
        }
      }
    }
  });

  // Keep running
  await Future.delayed(const Duration(days: 365));
}
