import 'package:desk_switch/shared/providers/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClientContent extends HookConsumerWidget {
  const ClientContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    // final connection = ref.watch(provider)
    final isClientRunning = ref.watch(
      appStateProvider.select(
        (state) => state.connection is ClientContent,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Server Connection Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect to Server',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Gap(16),
                  // Server IP Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Server IP',
                      hintText: 'Enter server IP address',
                    ),
                  ),
                  const Gap(8),
                  // Auto-detect Button
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement auto-detect
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Auto-detect Server'),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Start/Stop Button Section
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: isClientRunning
                      ? () {
                          // TODO: Implement stop client
                        }
                      : () {
                          // TODO: Implement start client
                        },
                  icon: Icon(isClientRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(isClientRunning ? 'Stop' : 'Start Client'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
