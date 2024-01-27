import 'package:flutter/material.dart';

class AccountState extends ChangeNotifier {
  String currentScreen = 'root';

  setScreen(String screen) {
    currentScreen = screen;
    notifyListeners();
  }
}
