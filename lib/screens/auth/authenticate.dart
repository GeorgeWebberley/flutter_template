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
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => setLoginScreen(null),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
            )
          ],
        ),
        crossFadeState: showSignIn == null
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond);
  }
}
