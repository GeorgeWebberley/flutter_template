import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
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
                      child: Image.asset("assets/images/food_4.png"),
                    ),
                    const SizedBox(
                      height: AppPading.large,
                    ),
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 40,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: AppPading.large,
                    ),
                    const Text(
                      "Don't worry! It happens. Enter your email address and we'll send you a link.",
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
                            decoration: textInputDecoration.copyWith(
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: 'Email',
                                errorStyle:
                                    const TextStyle(color: Colors.white)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter an email';
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
                                auth.sendResetPasswordEmail(email: email);
                                showToast(
                                    context: context,
                                    message:
                                        'If you have an account, an email will be sent to your inbox.',
                                    color: AppColors.secondary);
                              }
                            },
                            text: 'Submit',
                            size: ButtonSize.large,
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            loading: loading,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'Back to login',
                            type: ButtonType.secondary,
                            size: ButtonSize.large,
                          ),
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
}
