import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/screens/auth/register.dart';
import 'package:flutter_firebase_template/screens/auth/sign_in.dart';
import 'package:flutter_firebase_template/screens/auth/welcome.dart';
import 'package:flutter_firebase_template/widgets/app_animated_cross_fade.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool? showSignIn;

  @override
  void initState() {
    super.initState();
  }

  void setLoginScreen(bool? value) {
    setState(() {
      showSignIn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimatedCrossFade(
        firstChild: Welcome(setLoginScreen: setLoginScreen),
        secondChild: Stack(
          children: [
            AppAnimatedCrossFade(
                firstChild: SignIn(setLoginScreen: setLoginScreen),
                secondChild: Register(setLoginScreen: setLoginScreen),
                crossFadeState: showSignIn == true
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond),
          ],
        ),
        crossFadeState: showSignIn == null
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond);
  }
}
