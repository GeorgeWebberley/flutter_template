import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/buttons/round_asset_button.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart' as validator;

class Register extends StatefulWidget {
  const Register({Key? key, required this.setLoginScreen}) : super(key: key);
  final Function setLoginScreen;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String name = '';
  String password = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        // resizeToAvoidBottomInset: false,
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: AppBorderRadius.small,
                      child: Image.asset("assets/images/food_2.png"),
                    ),
                    const SizedBox(
                      height: AppPading.large,
                    ),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 40,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: AppPading.large,
                    ),
                    const Text(
                      "Go ahead and sign up, your personal meal planner is waiting for you!",
                      textAlign: TextAlign.center,
                    ).h5(),
                    const SizedBox(
                      height: AppPading.page * 2,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            autocorrect: false,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: textInputDecoration.copyWith(
                                prefixIcon: const Icon(Icons.person_outline),
                                hintText: 'Display Name',
                                errorStyle: const TextStyle(color: Colors.red)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter a display name';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                name = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autocorrect: false,
                            decoration: textInputDecoration.copyWith(
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: 'Email',
                                errorStyle: const TextStyle(color: Colors.red)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter an email';
                              } else if (!validator.isEmail(value)) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autocorrect: false,
                            decoration: textInputDecoration.copyWith(
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: 'Password',
                                errorStyle: const TextStyle(color: Colors.red)),
                            validator: (value) => value!.length < 6
                                ? 'Password must be 6 or more characters'
                                : null,
                            obscureText: true,
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autocorrect: false,
                            decoration: textInputDecoration.copyWith(
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: 'Confirm Password',
                                errorStyle: const TextStyle(color: Colors.red)),
                            validator: (value) => value! != password
                                ? 'Passwords do not match'
                                : null,
                            obscureText: true,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AppButton(
                            loading: loading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });

                                // TODO: add first and last name to registerWithEmailAndPassword
                                var result =
                                    await auth.registerWithEmailAndPassword(
                                        email, password);

                                if (result is String) {
                                  showToast(
                                      context: context,
                                      message: result,
                                      color: AppColors.danger);
                                  setState(() {
                                    loading = false;
                                  });
                                } else {
                                  await createUserDbEntry(appUser: result);
                                }
                              }
                            },
                            text: 'Register',
                            size: ButtonSize.large,
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            onPressed: () {
                              widget.setLoginScreen(true);
                            },
                            text: 'I already have an account',
                            type: ButtonType.secondary,
                            size: ButtonSize.large,
                          ),
                          const SizedBox(
                            height: 20,
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
                              const Expanded(
                                  child: Divider(color: Colors.black)),
                            ]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(AppPading.small),
                                child: RoundAssetButton(
                                  onPressed: () async {
                                    AppUser? result =
                                        await auth.signInWithGoogle();
                                    if (result == null) {
                                      showToast(
                                          context: context,
                                          message:
                                              'Could not register with those credentials',
                                          color: AppColors.danger);
                                      setState(() {});
                                    } else {
                                      await createUserDbEntry(appUser: result);
                                    }
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
                                    AppUser? result =
                                        await auth.signInWithApple();
                                    if (result == null) {
                                      showToast(
                                          context: context,
                                          message:
                                              'Could not register with those credentials',
                                          color: AppColors.danger);
                                      setState(() {});
                                    } else {
                                      await createUserDbEntry(appUser: result);
                                    }
                                  },
                                  child: Image.asset(
                                    "assets/icons/apple.png",
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> createUserDbEntry({
    required AppUser appUser,
  }) async {
    try {
      await UserService(uid: appUser.uid).createUserDbEntry(
        appUser: appUser,
        name: name,
      );
    } catch (error) {
      debugPrint('Error creating user db entry: $error');
      throw error;
    }
  }
}
