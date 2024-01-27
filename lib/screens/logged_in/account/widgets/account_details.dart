import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_header.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/state/account_state.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';
import 'package:provider/provider.dart';

// To hold the user's info for the account details screen
class UserDetailsInfo {
  UserDetailsInfo(
      {required this.title,
      required this.value,
      this.editable = false,
      required this.key});
  final String title;
  final String key;
  final String value;
  final bool editable;
}

// TODO: Name validation (e.g. length, spaces etc.)
// TODO: Slogan validation (e.g. length)
// TODO: Redo design of tiles so that it matches kia's design
class AccountDetails extends StatefulWidget {
  const AccountDetails({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    List<UserDetailsInfo> settings = [
      UserDetailsInfo(
          title: 'Username',
          value: widget.user.username ?? '',
          key: 'username'),
      UserDetailsInfo(
        title: 'First Name',
        value: widget.user.firstName ?? '',
        key: 'firstName',
        editable: true,
      ),
      UserDetailsInfo(
          title: 'Last name',
          value: widget.user.lastName ?? '',
          key: 'lastName',
          editable: true),
      UserDetailsInfo(title: 'Email', value: widget.user.email, key: 'email'),
    ];
    return Column(
      children: [
        AccountHeader(userData: widget.user),
        Expanded(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppPading.page,
                    0,
                    AppPading.page,
                    AppPading.page,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Provider.of<AccountState>(context, listen: false)
                                  .setScreen('root');
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: AppPading.small),
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.quaternary,
                                size: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var setting in settings)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppPading.large),
                          child: DetailTile(
                              title: setting.title,
                              value: truncateWithEllipsis(25, setting.value),
                              onPressed: setting.editable
                                  ? () {
                                      _openEditInfoDialog(
                                          title: setting.title.toLowerCase(),
                                          key: setting.key,
                                          initialValue: setting.value,
                                          user: widget.user);
                                    }
                                  : null,
                              icon: setting.editable
                                  ? const Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.secondary,
                                    )
                                  : null),
                        ),
                      DetailTile(
                        title: "Password",
                        value: '\u2B24' * 8,
                        onPressed: () {
                          _openChangePasswordDialog(user: widget.user);
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.secondary,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(right: AppPading.large * 2),
                        child: Divider(
                          height: 50,
                          color: Colors.grey[300],
                        ),
                      ),
                      AppButton(
                        onPressed: () {
                          // TODO: Implement account deletion
                        },
                        text: 'Delete Account',
                        color: AppColors.danger,
                      )
                    ],
                  ))),
        )
      ],
    );
  }

  _openChangePasswordDialog({
    required UserData user,
  }) {
    String oldPassword = '';
    String newPassword = '';
    String error = '';

    final _formKey = GlobalKey<FormState>();
    bool loading = false;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        // Use a StatefulBuilder so that we are able to call 'setState' inside the dialog, allowing us to update the UI as the user updates the value in the slider
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPading.large),
                    child: TextFormField(
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Old password'),
                      validator: (value) =>
                          value!.isEmpty ? 'Cannot be empty' : null,
                      onChanged: (value) {
                        setState(() {
                          oldPassword = value;
                        });
                      },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPading.large),
                    child: TextFormField(
                      decoration: textInputDecoration.copyWith(
                          hintText: 'New password'),
                      validator: (value) => value!.length < 6
                          ? 'Password must be 6 or more characters'
                          : null,
                      onChanged: (value) {
                        setState(() {
                          newPassword = value;
                        });
                      },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPading.large),
                    child: TextFormField(
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Confirm new password'),
                      validator: (value) => value! != newPassword
                          ? 'Passwords do not match'
                          : null,
                      obscureText: true,
                    ),
                  ),
                  AppButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });

                        bool result = await _auth.changePassword(
                            oldPassword, newPassword);

                        if (result) {
                          showToast(
                              context: context, message: 'Password updated!');

                          Navigator.pop(context);
                        } else {
                          setState(() {
                            error =
                                'Unable to update password. Please check your details.';
                            loading = false;
                          });
                        }
                      }
                    },
                    loading: loading,
                    text: 'Save',
                    color: AppColors.secondary,
                    size: ButtonSize.medium,
                  ),
                  const SizedBox(
                    height: AppPading.small,
                  ),
                  Text(
                    error,
                    style: const TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.w600),
                  ).h5()
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  _openEditInfoDialog(
      {required String title,
      required String key,
      required UserData user,
      String? initialValue}) {
    String input = '';
    final _formKey = GlobalKey<FormState>();
    bool loading = false;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        // Use a StatefulBuilder so that we are able to call 'setState' inside the dialog, allowing us to update the UI as the user updates the value in the slider
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: initialValue,
                    decoration: textInputDecoration.copyWith(
                        hintText: 'Enter a new $title'),
                    validator: (value) =>
                        value!.isEmpty ? 'Cannot be empty' : null,
                    onChanged: (value) {
                      setState(() {
                        input = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  AppButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        await UserService(uid: user.uid)
                            .updateUserData(key: key, value: input);
                        showToast(
                            context: context, message: 'Saved successfully!');

                        Navigator.pop(context);
                      }
                    },
                    loading: loading,
                    text: 'Save',
                    color: AppColors.secondary,
                    size: ButtonSize.medium,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
