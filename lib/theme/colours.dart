import 'package:flutter/material.dart';

/// A file to hold all the colours and gradients used in the app in a single location

/// The general colour theme used in the app.
class AppColors {
  static const Color primary = Color(0xff3761D7);
  static const Color secondary = Color(0xff0e9aa7);
  static const Color secondaryLight = Color(0xff3da4ab);
  static const Color tertiary = Color(0xfff6cd61);
  static const Color quaternary = Color(0xfffe8a71);
  static const Color danger = Color(0xffbb2124);
  static const Color green = Color(0Xff177725);
}

/// Gradients used in the app
class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 191, 200, 255),
        Color.fromARGB(255, 223, 226, 252),
        Color.fromARGB(255, 223, 226, 252),
        Color.fromARGB(255, 243, 244, 254),
        Color.fromARGB(255, 250, 237, 255),
        Color.fromARGB(255, 245, 220, 255),
      ]);
  static const LinearGradient backgroundGradientMild = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 239, 241, 253),
        Color.fromARGB(255, 236, 238, 252),
        Color.fromARGB(255, 250, 237, 255),
      ]);
  static const LinearGradient buttonPrimaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, Color(0xff7A8EE9)]);
  static const LinearGradient buttonSecondaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xffE2E8FB), Color(0xffE6EAFC)]);

  static const LinearGradient greenGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 69, 154, 82),
        AppColors.green,
      ]);
}
