import 'package:desk_switch/shared/models/connection.dart';
import 'package:desk_switch/shared/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppStatusBar extends HookConsumerWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final isClientMode = appState.isClientMode;
    final theme = Theme.of(context);

    // Determine status
    String statusText = 'Not Running';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pause_circle_filled;

    if (isClientMode) {
      final conn = appState.currentConnection;
      if (conn != null) {
        if (conn.isConnected) {
          statusText =
              'Connected to '
              '${conn.serverIp}${conn.settings['hostName'] != null ? ' (${conn.settings['hostName']})' : ''}';
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
        } else if (conn.isConnecting) {
          statusText = 'Connecting';
          statusColor = Colors.orange;
          statusIcon = Icons.sync;
        } else {
          statusText = 'Not Running';
          statusColor = Colors.grey;
          statusIcon = Icons.pause_circle_filled;
        }
      }
    } else {
      // Server mode
      if (appState.activeProfile != null) {
        statusText = 'Running';
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_fill;
      } else {
        statusText = 'Not Running';
        statusColor = Colors.grey;
        statusIcon = Icons.pause_circle_filled;
      }
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
          // IP addresses
          if (appState.networkConfig != null) ...[
            const Icon(Icons.network_check, size: 16),
            const SizedBox(width: 4),
            Text(
              appState.networkConfig!.ipAddress,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
