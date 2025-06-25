import 'package:desk_switch/features/home/widgets/client_content_providers.dart';
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
    final selectedServer = ref.watch(selectedServerProvider);
    // TODO: Replace with a real connection state provider if needed
    const isConnected = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Card(
                  child: _ServerSelection(
                    selectedServer: selectedServer,
                    onServerSelected: (server) {
                      ref.read(selectedServerProvider.notifier).select(server);
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Card(
                      child: _ConnectedServer(
                        isConnected: isConnected,
                        connectedServer: isConnected ? selectedServer : null,
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _ServerInfo(
                            selectedServer: selectedServer,
                            isConnected: isConnected,
                            onConnect: () {
                              // TODO: Implement connection logic
                            },
                            onDisconnect: () {
                              // TODO: Implement disconnect logic
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServerSelection extends HookConsumerWidget {
  const _ServerSelection({
    required this.selectedServer,
    required this.onServerSelected,
  });

  final ServerInfo? selectedServer;
  final ValueChanged<ServerInfo?> onServerSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serversStream = ref.watch(serversProvider);
    final pinnedNotifier = ref.read(pinnedServersProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(4),
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
              onPressed: () => _showAddServerDialog(context),
              tooltip: 'Add server',
            ),
            const Gap(4),
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

              return ListView.builder(
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final server = servers[index];
                  final isPinned = pinnedNotifier.isPinned(server.name);
                  // TODO: Implement isConnected logic if needed
                  const isConnected = false;

                  return ServerCard(
                    server: server,
                    isPinned: isPinned,
                    isConnected: isConnected,
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
    );
  }

  void _showAddServerDialog(BuildContext context) {
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

class _ServerInfo extends StatelessWidget {
  const _ServerInfo({
    required this.selectedServer,
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
  });

  final ServerInfo? selectedServer;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Server Info',
          style: theme.textTheme.titleMedium,
        ),
        const Gap(16),
        Expanded(
          child: selectedServer != null
              ? ListView(
                  children: [],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select a server to view server info',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ),
                ),
        ),
        const Gap(16),
        FilledButton.icon(
          onPressed: selectedServer == null
              ? null
              : isConnected
              ? onDisconnect
              : onConnect,
          icon: Icon(isConnected ? Icons.stop : Icons.play_arrow),
          label: Text(isConnected ? 'Disconnect' : 'Connect'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedServer extends StatelessWidget {
  const _ConnectedServer({
    required this.isConnected,
    required this.connectedServer,
  });

  final bool isConnected;
  final ServerInfo? connectedServer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
                          ? 'Connected to ${connectedServer?.name ?? "Unknown Server"} (${connectedServer?.host ?? "-"}:${connectedServer?.port?.toString() ?? "-"})'
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
          if (isConnected && connectedServer != null)
            FilledButton.icon(
              onPressed: () {
                // TODO: Implement disconnect logic
              },
              icon: const Icon(Icons.stop),
              label: const Text('Disconnect'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
            ),
        ],
      ),
    );
  }
}
