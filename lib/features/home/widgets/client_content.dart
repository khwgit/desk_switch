import 'package:desk_switch/core/services/client_service.dart'
    show ClientServiceState;
import 'package:desk_switch/core/services/server_service.dart'
    show ServerServiceState;
import 'package:desk_switch/features/home/providers/client_content_providers.dart';
import 'package:desk_switch/features/home/providers/shared_providers.dart';
import 'package:desk_switch/features/home/widgets/server_card.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

class ClientContent extends HookConsumerWidget {
  const ClientContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 4,
          child: _ServerList(),
        ),
        Gap(8),
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _ServerInfo()),
              Gap(8),
              _ConnectionStatus(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServerList extends HookConsumerWidget {
  const _ServerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serversStream = ref.watch(serversProvider);
    final pinnedNotifier = ref.watch(pinnedServersProvider.notifier);
    final onServerSelected = ref.watch(selectedServerProvider.notifier).select;
    final selectedServer = ref.watch(selectedServerProvider);
    final connectedServer = ref.watch(connectedServerProvider);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(8),
          // Header with Add Button
          Row(
            children: [
              const Gap(16),
              Text(
                'Servers',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(serversProvider),
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddServerDialog(
                  context,
                  onServerSelected,
                ),
                tooltip: 'Add server',
              ),
              const Gap(8),
            ],
          ),
          const Gap(4),
          // Available Servers List
          Expanded(
            child: serversStream.when(
              skipLoadingOnRefresh: false,
              data: (servers) {
                if (servers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 48,
                            color: theme.colorScheme.onSurface.withAlpha(100),
                          ),
                          const Gap(8),
                          Text(
                            'No servers available',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Waiting for server signals...',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                          const Gap(32),
                        ],
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => onServerSelected(null),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0, bottom: 32),
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      final isPinned = pinnedNotifier.isPinned(server.name);

                      return Consumer(
                        builder: (context, ref, child) {
                          final clientState = ref.watch(
                            clientStateProvider.select(
                              (state) => connectedServer?.id == server.id
                                  ? state
                                  : ClientServiceState.disconnected,
                            ),
                          );

                          return ServerCard(
                            server: server,
                            isSelected: selectedServer?.id == server.id,
                            isPinned: isPinned,
                            state: clientState,
                            onTap: () => onServerSelected(server),
                            onPinToggle: () {
                              if (isPinned) {
                                pinnedNotifier.unpin(server.name);
                              } else {
                                pinnedNotifier.pin(server.name);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const Gap(16),
                      Text(
                        'Server discovery failed',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Unable to discover servers on the network',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      FilledButton.icon(
                        onPressed: () {
                          ref.invalidate(serversProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServerDialog(
    BuildContext context,
    ValueChanged<ServerInfo?> onServerSelected,
  ) {
    final serverIpController = TextEditingController();
    final serverPortController = TextEditingController(text: '8080');
    final serverNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serverNameController,
              decoration: const InputDecoration(
                labelText: 'Server Name',
                hintText: 'Enter server name',
              ),
            ),
            const Gap(16),
            TextField(
              controller: serverIpController,
              decoration: const InputDecoration(
                labelText: 'Server IP',
                hintText: 'Enter server IP address',
              ),
            ),
            const Gap(16),
            TextField(
              controller: serverPortController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: 'Enter port number',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final ip = serverIpController.text.trim();
              final port =
                  int.tryParse(serverPortController.text.trim()) ?? 8080;
              final name = serverNameController.text.trim().isNotEmpty
                  ? serverNameController.text.trim()
                  : 'Manual Server';

              if (ip.isNotEmpty) {
                final server = ServerInfo(
                  id: const Uuid().v4(),
                  name: name,
                  host: ip,
                  port: port,
                  isOnline: true,
                );
                onServerSelected(server);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ServerInfo extends HookConsumerWidget {
  const _ServerInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedServer = ref.watch(selectedServerProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: selectedServer != null
          ? Column(
              children: [
                // Server Information
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(16),
                      Text(
                        selectedServer.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Gap(16),
                      _InfoRow(
                        label: 'Host',
                        value: selectedServer.host ?? 'Unknown',
                        icon: Icons.location_on,
                      ),
                      const Gap(8),
                      _InfoRow(
                        label: 'Port',
                        value: selectedServer.port?.toString() ?? 'Unknown',
                        icon: Icons.numbers,
                      ),
                      const Gap(8),
                      _InfoRow(
                        label: 'Status',
                        value: selectedServer.isOnline ? 'Online' : 'Offline',
                        icon: selectedServer.isOnline
                            ? Icons.wifi
                            : Icons.wifi_off,
                        valueColor: selectedServer.isOnline
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
                const Gap(4),
                // TODO: Auto-connect Settings
                // SwitchListTile(
                //   title: const Text('Auto-connect'),
                //   subtitle: Text(
                //     'Automatically connect to this server when it becomes available',
                //     style: theme.textTheme.bodySmall?.copyWith(
                //       color: theme.colorScheme.onSurface.withAlpha(150),
                //     ),
                //   ),
                //   secondary: const Icon(
                //     Icons.auto_awesome,
                //     size: 20,
                //   ),
                //   value: false,
                //   onChanged: (value) {
                //     ref
                //         .read(
                //           autoConnectPreferencesProvider.notifier,
                //         )
                //         .setAutoConnect(
                //           selectedServer.id,
                //           value,
                //         );
                //   },
                // ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.computer_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withAlpha(100),
                    ),
                    const Gap(8),
                    Text(
                      'No server selected',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(
                          150,
                        ),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Choose a server to view its connection options',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(
                          100,
                        ),
                      ),
                    ),
                    // const Gap(32),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withAlpha(150),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionStatus extends HookConsumerWidget {
  const _ConnectionStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectedServer = ref.watch(connectedServerProvider);
    final clientState = ref.watch(clientStateProvider);

    final isConnected = clientState == ClientServiceState.connected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Status',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Icon(
                            isConnected ? Icons.link : Icons.link_off,
                            color: isConnected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withAlpha(100),
                            size: 20,
                          ),
                          const Gap(8),
                          Text(
                            isConnected
                                ? 'Connected to ${connectedServer?.name ?? "Unknown Server"}'
                                : 'Not connected',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            const _ConnectionButton(),
          ],
        ),
      ),
    );
  }
}

class _ConnectionButton extends HookConsumerWidget {
  const _ConnectionButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerProvider);
    final connectedServer = ref.watch(connectedServerProvider);
    final server = ref.watch(serverProvider.notifier);
    final client = ref.watch(clientProvider.notifier);

    final clientState = ref.watch(clientStateProvider);
    final isServerRunning = ref.watch(
      serverStateProvider.select(
        (state) => state == ServerServiceState.running,
      ),
    );

    // Determine button state and action
    String buttonText;
    Widget buttonIcon;
    VoidCallback? buttonAction;

    switch (clientState) {
      case ClientServiceState.connecting:
        buttonText = 'Connecting...';
        buttonIcon = const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        buttonAction = null;
        break;
      case ClientServiceState.connected:
        if (selectedServer == null ||
            selectedServer.id == connectedServer?.id) {
          buttonText = 'Disconnect';
          buttonIcon = const Icon(Icons.stop);
          buttonAction = () => client.disconnect();
        } else {
          buttonText = 'Connect';
          buttonIcon = const Icon(Icons.play_arrow);
          buttonAction = selectedServer.isOnline
              ? () async {
                  // Show confirmation dialog for switching servers
                  final shouldSwitch = await _showSwitchServerDialog(
                    context,
                    connectedServer!.name,
                    selectedServer.name,
                  );
                  if (!shouldSwitch) return;
                  await client.disconnect();
                  await client.connect(selectedServer);
                }
              : null;
        }
        break;
      case ClientServiceState.disconnecting:
        buttonText = 'Disconnecting...';
        buttonIcon = const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        buttonAction = null;
        break;
      case ClientServiceState.disconnected:
        buttonText = 'Connect';
        buttonIcon = const Icon(Icons.play_arrow);
        buttonAction = selectedServer != null && selectedServer.isOnline
            ? () async {
                if (isServerRunning) {
                  final shouldStopServer = await _showStopServerDialog(context);
                  if (!shouldStopServer) return;

                  // Stop the server
                  await server.stop();
                  await client.connect(selectedServer);
                }
              }
            : null;
        break;
    }

    return FilledButton.icon(
      onPressed: buttonAction,
      icon: buttonIcon,
      label: Text(buttonText),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: buttonText == 'Disconnect'
            ? Theme.of(context).colorScheme.error
            : null,
        foregroundColor: buttonText == 'Disconnect'
            ? Theme.of(context).colorScheme.onError
            : null,
      ),
    );
  }

  Future<bool> _showStopServerDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Stop Server'),
            content: const Text(
              'This app is currently running as a server. To connect to another server, '
              'the current server must be stopped. Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Stop Server'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showSwitchServerDialog(
    BuildContext context,
    String currentServerName,
    String newServerName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Switch Server'),
            content: Text(
              'You are currently connected to "$currentServerName". '
              'Connecting to "$newServerName" will terminate the current connection. '
              'Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Switch'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
