import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:string_validator/string_validator.dart' as validator;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
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
                          'Forgot password',
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
                              const Text(
                                "Enter in your email address. You will be sent instructions to reset your password.",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ).h4(),
                              const SizedBox(
                                height: 40,
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
                              AppButton(
                                loading: loading,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _auth.sendResetPasswordEmail(email: email);
                                    showToast(
                                        context: context,
                                        message:
                                            'If you have an account, an email will be sent to your inbox.',
                                        color: AppColors.secondary);
                                  }
                                },
                                text: 'Confirm',
                                color: AppColors.secondary,
                                size: ButtonSize.large,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Back to login',
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
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
            ),
          ],
        ));
  }
}
