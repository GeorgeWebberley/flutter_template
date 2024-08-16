import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
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
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    String name = truncateWithEllipsis(
        20,
        (widget.userData.firstName == null && widget.userData.lastName == null)
            ? "George Webberley"
            : "${widget.userData.firstName ?? ''} ${widget.userData.lastName ?? ''}"
                .trim());

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.small,
          boxShadow: [AppBoxShadow.small]),
      child: Stack(children: [
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            iconSize: 20,
            icon: Icon(Icons.edit),
            color: Colors.grey.withOpacity(0.8),
            onPressed: () {
              print('edit profile');
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppPading.page),
          child: Column(
            children: [
              Row(),
              Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black))
                  .h5(),
              Text(truncateWithEllipsis(18, widget.userData.email),
                      style: const TextStyle(color: Colors.black))
                  .p(),
            ],
          ),
        ),
      ]),
    );
  }
}
