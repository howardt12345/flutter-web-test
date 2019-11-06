
import 'package:flutter/material.dart';

class SimpleRoute extends PageRoute {
  SimpleRoute({
    @required String name,
    @required this.title,
    @required this.builder,
  }) : super(settings: RouteSettings(
    name: name,
  ));

  final String title;
  final WidgetBuilder builder;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Title(
      title: this.title,
      color: Theme.of(context).primaryColor,
      child: builder(context),
    );
  }
}

typedef Widget NestedRouteBuilder(Widget child);

@immutable
class NestedRoute {
  final String name;
  final List<NestedRoute> subRoutes;
  final NestedRouteBuilder builder;

  const NestedRoute({@required this.name, this.subRoutes, @required this.builder});

  Route buildRoute(List<String> paths, int index) {
    return new PageRouteBuilder<dynamic>(
      pageBuilder: (_, __, ___) => _build(paths, index),
    );
  }

  Widget _build(List<String> paths, int index) {
    if (index > paths.length) {
      return builder(null);
    }
    final route = subRoutes?.firstWhere((route) => route.name == paths[index], orElse: () => null);
    return builder(route?._build(paths, index + 1));
  }
}

RouteFactory buildNestedRoutes(List<NestedRoute> routes) {
  return (RouteSettings settings) {
    final paths = settings.name.split('/');
    if (paths.length <= 1) {
      return null;
    }
    final rootRoute = routes.firstWhere((route) => route.name == paths[1]);
    return rootRoute.buildRoute(paths, 2);
  };
}