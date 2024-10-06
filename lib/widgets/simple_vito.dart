import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';

class SimpleVito extends StatefulWidget {
  const SimpleVito({
    super.key,
    required this.text,
    this.child,
  });

  final String text;
  final Widget? child;

  @override
  State<SimpleVito> createState() => _SimpleVitoState();
}

class _SimpleVitoState extends State<SimpleVito>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 500), // Adjust the duration as needed
    );

    // Define the scale animation (from 0 to 1)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // Adjust curve for a "pop" effect
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(AppPading.large),
            decoration: BoxDecoration(
              boxShadow: [AppBoxShadow.small],
              borderRadius: AppBorderRadius.large,
              color: Colors.white,
            ),
            child: Text(widget.text).h5(),
          ),
        ),
        LottieController(
          location: 'assets/lottie/robot.json',
          height: 100,
          repeat: true,
        ),
        if (widget.child != null) widget.child!
      ],
    );
  }
}
