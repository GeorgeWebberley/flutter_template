import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/intro_slider_page.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';
import 'package:provider/provider.dart';

class ConfirmEmail extends StatefulWidget {
  const ConfirmEmail({Key? key, required this.user, required this.onSuccess})
      : super(key: key);

  final User user;
  final dynamic Function() onSuccess;

  @override
  State<ConfirmEmail> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
  bool _isEmailVerified = false;
  Timer? timer;
  final double _animationSize = 150;

  @override
  void initState() {
    super.initState();
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      widget.user.sendEmailVerification();
      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => _checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntroSliderPage(
      backgroundGradient: AppGradients.backgroundGradient,
      foregroundColor: Colors.black,
      title: "Email Verification",
      description: _isEmailVerified
          ? "Email Successfully Verified"
          : "An email has been sent to the address you provided. Please click on the link in the email to verify your account before continuing.",
      lottieFile: _isEmailVerified
          ? LottieController(
              location: 'assets/lottie/email_confirmed.json',
              height: _animationSize,
              repeat: false,
              onComplete: () => widget.onSuccess.call(),
            )
          : LottieController(
              repeat: true,
              location: 'assets/lottie/email_sent.json',
              height: _animationSize),
      optionalChild: _isEmailVerified
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPading.page),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        child: Divider(
                      color: Colors.black.withOpacity(0.8),
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.medium),
                      child: const Text("Didn't receive an email?",
                              style: TextStyle(color: Colors.black))
                          .h5(),
                    ),
                    Expanded(
                        child: Divider(color: Colors.black.withOpacity(0.8))),
                  ]),
                  const SizedBox(
                    height: AppPading.page * 2,
                  ),
                  TextButton(
                      onPressed: () {
                        widget.user.sendEmailVerification();
                      },
                      child: const Text(
                        "Click here to resend",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                                color: AppColors.primary, offset: Offset(0, -2))
                          ],
                          color: Colors.transparent,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      )),
                  const SizedBox(
                    height: AppPading.page,
                  ),
                  const Text(
                    "or",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ).h5(),
                  const SizedBox(
                    height: AppPading.page,
                  ),
                  TextButton(
                      onPressed: () async {
                        await Provider.of<AuthService>(context, listen: false)
                            .signOut();
                      },
                      child: const Text(
                        "Go Back",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                                color: AppColors.primary, offset: Offset(0, -2))
                          ],
                          color: Colors.transparent,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      )),
                ],
              )),
    );
  }

  _checkEmailVerified() async {
    await widget.user.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      timer?.cancel();
      setState(() {
        _isEmailVerified = true;
      });
    }
  }
}
