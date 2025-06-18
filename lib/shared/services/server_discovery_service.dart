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

  /// Listens for server signals (broadcast/multicast) to discover available servers
  Stream<ServerInfo> listenForServers() async* {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      _discoveryPort,
    );

    // Join multicast group for better cross-router discovery
    try {
      final multicastGroup = InternetAddress(_multicastAddress);
      socket.joinMulticast(multicastGroup);
      debugPrint('Successfully joined multicast group: $_multicastAddress');
    } catch (e) {
      debugPrint('Warning: Could not join multicast group: $e');
      debugPrint('Discovery will continue with broadcast only...');
    }

    try {
      await for (final event in socket) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
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
      socket.close();
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
    final servers = <String, ServerInfo>{};
    Timer? cleanupTimer;
    StreamSubscription<ServerInfo>? serverSubscription;
    final controller = StreamController<List<ServerInfo>>();

    // Emit empty list initially
    yield <ServerInfo>[];

    try {
      // Start listening for server signals
      serverSubscription = listenForServers().listen(
        (server) {
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
          controller.add(servers.values.toList());
        },
        onError: (error) {
          debugPrint('Error in server discovery: $error');
        },
      );

      // Start periodic cleanup timer
      cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
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
          controller.add(servers.values.toList());
        }
      });

      // Yield the stream of server lists
      yield* controller.stream;
    } finally {
      cleanupTimer?.cancel();
      serverSubscription?.cancel();
      controller.close();
    }
  }
}
