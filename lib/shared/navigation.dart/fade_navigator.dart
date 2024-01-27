import 'package:flutter/material.dart';

/// Adds a 'fade' animation to MaterialPageRoute transitions. Can be applied like
/// so:
///
/// Navigator.push(context, FadeNavigator(builder: (context, _, __) => MyRoute()));
///
/// Note: This is not needed when we use 'pushNamed', since Fluro router handles
/// the fade animation.
class FadeNavigator<T> extends PageRouteBuilder<T> {
  FadeNavigator(
      {required Widget Function(
              BuildContext, Animation<double>, Animation<double>)
          builder,
      RouteSettings? settings})
      : super(pageBuilder: builder, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  RouteTransitionsBuilder get transitionsBuilder =>
      (_, a, __, c) => FadeTransition(opacity: a, child: c);
}
