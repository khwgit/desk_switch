import 'package:desk_switch/shared/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppNavigationRail extends HookConsumerWidget {
  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRoute = ref.watch(appRouteProvider);
    final theme = Theme.of(context);
    final isHovered = useState(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Stack(
        children: [
          // Navigation Rail
          NavigationRail(
            extended: isHovered.value,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              if (index == 1) {
                // Navigate to settings using GoRouter
                appRoute.settings().go(context);
              } else {
                onDestinationSelected(index);
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Version Info
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Text(
                          'v${snapshot.data!.version}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.6,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
