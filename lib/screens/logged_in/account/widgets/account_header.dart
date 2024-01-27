import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/user_avatar.dart';

class AccountHeader extends StatefulWidget {
  const AccountHeader({
    Key? key,
    required this.userData,
  }) : super(key: key);

  final UserData userData;

  @override
  State<AccountHeader> createState() => _AccountHeaderState();
}

class _AccountHeaderState extends State<AccountHeader> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    String _name = truncateWithEllipsis(
        20,
        (widget.userData.firstName == null && widget.userData.lastName == null)
            ? ""
            : "${widget.userData.firstName ?? ''} ${widget.userData.lastName ?? ''}"
                .trim());

    String _username = truncateWithEllipsis(20, widget.userData.username!);

    return Container(
      color: AppColors.quaternary,
      padding: const EdgeInsets.all(AppPading.page),
      child: Stack(clipBehavior: Clip.none, children: [
        Row(
          children: [
            UserAvatar(user: widget.userData),
            const SizedBox(
              width: AppPading.large,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name == "" ? _username : _name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.white))
                    .h3(),
                Text(
                        truncateWithEllipsis(18,
                            _name == "" ? widget.userData.email : _username),
                        style: const TextStyle(color: Colors.white))
                    .h5(),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: -20,
          right: 0,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
              ),
              onPressed: () async {
                await _auth.signOut();
              },
              child: const Text('logout', style: TextStyle(color: Colors.white))
                  .h5()),
        ),
      ]),
    );
  }
}
