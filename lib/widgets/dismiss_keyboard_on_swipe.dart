import 'package:flutter/material.dart';

class DismissKeyboardOnSwipe extends StatelessWidget {
  const DismissKeyboardOnSwipe({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // If dragging down, close the keyboard
        if (details.primaryDelta! > 0) {
          FocusScope.of(context).unfocus();
        }
      },
      child: child,
    );
  }
}
