import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_dialog.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class AccountHeader extends StatefulWidget {
  const AccountHeader({
    super.key,
    required this.userData,
  });

  final UserData userData;

  @override
  State<AccountHeader> createState() => _AccountHeaderState();
}

class _AccountHeaderState extends State<AccountHeader> {
  @override
  Widget build(BuildContext context) {
    return AppBox(
      child: Stack(children: [
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            iconSize: 20,
            icon: const Icon(Icons.edit),
            color: Colors.grey.withOpacity(0.8),
            onPressed: () {
              editNameDialog(context);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppPading.page, vertical: AppPading.page * 1.5),
          child: Column(
            children: [
              const Row(),
              if (widget.userData.name != null)
                Text(widget.userData.name ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.black))
                    .h5()
              else
                const Text("No name set",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.black))
                    .h5(),
              Text(truncateWithEllipsis(40, widget.userData.email),
                      style: const TextStyle(color: Colors.black))
                  .p(),
            ],
          ),
        ),
      ]),
    );
  }

  void editNameDialog(BuildContext context) {
    String? name = widget.userData.name;
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AppDialog(
              loading: loading,
              content: TextField(
                decoration: textInputDecoration.copyWith(
                  prefixIcon: const Icon(Icons.person_outline),
                  hintText: 'First name',
                ),
                onChanged: (value) {
                  dialogSetState(() {
                    name = value;
                  });
                },
              ),
              title: "Update your name",
              onSave: () async {
                dialogSetState(() {
                  loading = true;
                });
                await UserService(uid: widget.userData.uid).updateUserData(
                  key: "name",
                  value: name,
                );
                Navigator.of(context).pop();
              });
        });
      },
    );
  }
}
