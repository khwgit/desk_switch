import 'dart:async';

import 'server_signal_service.dart';

void main() async {
  print('Starting DeskSwitch Multicast Test Server...');

  // Create server signal service with hardware-based ID
  final signalService = await createServerSignalService(
    name: 'Test Server (Multicast)',
    useMulticast: true,
    useBroadcast: true,
    useHardwareId: true, // Use hardware-based ID instead of UUID
  );

  print('Server Info:');
  print('  ID: ${signalService.currentServerInfo.id}');
  print('  Name: ${signalService.currentServerInfo.name}');
  print('  IP: ${signalService.currentServerInfo.ipAddress}');
  print('  Port: ${signalService.currentServerInfo.port}');
  print('  Multicast Group: 239.255.255.250:8080');

  try {
    // Start sending server signals
    await signalService.start();

    print('\n📡 Multicasting server presence...');
    print('Press Ctrl+C to stop the server');

    // Keep the program running
    await Future.delayed(const Duration(days: 365));
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    await signalService.stop();
  }
}
