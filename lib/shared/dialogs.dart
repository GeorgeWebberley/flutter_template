import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

void showToast(
    {required BuildContext context,
    required String message,
    EdgeInsetsGeometry? margin,
    Color? color = AppColors.secondary}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: margin,
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ),
  );
}
