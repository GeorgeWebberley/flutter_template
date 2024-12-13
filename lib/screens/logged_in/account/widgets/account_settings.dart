import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_dialog.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';
import 'package:flutter_firebase_template/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({
    super.key,
    required this.user,
    required this.backToRoot,
  });

  final UserData user;
  final void Function() backToRoot;

  @override
  Widget build(BuildContext context) {
    User? currentAuth = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: backToRoot,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppPading.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTitle(title: 'Account Administration'),
            AppBox(
              child: Column(
                children: [
                  if (currentAuth?.providerData
                          .map((e) => e.providerId)
                          .contains("password") ==
                      true)
                    DetailTile(
                      title: "Change Password",
                      onPressed: () {
                        editNameDialog(context);
                      },
                    ),
                  if (currentAuth?.providerData
                          .map((e) => e.providerId)
                          .contains("password") ==
                      true)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.large),
                      child: Divider(
                        height: 0,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  DetailTile(
                    title: "Delete Account",
                    onPressed: () {
                      deleteAccountDialog(context);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  deleteAccountDialog(BuildContext context) {
    bool needsPassword = false;
    String? password;
    AuthService auth = Provider.of<AuthService>(context, listen: false);
    bool loading = false;

    showDialog<void>(
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (stateContext, dialogSetState) {
              return AppDialog(
                loading: loading,
                title:
                    needsPassword ? 'Re-enter your password' : 'Delete Account',
                buttonText: "Confirm",
                content: needsPassword
                    ? TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Enter your password'),
                        onChanged: (value) {
                          dialogSetState(() {
                            password = value;
                          });
                        },
                        obscureText: true,
                      )
                    : const Text(
                        'Are you sure you want to delete your account? This action cannot be undone.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ).h5(),
                onSave: () async {
                  dialogSetState(() {
                    loading = true;
                  });
                  String? result = needsPassword
                      ? await auth
                          .reauthenticateWithEmailAndDelete(password ?? '')
                      : await auth.deleteAccount();
                  if (result == "reauthenticate") {
                    dialogSetState(() {
                      needsPassword = true;
                      loading = false;
                    });

                    return;
                  }
                  if (result != null) {
                    showToast(
                        context: context,
                        message: "Password incorrect",
                        color: AppColors.danger);
                    dialogSetState(() {
                      loading = false;
                    });
                  } else {
                    // Loop through LocalStorageKeys and remove all data
                    await Provider.of<LocalStorageProvider>(context,
                            listen: false)
                        .cleanup();

                    await UserService(uid: user.uid).deleteUserDbEntry();
                    await auth.signOut();

                    showToast(
                        context: context,
                        message: 'Account deleted successfully!');

                    // Return to wrapper
                    Navigator.of(context).pop();
                    // Navigate back to wrapper screen
                    Navigator.pushAndRemoveUntil(
                        context,
                        SlideNavigator(
                            builder: (context, _, __) => const Wrapper()),
                        (route) => false);
                  }
                },
              );
            }));
  }

  void editNameDialog(BuildContext context) {
    String? password;
    String? confirmPassword;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AppDialog(
              content: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      obscureText: true,
                      autocorrect: false,
                      decoration: textInputDecoration.copyWith(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Password',
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) => value!.length < 6
                          ? 'Password must be 6 or more characters'
                          : null,
                      onChanged: (value) {
                        dialogSetState(() {
                          password = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: AppPading.page,
                    ),
                    TextFormField(
                      obscureText: true,
                      autocorrect: false,
                      decoration: textInputDecoration.copyWith(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Confirm password',
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) =>
                          value! != password ? 'Passwords do not match' : null,
                      onChanged: (value) {
                        dialogSetState(() {
                          confirmPassword = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              title: "Set a new password",
              onSave: () async {
                if (formKey.currentState!.validate()) {
                  bool result =
                      await Provider.of<AuthService>(context, listen: false)
                          .changePassword(password!, confirmPassword!);

                  if (!result) {
                    showToast(
                        context: context,
                        message: "Error setting password",
                        color: AppColors.danger);
                  }
                }
              });
        });
      },
    );
  }
}
