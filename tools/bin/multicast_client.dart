import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'app_constants.dart';

void main() async {
  print('Starting DeskSwitch Multicast Test Client...');
  print(
      'Listening for server multicasts on 239.255.255.250:${AppConstants.defaultPort}');

  // Create UDP socket to listen for multicasts
  final socket = await RawDatagramSocket.bind(
    InternetAddress.anyIPv4,
    AppConstants.defaultPort,
  );

  // Use a more reliable multicast address
  final multicastGroup = InternetAddress('239.255.255.250');

  try {
    socket.joinMulticast(multicastGroup);
    print('Successfully joined multicast group: ${multicastGroup.address}');
  } catch (e) {
    print('Warning: Could not join multicast group: $e');
    print('Client will continue listening for broadcasts only...');
  }

  print('Client listening for multicast...');
  print('Press Ctrl+C to stop');

  // Listen for messages
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram == null) return;

      final message = String.fromCharCodes(datagram.data);
      print(
          '\nReceived multicast from ${datagram.address.address}:${datagram.port}');
      print('Message: $message');

      // Parse multicast message
      if (message.startsWith('{')) {
        try {
          final json = jsonDecode(message) as Map<String, dynamic>;
          if (json['type'] == 'DESK_SWITCH_SERVER_MULTICAST') {
            final server = json['server'] as Map<String, dynamic>;
            print('✅ Found DeskSwitch Server (Multicast):');
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
