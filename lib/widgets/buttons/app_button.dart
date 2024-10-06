import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

enum ButtonSize { small, medium, large }

enum ButtonType { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.backgroundGradient,
    this.loading = false,
    this.size = ButtonSize.medium,
    this.type = ButtonType.primary,
    this.disabled = false,
  });

  final VoidCallback? onPressed;
  final dynamic text;
  final Color? color;
  final Gradient? backgroundGradient;
  final ButtonSize? size;
  final bool loading;
  final ButtonType type;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    // Default size (if medium)
    double height = 50;
    double fontSize = 26;

    if (size == ButtonSize.small) {
      height = 40;
      fontSize = 16;
    } else if (size == ButtonSize.large) {
      height = 60;
      fontSize = 20;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient ??
            (disabled
                ? LinearGradient(colors: [
                    Colors.grey.withOpacity(0.25),
                    Colors.grey.withOpacity(0.25)
                  ])
                : (type == ButtonType.primary
                    ? AppGradients.buttonPrimaryGradient
                    : AppGradients.buttonSecondaryGradient)),
        boxShadow: disabled
            ? null
            : type == ButtonType.primary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.transparent,
            minimumSize: Size.fromHeight(height)),
        child: loading
            ? CircularProgressIndicator(
                color: color ??
                    (type == ButtonType.primary ? Colors.white : Colors.black))
            : Text(
                text,
                style: TextStyle(
                    fontSize: fontSize,
                    color: color ??
                        (type == ButtonType.primary
                            ? Colors.white
                            : Colors.black),
                    fontWeight: type == ButtonType.primary
                        ? FontWeight.w500
                        : FontWeight.w300),
              ),
      ),
    );
  }
}
