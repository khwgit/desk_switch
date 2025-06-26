import 'package:desk_switch/features/home/widgets/server_content_providers.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerContent extends HookConsumerWidget {
  const ServerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isServerRunning = ref.watch(serverRunningProvider);
    final serverService = ref.read(serverServiceProvider.notifier);
    final broadcastService = ref.read(broadcastServiceProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Selection Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Configuration Profile',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/server/profiles');
                      },
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Profiles',
                    ),
                  ],
                ),
                const Gap(16),
                // Profile selection UI can be added here later
              ],
            ),
          ),
        ),
        const Spacer(),
        // Start/Stop Button Section
        FilledButton.icon(
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
        ),
      ],
    );
  }
}
