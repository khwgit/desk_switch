import 'package:desk_switch/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final route = ref.watch(appRouteProvider);
  final routes = route.routes;
  return GoRouter(
    initialLocation: route.home().location,
    routes: routes,
  );
});
