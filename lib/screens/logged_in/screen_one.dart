import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.quaternary,
      body: Center(
          child: Text(
        "PAGE ONE",
        style: TextStyle(fontSize: 30, color: Colors.white),
      )),
    );
  }
}
