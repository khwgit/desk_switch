import 'package:desk_switch/l10n/app_localizations.dart';
import 'package:desk_switch/shared/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow();

  // Set window properties
  await windowManager.setTitle('DeskSwitch');
  await windowManager.setSize(const Size(800, 600));
  await windowManager.setMinimumSize(const Size(800, 600));
  await windowManager.setMaximumSize(const Size(800, 600));
  await windowManager.setResizable(false);
  await windowManager.center();

  runApp(const ProviderScope(child: DeskSwitchApp()));
}

class DeskSwitchApp extends ConsumerWidget {
  const DeskSwitchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
      useMaterial3: true,
      cardTheme: const CardThemeData(
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        minWidth: 72,
      ),
    );

    return MaterialApp.router(
      title: 'DeskSwitch',
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme,
      darkTheme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
