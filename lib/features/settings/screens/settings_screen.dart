import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Theme Settings
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: theme.textTheme.titleLarge,
                ),
                const Gap(16),
                // Theme Mode Selection
                DropdownButtonFormField<ThemeMode>(
                  value: ThemeMode.system,
                  decoration: const InputDecoration(
                    labelText: 'Theme Mode',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (ThemeMode? mode) {
                    if (mode != null) {
                      // TODO: Implement theme mode change
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        // Network Settings
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network',
                  style: theme.textTheme.titleLarge,
                ),
                const Gap(16),
                // Network Interface Selection
                DropdownButtonFormField<String>(
                  value: 'en0',
                  decoration: const InputDecoration(
                    labelText: 'Network Interface',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'en0',
                      child: Text('Wi-Fi (en0)'),
                    ),
                    DropdownMenuItem(
                      value: 'en1',
                      child: Text('Ethernet (en1)'),
                    ),
                  ],
                  onChanged: (String? interface) {
                    if (interface != null) {
                      // TODO: Implement network interface change
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
