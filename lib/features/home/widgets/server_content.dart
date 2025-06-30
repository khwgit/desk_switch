import 'package:desk_switch/features/home/widgets/arrange_displays_dialog.dart';
import 'package:desk_switch/features/home/widgets/server_content_providers.dart';
import 'package:desk_switch/models/server_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerContent extends HookConsumerWidget {
  const ServerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: Connected Clients
        Expanded(
          flex: 4,
          child: _ClientList(),
        ),
        Gap(8),
        // Right: Configuration and Controls
        Expanded(
          flex: 6,
          child: _ServerProfile(),
        ),
      ],
    );
  }
}

class _ServerProfile extends HookConsumerWidget {
  const _ServerProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isServerRunning = ref.watch(serverRunningProvider);
    final profileAsync = ref.watch(serverProfileProvider);
    final serverService = ref.read(serverServiceProvider.notifier);
    final broadcastService = ref.read(broadcastServiceProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: theme.textTheme.titleMedium,
            ),
            const Gap(16),
            Expanded(
              child: profileAsync.when(
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ServerNameField(profile: profile),
                    const Gap(16),
                    _PortConfigurationSection(
                      isServerRunning: isServerRunning,
                      profile: profile,
                    ),
                    const Gap(16),
                    const _MonitorArrangementButton(),
                    const Gap(16),
                    const Spacer(),
                    _StartButton(
                      isServerRunning: isServerRunning,
                      serverService: serverService,
                      broadcastService: broadcastService,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text(
                  'Failed to load profile',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends HookConsumerWidget {
  final bool isServerRunning;
  final dynamic serverService;
  final dynamic broadcastService;

  const _StartButton({
    required this.isServerRunning,
    required this.serverService,
    required this.broadcastService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: isServerRunning
          ? () async {
              await serverService.stop();
              await broadcastService.stop();
              ref.invalidate(serverRunningProvider);
            }
          : () async {
              final serverInfo = await serverService.start();
              if (serverInfo != null) {
                await broadcastService.start(serverInfo);
              }
              ref.invalidate(serverRunningProvider);
            },
      icon: Icon(isServerRunning ? Icons.stop : Icons.play_arrow),
      label: Text(isServerRunning ? 'Stop' : 'Start Server'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
      ),
    );
  }
}

class _ServerNameField extends HookConsumerWidget {
  const _ServerNameField({required this.profile});
  final ServerInfo profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final nameController = useTextEditingController(
      text: profile.name,
    );
    final isEditing = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Server Name',
          style: theme.textTheme.labelLarge,
        ),
        const Gap(4),
        if (isEditing.value)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter server name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (value) {
                    // TODO: Save server name
                    isEditing.value = false;
                  },
                ),
              ),
              const Gap(8),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // TODO: Save server name
                  isEditing.value = false;
                },
                tooltip: 'Save',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  nameController.text = profile.name;
                  isEditing.value = false;
                },
                tooltip: 'Cancel',
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  nameController.text,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                onPressed: () => isEditing.value = true,
                tooltip: 'Edit server name',
              ),
            ],
          ),
      ],
    );
  }
}

class _PortConfigurationSection extends HookConsumerWidget {
  final bool isServerRunning;
  final ServerInfo profile;

  const _PortConfigurationSection({
    required this.isServerRunning,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final portController = useTextEditingController(
      text: (profile.port ?? 8080).toString(),
    );
    final isPortAuto = useState(true);
    final currentPort = useState<int?>(null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Server Port',
          style: theme.textTheme.labelLarge,
        ),
        const Gap(8),
        // Auto/Manual Toggle
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Auto'),
                    icon: Icon(Icons.auto_awesome, size: 16),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Manual'),
                    icon: Icon(Icons.edit, size: 16),
                  ),
                ],
                selected: {isPortAuto.value},
                onSelectionChanged: (Set<bool> newSelection) {
                  isPortAuto.value = newSelection.first;
                },
              ),
            ),
          ],
        ),
        const Gap(8),
        // Port Display/Input
        if (isPortAuto.value)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    isServerRunning
                        ? 'Port: \\${currentPort.value ?? 'Detecting...'}'
                        : 'Port will be automatically assigned when server starts',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          TextField(
            controller: portController,
            decoration: const InputDecoration(
              hintText: 'Enter port number',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // TODO: Validate and save port
            },
          ),
      ],
    );
  }
}

class _MonitorArrangementButton extends HookConsumerWidget {
  const _MonitorArrangementButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Open monitor arrangement dialog/screen
        showDialog(
          context: context,
          builder: (context) => ArrangeDisplaysDialog(
            initialArrangement: KvmDisplayArrangement(
              displays: [
                KvmDisplay(
                  id: '1',
                  name: 'Primary Display',
                  // resolution: '1920x1080',
                  size: const Size(192, 108),
                  position: const Offset(0, 0),
                ),
                KvmDisplay(
                  id: '2',
                  name: 'Secondary Display',
                  size: const Size(108, 192),
                  position: const Offset(192, 0),
                ),
                KvmDisplay(
                  id: '3',
                  name: 'External Monitor',
                  size: const Size(192, 108),
                  position: const Offset(0, 108),
                ),
              ],
            ),
            onArrangementChanged: (arrangement) {},
          ),
        );
      },
      icon: const Icon(Icons.display_settings),
      label: const Text('Arrange Monitors'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

class _MonitorArrangementDialog extends HookConsumerWidget {
  const _MonitorArrangementDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock monitor data - replace with actual monitor detection
    final monitors = [
      {'name': 'Primary Display', 'resolution': '1920x1080', 'enabled': true},
      {'name': 'Secondary Display', 'resolution': '2560x1440', 'enabled': true},
      {'name': 'External Monitor', 'resolution': '1366x768', 'enabled': false},
    ];

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.display_settings,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const Gap(8),
                  Text(
                    'Monitor Arrangement',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Monitors',
                      style: theme.textTheme.titleSmall,
                    ),
                    const Gap(8),
                    Text(
                      'Configure which monitors to share and how they should be arranged for connected clients.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(16),
                    // Monitor List
                    Expanded(
                      child: ListView.separated(
                        itemCount: monitors.length,
                        separatorBuilder: (context, index) => const Gap(8),
                        itemBuilder: (context, index) {
                          final monitor = monitors[index];
                          return _MonitorItem(
                            name: monitor['name'] as String,
                            resolution: monitor['resolution'] as String,
                            enabled: monitor['enabled'] as bool,
                            onToggle: (value) {
                              // TODO: Update monitor enabled state
                            },
                          );
                        },
                      ),
                    ),
                    const Gap(16),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Refresh monitor list
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              // TODO: Apply monitor arrangement
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitorItem extends HookConsumerWidget {
  final String name;
  final String resolution;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _MonitorItem({
    required this.name,
    required this.resolution,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Monitor Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.monitor,
                size: 20,
                color: enabled
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(12),
            // Monitor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    resolution,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle Switch
            Switch(
              value: enabled,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientList extends HookConsumerWidget {
  const _ClientList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serverState = ref.watch(serverServiceProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final isServerRunning = serverState == ServerServiceState.running;

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
                'Clients',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {}, // Optionally disable if server not running
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {}, // Optionally disable if server not running
                tooltip: 'Add client',
              ),
              const Gap(8),
            ],
          ),
          const Gap(4),
          // Main content
          Expanded(
            child: isServerRunning
                ? clientsAsync.when(
                    data: (clients) => clients.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.computer_outlined,
                                    size: 48,
                                    color: theme.colorScheme.onSurface
                                        .withAlpha(100),
                                  ),
                                  const Gap(8),
                                  Text(
                                    'No clients found',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(150),
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    'Clients will appear here when they connect',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(100),
                                    ),
                                  ),
                                  const Gap(32),
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            children: clients
                                .map(
                                  (c) => ListTile(
                                    leading: const Icon(Icons.computer),
                                    title: Text(c.name ?? c.id),
                                  ),
                                )
                                .toList(),
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
                              'Failed to load clients',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              error.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  150,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.power_settings_new,
                            size: 48,
                            color: theme.colorScheme.onSurface.withAlpha(100),
                          ),
                          const Gap(8),
                          Text(
                            'Server not running',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'The client list will appear here once the server is running.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                          const Gap(32),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
