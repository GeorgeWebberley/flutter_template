import 'package:flutter/material.dart';

/// A file to hold all the colours and gradients used in the app in a single location

/// The general colour theme used in the app.
class AppColors {
  static const Color primary = Color(0xff4a4e4d);
  static const Color secondary = Color(0xff0e9aa7);
  static const Color secondaryLight = Color(0xff3da4ab);
  static const Color tertiary = Color(0xfff6cd61);
  static const Color quaternary = Color(0xfffe8a71);
  static const Color danger = Color(0xffbb2124);
}

/// Gradients used in the app
class AppGradients {
  static const Color _backgroundSecondary = Color.fromARGB(255, 56, 71, 104);

  static const LinearGradient backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.primary, _backgroundSecondary]);
}
