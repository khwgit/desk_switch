import 'package:desk_switch/features/app/widgets/app_navigation_rail.dart';
import 'package:desk_switch/features/app/widgets/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppScaffold extends HookConsumerWidget {
  const AppScaffold({
    super.key,
    required this.shell,
  });

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationRailTheme = NavigationRailTheme.of(context);
    final navigationRailMinWidth = navigationRailTheme.minWidth;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Main Content
                Positioned.fill(
                  child: Row(
                    children: [
                      Gap(navigationRailMinWidth!),
                      Expanded(child: shell),
                    ],
                  ),
                ),
                // Left Sidebar (overlay)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Material(
                    elevation: 2,
                    child: AppNavigationRail(
                      selectedIndex: shell.currentIndex,
                      onDestinationSelected: (index) => shell.goBranch(index),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status Bar
          const AppStatusBar(),
        ],
      ),
    );
  }
}
