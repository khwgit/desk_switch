import 'package:desk_switch/shared/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerContent extends HookConsumerWidget {
  const ServerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  if (appState.profiles.isEmpty)
                    const Text('No profiles available')
                  else
                    DropdownButtonFormField<String>(
                      value: appState.activeProfile?.id,
                      decoration: const InputDecoration(
                        labelText: 'Select Profile',
                      ),
                      items: appState.profiles.map((profile) {
                        return DropdownMenuItem(
                          value: profile.id,
                          child: Text(profile.name),
                        );
                      }).toList(),
                      onChanged: (profileId) {
                        if (profileId != null) {
                          final profile = appState.profiles.firstWhere(
                            (p) => p.id == profileId,
                          );
                          ref
                              .read(appStateProvider.notifier)
                              .setActiveProfile(profile);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Start Button Section
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: appState.activeProfile == null
                      ? null
                      : () {
                          // TODO: Implement start server
                        },
                  label: const Text('Start Server'),
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
