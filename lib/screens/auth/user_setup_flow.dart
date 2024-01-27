import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/screens/auth/confirm_email.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/app_intro_slider.dart';

class UserSetupFlow extends StatefulWidget {
  const UserSetupFlow({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  State<UserSetupFlow> createState() => _UserSetupFlowState();
}

class _UserSetupFlowState extends State<UserSetupFlow> {
  late bool _emailVerified;

  @override
  void initState() {
    super.initState();

    _emailVerified = widget.user.emailVerified;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(seconds: 1),
      firstChild: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width),
        child: ConfirmEmail(
          user: FirebaseAuth.instance.currentUser!,
          onSuccess: () {
            setState(() {
              _emailVerified = true;
            });
          },
        ),
      ),
      secondChild: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width),
        child: AppIntroSlider(user: widget.user),
      ),
      crossFadeState: !_emailVerified
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }
}
