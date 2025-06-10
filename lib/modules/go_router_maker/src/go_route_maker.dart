import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'go_route_config.dart';
import 'internal/utils.dart';

typedef GoRouteMakerWidgetBuilder<T extends GoRouteData?> = Widget Function(
  BuildContext context,
  GoRouterState state,
  T data,
);

typedef GoRouteMakerPageBuilder<T extends GoRouteData?> = Page<void> Function(
  BuildContext context,
  GoRouterState state,
  T data,
);

typedef GoRouteMakerRedirect<T extends GoRouteData?> = FutureOr<String?>
    Function(
  BuildContext context,
  GoRouterState state,
  T data,
);

typedef GoRouteMakerExitCallback<T extends GoRouteData?> = FutureOr<bool>
    Function(
  BuildContext context,
  GoRouterState state,
  T data,
);

class GoRouteMaker extends GoRouteMakerBase<Null> {
  const GoRouteMaker({
    required super.location,
    super.name,
    super.builder,
    super.pageBuilder,
    super.redirect,
    super.onExit,
    super.parentNavigatorKey,
  }) : super._(data: null);

  GoRouteConfig call() {
    return GoRouteConfig(location(null), null);
  }
}

class DataGoRouteMaker<T extends GoRouteData> extends GoRouteMakerBase<T> {
  const DataGoRouteMaker({
    required super.location,
    required RouteMakerDataBuilder<T> super.data,
    super.name,
    super.builder,
    super.pageBuilder,
    super.redirect,
    super.onExit,
    super.parentNavigatorKey,
  }) : super._();

  GoRouteConfig call(T data) {
    return GoRouteConfig(location(data), data);
  }
}

abstract class GoRouteMakerBase<T extends GoRouteData?> {
  final String Function(T data) location;
  final RouteMakerDataBuilder<T>? data;
  final String? name;
  final GoRouteMakerWidgetBuilder<T>? builder;
  final GoRouteMakerPageBuilder<T>? pageBuilder;
  final GoRouteMakerRedirect<T>? redirect;
  final GoRouteMakerExitCallback<T>? onExit;

  final GlobalKey<NavigatorState>? parentNavigatorKey;

  GoRoute $route({
    required String path,
    List<RouteBase> routes = const [],
  }) {
    T extract(GoRouterState state) {
      final extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `GoRouteData`, so it doesn't need to be recreated.
      if (extra is T) return extra;
      return (_stateObjectExpando[state] ??= data?.call(state)) as T;
    }

    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
      builder: (context, state) {
        final extracted = extract(state);
        final result = builder?.call(context, state, extracted) ??
            extracted?.build(context, state);
        if (result != null) return result;
        throw UnimplementedError(
          'One of `build` or `buildPage` must be implemented.',
        );
      },
      pageBuilder: (context, state) {
        final extracted = extract(state);
        return pageBuilder?.call(context, state, extracted) ??
            extracted?.buildPage(context, state) ??
            const NoOpPage();
      },
      redirect: (context, state) {
        final extracted = extract(state);
        return redirect?.call(context, state, extracted) ??
            extracted?.redirect(context, state);
      },
      onExit: (context, state) {
        final extracted = extract(state);
        return onExit?.call(context, state, extracted) ??
            extracted?.onExit(context, state) ??
            true;
      },
    );
  }

  const GoRouteMakerBase._({
    required this.location,
    this.data,
    this.name,
    this.builder,
    this.pageBuilder,
    this.redirect,
    this.onExit,
    this.parentNavigatorKey,
  });

  /// Used to cache [GoRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<GoRouteData> _stateObjectExpando = Expando<GoRouteData>(
    'GoRouteState to GoRouteData expando',
  );
}
