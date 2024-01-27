import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/text.dart';

enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      this.color,
      this.loading = false,
      this.size = ButtonSize.medium})
      : super(key: key);

  final VoidCallback? onPressed;
  final dynamic text;
  final Color? color;
  final ButtonSize? size;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // Default size (if medium)
    double height = 50;
    double fontSize = 26;

    if (size == ButtonSize.small) {
      height = 40;
      fontSize = 22;
    } else if (size == ButtonSize.large) {
      height = 60;
      fontSize = 32;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          primary: color ?? AppColors.primary,
          minimumSize: Size.fromHeight(height)),
      child: loading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(text, style: TextStyle(fontSize: fontSize)).h1(),
    );
  }
}
