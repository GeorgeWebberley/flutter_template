import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/buttons/round_asset_button.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key, required this.setLoginScreen}) : super(key: key);

  final Function setLoginScreen;

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // The logo
            Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 80),
                child: Image.asset("assets/images/logo.png")),

            Padding(
              padding: const EdgeInsets.only(
                  left: AppPading.medium,
                  right: AppPading.medium,
                  bottom: AppPading.page),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPading.medium),
                      child: AppButton(
                        onPressed: () {
                          widget.setLoginScreen(false);
                        },
                        text: 'REGISTER',
                        color: AppColors.secondary,
                        size: ButtonSize.large,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPading.medium),
                    child: AppButton(
                      onPressed: () {
                        widget.setLoginScreen(true);
                      },
                      text: 'LOGIN',
                      color: AppColors.quaternary,
                      size: ButtonSize.large,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppPading.medium,
                        horizontal: AppPading.large),
                    child: Row(children: const [
                      Expanded(
                          child: Divider(
                        color: Colors.white,
                      )),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppPading.medium),
                        child: Text("OR CONTINUE WITH",
                            style: TextStyle(color: Colors.white)),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppPading.small),
                        child: RoundAssetButton(
                          onPressed: () async {
                            AppUser? result = await _auth.signInWithGoogle();
                            if (result == null) {
                              showToast(
                                  context: context,
                                  message:
                                      'Could not register with those credentials',
                                  color: AppColors.danger);
                            }
                            setState(() {});
                          },
                          child: Image.asset(
                            "assets/icons/google.png",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppPading.small),
                        child: RoundAssetButton(
                          onPressed: () {},
                          child: Image.asset(
                            "assets/icons/apple.png",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppPading.small),
                        child: RoundAssetButton(
                          onPressed: () {},
                          child: Image.asset(
                            "assets/icons/facebook.png",
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
