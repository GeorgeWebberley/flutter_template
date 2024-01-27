import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/screens/auth/forgot_password.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key, required this.setLoginScreen}) : super(key: key);
  final Function setLoginScreen;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String username = '';
  String password = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          )),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(color: Colors.white),
                  ).h1(),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Image(
                  image: AssetImage('assets/images/logo.png'),
                  height: 200,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Divider(
                          height: 70,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Email',
                              errorStyle: const TextStyle(color: Colors.white)),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter an email' : null,
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
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Password',
                              errorStyle: const TextStyle(color: Colors.white)),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    FadeNavigator(
                                        builder: (context, _, __) =>
                                            const ForgotPassword()),
                                  );
                                },
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        AppButton(
                          loading: loading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              AppUser? result = await _auth
                                  .signInWithEmailAndPassword(email, password);

                              if (result == null) {
                                setState(() {
                                  loading = false;
                                });
                                showToast(
                                    context: context,
                                    message:
                                        'Could not login with those credentials',
                                    color: AppColors.danger);
                              }
                            }
                          },
                          text: 'Sign in',
                          color: AppColors.secondary,
                          size: ButtonSize.large,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            widget.setLoginScreen(false);
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ).h3(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
