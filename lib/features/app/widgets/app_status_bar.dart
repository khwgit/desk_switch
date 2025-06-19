import 'package:desk_switch/core/states/app_state.dart';
import 'package:desk_switch/models/connection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppStatusBar extends HookConsumerWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(
      appStateProvider.select(
        (state) => state.connection,
      ),
    );
    final theme = Theme.of(context);

    // Determine status
    String statusText = 'Not Running';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pause_circle_filled;

    switch (connection) {
      case ClientConnection():
        if (connection.isConnected) {
          // statusText =
          //     'Connected to '
          //     '${connection.serverIp}${connection.settings['hostName'] != null ? ' (${connection.settings['hostName']})' : ''}';
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
        } else if (connection.isConnecting) {
          statusText = 'Connecting';
          statusColor = Colors.orange;
          statusIcon = Icons.sync;
        } else {
          statusText = 'Not Running';
          statusColor = Colors.grey;
          statusIcon = Icons.pause_circle_filled;
        }
        break;
      case ServerConnection():
        statusText = 'Running';
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_fill;
        break;
      case null:
        statusText = 'Not Running';
        statusColor = Colors.grey;
        statusIcon = Icons.pause_circle_filled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status indicator icon
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          // Status text
          Text(
            statusText,
            style: theme.textTheme.bodyMedium?.copyWith(color: statusColor),
          ),
          const SizedBox(width: 16),
          // // IP addresses
          // if (appState.networkConfig != null) ...[
          //   const Icon(Icons.network_check, size: 16),
          //   const SizedBox(width: 4),
          //   Text(
          //     appState.networkConfig!.ipAddress,
          //     style: theme.textTheme.bodyMedium,
          //   ),
          // ],
        ],
      ),
    );
  }
}
