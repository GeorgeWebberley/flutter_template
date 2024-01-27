import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/padding.dart';

class RoundAssetButton extends StatelessWidget {
  const RoundAssetButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color = Colors.white,
    this.diameter = 30,
  }) : super(key: key);

  final void Function()? onPressed;
  final Widget child;
  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(AppPading.small),
          backgroundColor: Colors.white,
        ),
        child:
            SizedBox(height: (diameter + 2 * AppPading.small), child: child));
  }
}
