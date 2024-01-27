import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:string_validator/string_validator.dart' as validator;

class Register extends StatefulWidget {
  const Register({Key? key, required this.setLoginScreen}) : super(key: key);
  final Function setLoginScreen;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String password = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        // resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                gradient: AppGradients.backgroundGradient,
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
                      'Register',
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 50),
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
                                errorStyle:
                                    const TextStyle(color: Colors.white)),
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
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Password',
                                errorStyle:
                                    const TextStyle(color: Colors.white)),
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
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Confirm Password',
                                errorStyle:
                                    const TextStyle(color: Colors.white)),
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

                                var result =
                                    await _auth.registerWithEmailAndPassword(
                                        email, password);

                                if (result is String) {
                                  setState(() {
                                    loading = false;
                                  });
                                  showToast(
                                      context: context,
                                      message: result,
                                      color: AppColors.danger);
                                }
                              }
                            },
                            text: 'Register',
                            color: AppColors.secondary,
                            size: ButtonSize.large,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              widget.setLoginScreen(true);
                            },
                            child: const Text(
                              'Sign in',
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
          ),
        ));
  }
}
