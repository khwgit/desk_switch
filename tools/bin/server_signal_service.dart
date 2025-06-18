import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'app_constants.dart';
import 'mac_address_util.dart';
import 'server_info.dart';

/// Service for sending server signals to be discovered by clients
class ServerSignalService {
  static const _discoveryPort = AppConstants.defaultPort;
  static const _multicastAddress = '239.255.255.250';
  static const _broadcastAddress = '255.255.255.255';

  final ServerInfo serverInfo;
  final Duration signalInterval;
  final bool useMulticast;
  final bool useBroadcast;

  RawDatagramSocket? _socket;
  Timer? _signalTimer;
  bool _isRunning = false;

  ServerSignalService({
    required this.serverInfo,
    this.signalInterval = const Duration(seconds: 2),
    this.useMulticast = true,
    this.useBroadcast = true,
  });

  /// Starts sending server signals
  Future<void> start() async {
    if (_isRunning) return;

    try {
      // Create UDP socket for sending signals
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0, // Let the system choose a port for sending
      );

      if (useMulticast) {
        _socket!.broadcastEnabled = true;
      }

      _isRunning = true;

      // Start periodic signal sending
      _signalTimer = Timer.periodic(signalInterval, (timer) {
        _sendServerSignal();
      });

      print('✅ Server signal service started');
      print('   Signal interval: ${signalInterval.inSeconds}s');
      print('   Multicast: ${useMulticast ? 'enabled' : 'disabled'}');
      print('   Broadcast: ${useBroadcast ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('❌ Error starting server signal service: $e');
      rethrow;
    }
  }

  /// Stops sending server signals
  Future<void> stop() async {
    if (!_isRunning) return;

    _signalTimer?.cancel();
    _signalTimer = null;
    _socket?.close();
    _socket = null;
    _isRunning = false;

    print('🛑 Server signal service stopped');
  }

  /// Sends a server signal (broadcast and/or multicast)
  void _sendServerSignal() {
    if (!_isRunning || _socket == null) return;

    try {
      final signalMessage = _createSignalMessage();
      final message = jsonEncode(signalMessage);
      final data = message.codeUnits;

      // Send broadcast signal
      if (useBroadcast) {
        _socket!.send(
          data,
          InternetAddress(_broadcastAddress),
          _discoveryPort,
        );
      }

      // Send multicast signal
      if (useMulticast) {
        _socket!.send(
          data,
          InternetAddress(_multicastAddress),
          _discoveryPort,
        );
      }

      print(
          '📡 Sent server signal: ${serverInfo.name} (${serverInfo.ipAddress}:${serverInfo.port})');
    } catch (e) {
      print('❌ Error sending server signal: $e');
    }
  }

  /// Creates a server signal message
  Map<String, dynamic> _createSignalMessage() {
    return {
      'type': useMulticast
          ? 'DESK_SWITCH_SERVER_MULTICAST'
          : 'DESK_SWITCH_SERVER_BROADCAST',
      'server': serverInfo.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Gets the current server info
  ServerInfo get currentServerInfo => serverInfo;

  /// Checks if the service is running
  bool get isRunning => _isRunning;
}

/// Factory function to create a server signal service with common configurations
Future<ServerSignalService> createServerSignalService({
  required String name,
  String? ipAddress,
  int? port,
  Duration? signalInterval,
  bool useMulticast = true,
  bool useBroadcast = true,
  bool useHardwareId = false,
}) async {
  final serverId = useHardwareId
      ? await ServerIdUtil.createHardwareBasedId()
      : ServerIdUtil.createServerId();

  final serverInfo = ServerInfo(
    id: serverId,
    name: name,
    ipAddress: ipAddress ?? '127.0.0.1',
    port: port ?? AppConstants.defaultPort,
    isOnline: true,
    lastSeen: DateTime.now().toIso8601String(),
  );

  return ServerSignalService(
    serverInfo: serverInfo,
    signalInterval: signalInterval ?? const Duration(seconds: 2),
    useMulticast: useMulticast,
    useBroadcast: useBroadcast,
  );
}
