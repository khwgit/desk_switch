import 'package:desk_switch/features/app/widgets/app_status_bar_providers.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppStatusBar extends HookConsumerWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStatus = ref.watch(appStatusProvider);
    final theme = Theme.of(context);

    // Determine status
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (appStatus.isServerMode) {
      if (appStatus.isServerRunning) {
        statusText = 'Server Running';
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_fill;
      } else if (appStatus.isServerStarting) {
        statusText = 'Starting Server...';
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
      } else {
        statusText = 'Server Stopped';
        statusColor = Colors.grey;
        statusIcon = Icons.pause_circle_filled;
      }
    } else {
      // Client mode
      if (appStatus.isConnected) {
        statusText =
            'Connected to ${appStatus.connectedServerName ?? "Unknown Server"}';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      } else if (appStatus.isConnecting) {
        statusText = 'Connecting...';
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
      } else {
        statusText = 'Not Connected';
        statusColor = Colors.grey;
        statusIcon = Icons.pause_circle_filled;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
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
          const Gap(12),
          // Status indicator icon
          Icon(statusIcon, color: statusColor, size: 16),
          const Gap(6),
          // Status text
          Text(
            statusText,
            style: theme.textTheme.bodyMedium?.copyWith(color: statusColor),
          ),
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
