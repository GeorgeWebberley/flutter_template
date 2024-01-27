import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A widget wrapped around [Lottie] to provide us some extra functionality.
/// Currently this is predominantly to add an 'onComplete' callback function but
/// can be expanded in future if need be.
class LottieController extends StatefulWidget {
  const LottieController(
      {Key? key,
      required this.location,
      this.repeat,
      this.width,
      this.height,
      this.fit,
      this.onComplete})
      : super(key: key);

  final String location;
  final bool? repeat;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final dynamic Function()? onComplete;

  @override
  State<LottieController> createState() => _LottieControllerState();
}

class _LottieControllerState extends State<LottieController>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.value;
    return Lottie.asset(widget.location,
        repeat: widget.repeat,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        controller: _controller, onLoaded: (composition) {
      if (widget.repeat == true) {
        _controller
          ..duration = composition.duration
          ..forward()
          ..repeat();
      } else {
        _controller
          ..duration = composition.duration
          ..forward().whenComplete(() => widget.onComplete?.call());
      }
    });
  }
}
