import 'package:desk_switch/features/home/providers/server_discovery_provider.dart';
import 'package:desk_switch/features/home/widgets/server_card.dart';
import 'package:desk_switch/shared/models/connection.dart';
import 'package:desk_switch/shared/models/server_info.dart';
import 'package:desk_switch/shared/providers/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClientContent extends HookConsumerWidget {
  const ClientContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isClientRunning = ref.watch(
      appStateProvider.select(
        (state) => state.connection is ClientConnection,
      ),
    );

    // Watch server discovery state
    final discoveryState = ref.watch(serverDiscoveryStateProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left side - Server Selection
        Expanded(
          flex: 4,
          child: Card(
            child: _ServerSelection(
              selectedServer: discoveryState.selectedServer,
              onServerSelected: (server) {
                ref
                    .read(serverDiscoveryStateProvider.notifier)
                    .selectServer(server);
              },
            ),
          ),
        ),
        // Right side - Connection Info
        Expanded(
          flex: 6,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ConnectionInfo(
                selectedServer: discoveryState.selectedServer,
                isClientRunning: isClientRunning,
                onConnect: () {
                  ref.read(appStateProvider.notifier).startClient();
                },
                onDisconnect: () {
                  ref.read(appStateProvider.notifier).stopClient();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServerSelection extends HookConsumerWidget {
  const _ServerSelection({
    super.key,
    required this.selectedServer,
    required this.onServerSelected,
  });

  final ServerInfo? selectedServer;
  final ValueChanged<ServerInfo?> onServerSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final servers = ref.watch(serverDiscoveryProvider);
    final bookmarkedServers = useState<Set<String>>({});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(4),
        // Header with Add Button
        Row(
          children: [
            Gap(16),
            Text(
              'Servers',
              style: theme.textTheme.titleMedium,
            ),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshServerList(ref, bookmarkedServers.value),
              tooltip: 'Refresh server list (hide offline servers)',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddServerDialog(context),
              tooltip: 'Add server manually',
            ),
            Gap(4),
          ],
        ),
        Gap(4),
        // Available Servers List
        Expanded(
          child: servers.when(
            data: (serverList) {
              // Filter servers to show only online servers or bookmarked servers
              final filteredServers = serverList.where((server) {
                final isBookmarked = bookmarkedServers.value.contains(
                  server.id,
                );
                return server.isOnline || isBookmarked;
              }).toList();

              if (filteredServers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const Gap(8),
                        Text(
                          'No servers available',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Waiting for server signals...',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredServers.length,
                itemBuilder: (context, index) {
                  final server = filteredServers[index];
                  final isBookmarked = bookmarkedServers.value.contains(
                    server.id,
                  );

                  return ServerCard(
                    server: server,
                    isBookmarked: isBookmarked,
                    onTap: () => onServerSelected(server),
                    onBookmarkToggle: () {
                      final newBookmarks = Set<String>.from(
                        bookmarkedServers.value,
                      );
                      if (isBookmarked) {
                        newBookmarks.remove(server.id);
                      } else {
                        newBookmarks.add(server.id);
                      }
                      bookmarkedServers.value = newBookmarks;
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
                child: Text(
                  'Error: $error',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
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
        title: const Text('Add Server Manually'),
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
                  id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  ipAddress: ip,
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

  void _refreshServerList(WidgetRef ref, Set<String> bookmarkedServers) {
    // Since the server discovery service automatically manages server status,
    // we'll just trigger a rebuild to show the current filtered state
    // The filtering will be done in the UI when displaying servers
    ref.invalidate(serverDiscoveryProvider);
  }
}

class _ConnectionInfo extends StatelessWidget {
  const _ConnectionInfo({
    required this.selectedServer,
    required this.isClientRunning,
    required this.onConnect,
    required this.onDisconnect,
  });

  final ServerInfo? selectedServer;
  final bool isClientRunning;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                'Connection Info',
                style: theme.textTheme.titleLarge,
              ),
              const Gap(16),
              if (selectedServer != null) ...[
                _InfoCard(
                  title: 'Server Name',
                  value: selectedServer!.name,
                  icon: Icons.computer,
                ),
                const Gap(8),
                _InfoCard(
                  title: 'IP Address',
                  value: selectedServer!.ipAddress,
                  icon: Icons.language,
                ),
                const Gap(8),
                _InfoCard(
                  title: 'Port',
                  value: selectedServer!.port.toString(),
                  icon: Icons.numbers,
                ),
                const Gap(8),
                _InfoCard(
                  title: 'Status',
                  value: selectedServer!.isOnline ? 'Online' : 'Offline',
                  icon: selectedServer!.isOnline
                      ? Icons.check_circle
                      : Icons.error_outline,
                  valueColor: selectedServer!.isOnline
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select a server to view connection info',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Gap(16),
        FilledButton.icon(
          onPressed: selectedServer == null
              ? null
              : isClientRunning
              ? onDisconnect
              : onConnect,
          icon: Icon(isClientRunning ? Icons.stop : Icons.play_arrow),
          label: Text(isClientRunning ? 'Disconnect' : 'Connect'),
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
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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
