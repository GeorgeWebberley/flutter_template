import 'package:flutter/material.dart';

class AppAnimatedCrossFade extends StatelessWidget {
  const AppAnimatedCrossFade(
      {Key? key,
      required this.firstChild,
      required this.secondChild,
      required this.crossFadeState})
      : super(key: key);

  final Widget firstChild;
  final Widget secondChild;
  final CrossFadeState crossFadeState;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstChild: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width),
          child: firstChild),
      secondChild: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width),
        child: secondChild,
      ),
      crossFadeState: crossFadeState,
    );
  }
}
