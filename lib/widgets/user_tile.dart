import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/services/friend_service.dart';
import 'package:flutter_firebase_template/shared/constants.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/shared/enums.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  const UserTile(
      {Key? key,
      required this.user,
      this.onTap,
      this.trailing,
      this.friendStatus = FriendStatus.friend})
      : super(key: key);

  final UserData user;
  final void Function()? onTap;
  final FriendStatus friendStatus;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<AppUser?>(context);
    FriendService _friendService = FriendService(uid: _currentUser!.uid);

    String _title = truncateWithEllipsis(
        20,
        (user.firstName == null && user.lastName == null)
            ? user.username!
            : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim());

    String _subtitle = truncateWithEllipsis(
        20,
        (user.firstName == null && user.lastName == null)
            ? ""
            : user.username!);

    return Material(
      elevation: 2,
      borderRadius: AppBorderRadius.large,
      child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.quaternary, width: 1),
              borderRadius: AppBorderRadius.large),
          title: Text(_title),
          // subtitle: Text(user.slogan ?? ''),
          subtitle: Text(_subtitle),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.imageUrl ??
                placeholderNetworkImage), // no matter how big it is, it won't overflow
          ),
          trailing: trailing ??
              (friendStatus == FriendStatus.friend
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        String? message = await removeFriendConfirmationDialog(
                            context: context,
                            currentUserId: _currentUser.uid,
                            friendId: user.uid);
                        if (message != null) {
                          showToast(context: context, message: message);
                        }
                      },
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.danger,
                          ),
                          onPressed: () {
                            _friendService.rejectFriendRequest(user.uid);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: AppColors.secondary,
                          ),
                          onPressed: () {
                            _friendService.acceptFriendRequest(user.uid);
                          },
                        )
                      ],
                    ))),
    );
  }
}
