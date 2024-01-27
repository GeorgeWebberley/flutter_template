import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

class ScreenTwo extends StatelessWidget {
  const ScreenTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
          child: Text(
        "PAGE TWO",
        style: TextStyle(fontSize: 30, color: Colors.white),
      )),
    );
  }
}
