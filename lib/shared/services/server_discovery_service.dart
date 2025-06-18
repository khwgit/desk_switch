import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desk_switch/shared/models/server_info.dart';
import 'package:flutter/foundation.dart';

class ServerDiscoveryService {
  static const _discoveryPort = 12345;
  static const _discoveryTimeout = Duration(seconds: 5);
  static const _cleanupInterval = Duration(seconds: 2);
  static const _multicastAddress = '239.255.255.250';

  StreamSubscription<ServerInfo>? _activeSubscription;
  Timer? _cleanupTimer;
  StreamController<List<ServerInfo>>? _controller;
  RawDatagramSocket? _socket;
  bool _isRunning = false;

  /// Listens for server signals (broadcast/multicast) to discover available servers
  Stream<ServerInfo> listenForServers() async* {
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      _discoveryPort,
    );

    // Join multicast group for better cross-router discovery
    try {
      final multicastGroup = InternetAddress(_multicastAddress);
      _socket!.joinMulticast(multicastGroup);
      debugPrint('Successfully joined multicast group: $_multicastAddress');
    } catch (e) {
      debugPrint('Warning: Could not join multicast group: $e');
      debugPrint('Discovery will continue with broadcast only...');
    }

    try {
      await for (final event in _socket!) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram == null) continue;

          final message = String.fromCharCodes(datagram.data);
          debugPrint(
            'Received server signal from ${datagram.address.address}: $message',
          );

          // Handle server broadcast signals
          if (message.startsWith('{')) {
            try {
              final serverInfo = _parseServerSignal(
                message,
                datagram.address.address,
              );
              if (serverInfo != null) {
                yield serverInfo;
              }
            } catch (e) {
              debugPrint('Error parsing server signal: $e');
            }
          }
        }
      }
    } finally {
      // Don't close socket here as it's managed by stopDiscovery
      // _socket!.close();
    }
  }

  /// Parses a server signal message into a ServerInfo object
  ServerInfo? _parseServerSignal(String message, String ipAddress) {
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;

      // Check if this is a DeskSwitch server signal
      final messageType = json['type'] as String?;
      if (messageType != 'DESK_SWITCH_SERVER_BROADCAST' &&
          messageType != 'DESK_SWITCH_SERVER_MULTICAST') {
        return null;
      }

      final serverJson = json['server'] as Map<String, dynamic>;

      return ServerInfo(
        id: serverJson['id'] as String,
        name: serverJson['name'] as String,
        ipAddress: serverJson['ipAddress'] as String,
        port: serverJson['port'] as int,
        isOnline: true,
        lastSeen: DateTime.now().toIso8601String(),
        metadata: Map<String, dynamic>.from(serverJson['metadata'] ?? {}),
      );
    } catch (e) {
      debugPrint('Error parsing server signal: $e');
      return null;
    }
  }

  /// Starts listening for server signals and manages server list
  Stream<List<ServerInfo>> startDiscovery() async* {
    // Stop any existing discovery session
    stopDiscovery();

    final servers = <String, ServerInfo>{};
    _controller = StreamController<List<ServerInfo>>();
    _isRunning = true;

    debugPrint('Starting server discovery...');

    // Emit empty list initially
    yield <ServerInfo>[];

    try {
      // Start listening for server signals
      _activeSubscription = listenForServers().listen(
        (server) {
          if (!_isRunning) return; // Don't process if stopped

          // Check if this server already exists
          final existingServer = servers[server.id];
          if (existingServer != null) {
            // Update existing server with new online status and lastSeen
            servers[server.id] = existingServer.copyWith(
              isOnline: true,
              lastSeen: server.lastSeen,
              // Preserve other fields from existing server (name, ipAddress, port, metadata)
              name: server.name,
              ipAddress: server.ipAddress,
              port: server.port,
              metadata: server.metadata,
            );
          } else {
            // Add new server
            servers[server.id] = server;
          }
          _controller?.add(servers.values.toList());
        },
        onError: (error) {
          debugPrint('Error in server discovery: $error');
          _controller?.addError(error);
        },
      );

      // Start periodic cleanup timer
      _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
        if (!_isRunning) return; // Don't process if stopped

        final now = DateTime.now();
        bool hasChanges = false;

        // Check for offline servers
        for (final entry in servers.entries) {
          final server = entry.value;
          if (server.lastSeen != null) {
            final lastSeen = DateTime.parse(server.lastSeen!);
            if (now.difference(lastSeen) > _discoveryTimeout &&
                server.isOnline) {
              servers[entry.key] = server.copyWith(isOnline: false);
              hasChanges = true;
            }
          }
        }

        // Emit updated list if there were changes
        if (hasChanges) {
          _controller?.add(servers.values.toList());
        }
      });

      // Yield the stream of server lists
      yield* _controller!.stream;
    } finally {
      if (_isRunning) {
        stopDiscovery();
      }
    }
  }

  /// Stops the current discovery session and cleans up resources
  void stopDiscovery() {
    if (!_isRunning) return;

    debugPrint('Stopping server discovery...');
    _isRunning = false;

    _activeSubscription?.cancel();
    _activeSubscription = null;

    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    _controller?.close();
    _controller = null;

    // Leave multicast group and close socket
    if (_socket != null) {
      try {
        final multicastGroup = InternetAddress(_multicastAddress);
        _socket!.leaveMulticast(multicastGroup);
        debugPrint('Left multicast group: $_multicastAddress');
      } catch (e) {
        debugPrint('Warning: Could not leave multicast group: $e');
      }
      _socket!.close();
      _socket = null;
    }

    debugPrint('Server discovery stopped');
  }

  /// Checks if discovery is currently running
  bool get isRunning => _isRunning;
}
