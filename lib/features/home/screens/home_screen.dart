import 'package:desk_switch/features/home/widgets/client_content.dart';
import 'package:desk_switch/features/home/widgets/server_content.dart';
import 'package:desk_switch/shared/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final isClientMode = appState.isClientMode;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom Mode Selection Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              // Client Mode Card
              Expanded(
                child: _ModeCard(
                  selected: isClientMode,
                  icon: Icons.input,
                  iconBg: theme.colorScheme.primary,
                  title: 'Client Mode',
                  subtitle: 'Use another computer\'s mouse and keyboard',
                  onTap: () {
                    if (!isClientMode) {
                      ref
                          .read(appStateProvider.notifier)
                          .switchMode(AppMode.client);
                    }
                  },
                ),
              ),
              const Gap(12),
              // Server Mode Card
              Expanded(
                child: _ModeCard(
                  selected: !isClientMode,
                  icon: Icons.dns,
                  iconBg: theme.colorScheme.secondary,
                  title: 'Server Mode',
                  subtitle: 'Share this computer\'s mouse and keyboard',
                  onTap: () {
                    if (isClientMode) {
                      ref
                          .read(appStateProvider.notifier)
                          .switchMode(AppMode.server);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Mode-specific Content
        Expanded(
          child: isClientMode ? const ClientContent() : const ServerContent(),
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.7)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: iconBg,
                size: 28,
              ),
            ),
            const Gap(16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const Gap(4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
