import 'package:desk_switch/features/app/widgets/app_navigation_rail.dart';
import 'package:desk_switch/features/app/widgets/app_status_bar.dart';
import 'package:desk_switch/shared/providers/app_state.dart';
import 'package:flutter/material.dart';
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
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Left Sidebar
                AppNavigationRail(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: (index) => shell.goBranch(index),
                ),
                // Main Content
                Expanded(child: shell),
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
