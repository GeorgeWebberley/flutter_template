import 'package:flutter/material.dart';

/// Adds a 'slide' animation to MaterialPageRoute transitions.
/// Can be applied like so:
///
/// Navigator.push(context, SlideNavigator(builder: (context, _, __) => MyRoute()));
///
/// Note: This is not needed when using 'pushNamed' if you're handling animations elsewhere.
class SlideNavigator<T> extends PageRouteBuilder<T> {
  SlideNavigator({
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
        builder,
    super.settings,
  }) : super(pageBuilder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  RouteTransitionsBuilder get transitionsBuilder =>
      (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var reverseTween =
            Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0))
                .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: SlideTransition(
            position: secondaryAnimation.drive(reverseTween),
            child: child,
          ),
        );
      };
}
