import 'dart:async';

import 'server_signal_service.dart';

void main() async {
  print('Starting DeskSwitch Simple Test Server...');

  // Create server signal service
  final signalService = await createServerSignalService(
    name: 'Test Server (Simple)',
    useMulticast: false, // Only broadcast
    useBroadcast: true,
    useHardwareId: true, // Use hardware-based ID
  );

  print('Server Info:');
  print('  ID: ${signalService.currentServerInfo.id}');
  print('  Name: ${signalService.currentServerInfo.name}');
  print('  IP: ${signalService.currentServerInfo.ipAddress}');
  print('  Port: ${signalService.currentServerInfo.port}');
  print('  Discovery Port: 8080');

  try {
    // Start sending server signals
    await signalService.start();

    print('\n📡 Broadcasting server presence...');
    print('Press Ctrl+C to stop the server');

    // Keep the program running
    await Future.delayed(const Duration(days: 365));
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    await signalService.stop();
  }
}
