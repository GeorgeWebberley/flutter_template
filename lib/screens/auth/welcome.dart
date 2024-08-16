import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/buttons/round_asset_button.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key, required this.setLoginScreen});

  final Function setLoginScreen;

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppPading.page,
              right: AppPading.page,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: AppBorderRadius.small,
                  child: Image.asset("assets/images/food_1.png"),
                ),
                const Text(
                  "Welcome",
                  style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 55,
                      fontWeight: FontWeight.w500),
                ),
                const Text(
                  "We're glad you are here! Get started and create your first meal plan for free!",
                  textAlign: TextAlign.center,
                ).h5(),
                Column(
                  children: [
                    Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppPading.medium),
                        child: AppButton(
                          onPressed: () {
                            widget.setLoginScreen(false);
                          },
                          text: 'Get Started',
                          size: ButtonSize.large,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppPading.medium),
                      child: AppButton(
                        onPressed: () {
                          widget.setLoginScreen(true);
                        },
                        text: 'Sign in',
                        type: ButtonType.secondary,
                        size: ButtonSize.large,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppPading.small,
                          horizontal: AppPading.large),
                      child: Row(children: [
                        const Expanded(
                            child: Divider(
                          color: Colors.black,
                        )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPading.medium),
                          child: const Text("or continue with",
                                  style: TextStyle(color: Colors.black))
                              .h5(),
                        ),
                        const Expanded(child: Divider(color: Colors.black)),
                      ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppPading.small),
                          child: RoundAssetButton(
                            onPressed: () async {
                              AppUser? result = await auth.signInWithGoogle();
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
                            onPressed: () async {
                              AppUser? result = await auth.signInWithApple();
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
                              "assets/icons/apple.png",
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
