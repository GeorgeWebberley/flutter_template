import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';

class AppBox extends StatelessWidget {
  const AppBox({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.small,
          boxShadow: [AppBoxShadow.small],
        ),
        child: child);
  }
}
