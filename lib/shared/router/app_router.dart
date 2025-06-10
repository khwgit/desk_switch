import 'package:desk_switch/features/client/screens/client_connect_screen.dart';
import 'package:desk_switch/features/client/screens/client_home_screen.dart';
import 'package:desk_switch/features/client/screens/client_settings_screen.dart';
import 'package:desk_switch/features/mode_selection/screens/mode_selection_screen.dart';
import 'package:desk_switch/features/server/screens/server_clients_screen.dart';
import 'package:desk_switch/features/server/screens/server_home_screen.dart';
import 'package:desk_switch/features/server/screens/server_network_screen.dart';
import 'package:desk_switch/features/server/screens/server_profiles_screen.dart';
import 'package:desk_switch/shared/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const ModeSelectionScreen(),
      ),
      GoRoute(
        path: Routes.client,
        builder: (context, state) => const ClientHomeScreen(),
        routes: [
          GoRoute(
            path: 'connect',
            builder: (context, state) => const ClientConnectScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const ClientSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.server,
        builder: (context, state) => const ServerHomeScreen(),
        routes: [
          GoRoute(
            path: 'profiles',
            builder: (context, state) => const ServerProfilesScreen(),
          ),
          GoRoute(
            path: 'network',
            builder: (context, state) => const ServerNetworkScreen(),
          ),
          GoRoute(
            path: 'clients',
            builder: (context, state) => const ServerClientsScreen(),
          ),
        ],
      ),
    ],
  );
});
