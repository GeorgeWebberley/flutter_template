import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    super.key,
    this.color = AppColors.green,
  });

  final Color? color;

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _dotController1;
  late AnimationController _dotController2;
  late AnimationController _dotController3;

  @override
  void initState() {
    super.initState();
    _dotController1 = _createDotController();
    _dotController2 = _createDotController(delay: 100);
    _dotController3 = _createDotController(delay: 200);

    _dotController1.forward();
    _dotController2.forward();
    _dotController3.forward();
  }

  AnimationController _createDotController({int delay = 0}) {
    return AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted) {
              (delay == 0
                      ? _dotController1
                      : delay == 100
                          ? _dotController2
                          : _dotController3)
                  .reverse();
            }
          });
        } else if (status == AnimationStatus.dismissed) {
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted) {
              (delay == 0
                      ? _dotController1
                      : delay == 100
                          ? _dotController2
                          : _dotController3)
                  .forward();
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _dotController1.dispose();
    _dotController2.dispose();
    _dotController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(_dotController1),
        const SizedBox(width: 4),
        _buildDot(_dotController2),
        const SizedBox(width: 4),
        _buildDot(_dotController3),
      ],
    );
  }

  Widget _buildDot(AnimationController controller) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
      child: CircleAvatar(
        radius: 5,
        backgroundColor: widget.color!,
      ),
    );
  }
}
