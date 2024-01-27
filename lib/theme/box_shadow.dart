import 'package:flutter/material.dart';

/// Box shadows used in the app kept in a single location
class AppBoxShadow {
  static BoxShadow small = BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 3,
      offset: const Offset(1, 2));
  static BoxShadow medium = BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 4,
      offset: const Offset(2, 4));
  static BoxShadow large = BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 4,
      offset: const Offset(4, 8));
}
