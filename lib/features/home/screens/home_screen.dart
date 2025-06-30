import 'package:desk_switch/features/home/widgets/client_content.dart';
import 'package:desk_switch/features/home/widgets/server_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ConnectionMode {
  client,
  server,
}

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = useState(ConnectionMode.client);

    return Column(
      children: [
        const Gap(24),
        // Custom Mode Selection Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Client Mode Card
                Expanded(
                  child: _ModeCard(
                    selected: mode.value == ConnectionMode.client,
                    icon: Icons.input,
                    iconBg: theme.colorScheme.primary,
                    title: 'Client Mode',
                    subtitle: 'Use another computer\'s mouse and keyboard',
                    onTap: () {
                      mode.value = ConnectionMode.client;
                    },
                  ),
                ),
                const Gap(12),
                // Server Mode Card
                Expanded(
                  child: _ModeCard(
                    selected: mode.value == ConnectionMode.server,
                    icon: Icons.dns,
                    iconBg: theme.colorScheme.secondary,
                    title: 'Server Mode',
                    subtitle: 'Share this computer\'s mouse and keyboard',
                    onTap: () {
                      mode.value = ConnectionMode.server;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Mode-specific Content
        Expanded(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(16),
            child: switch (mode.value) {
              ConnectionMode.client => const ClientContent(),
              ConnectionMode.server => const ServerContent(),
            },
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.7)
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                icon,
                color: iconBg,
                size: 20,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Gap(2),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
