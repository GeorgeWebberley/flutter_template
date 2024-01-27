import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/services/friend_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/constants.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/shared/enums.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';

class UserProfile extends StatefulWidget {
  const UserProfile(
      {Key? key, required this.friendId, required this.currentUser})
      : super(key: key);

  // TODO: Instead of passing in currentUser maybe we should keep it in a provider/state
  final String friendId;
  final UserData currentUser;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool buttonLoading = false;

  @override
  Widget build(BuildContext context) {
    final friendService = FriendService(uid: widget.currentUser.uid);
    final userService = UserService(uid: widget.currentUser.uid);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppPading.page),
        child: Center(
          // We already have the user data when navigating to this page, however setup
          // a stream with the friends document in firebase so that we can track the
          // friend status 'live'
          child: StreamBuilder<UserData>(
              stream: userService.friendData(widget.friendId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserData friendData = snapshot.data!;

                  bool userHasNoName = (friendData.firstName == null &&
                      friendData.lastName == null);

                  String title = userHasNoName
                      ? friendData.username!
                      : '${friendData.firstName ?? ''} ${friendData.lastName ?? ''}'
                          .trim();

                  String subtitle = userHasNoName ? '' : friendData.username!;
                  FriendStatus friendStatus = FriendStatus.none;

                  if (widget.currentUser.friends != null &&
                      widget.currentUser.friends!.contains(friendData.uid)) {
                    friendStatus = FriendStatus.friend;
                  } else if (widget.currentUser.friendRequests != null &&
                      widget.currentUser.friendRequests!
                          .contains(friendData.uid)) {
                    friendStatus = FriendStatus.requestReceived;
                  } else if (friendData.friendRequests != null &&
                      friendData.friendRequests!
                          .contains(widget.currentUser.uid)) {
                    friendStatus = FriendStatus.requestSent;
                  }

                  return SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(100),
                            child: CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(
                                  friendData.imageUrl ??
                                      placeholderNetworkImage),
                            ),
                          ),
                          const SizedBox(height: AppPading.large),
                          Text(title).h1(),
                          Text(
                            subtitle,
                            style: const TextStyle(color: AppColors.secondary),
                          ).h3(),

                          const SizedBox(height: AppPading.large * 2),
                          // Button should be 'Remove friend' if user is already a friend
                          AppButton(
                            loading: buttonLoading,
                            onPressed: (friendStatus ==
                                    FriendStatus.requestSent)
                                ? null
                                : () async {
                                    setState(() {
                                      buttonLoading = true;
                                    });
                                    String? message;
                                    if (friendStatus == FriendStatus.none) {
                                      await friendService
                                          .requestFriend(friendData.uid);
                                      message = 'Request sent!';
                                    } else if (friendStatus ==
                                        FriendStatus.requestReceived) {
                                      await friendService
                                          .acceptFriendRequest(friendData.uid);
                                      message = 'Friend added!';
                                    } else {
                                      message =
                                          await removeFriendConfirmationDialog(
                                              context: context,
                                              currentUserId:
                                                  widget.currentUser.uid,
                                              friendId: friendData.uid);
                                    }
                                    setState(() {
                                      buttonLoading = false;
                                    });
                                    // Pop the context and a show a success snackbar message
                                    if (message != null) {
                                      showToast(
                                        context: context,
                                        message: message,
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                            text: (friendStatus == FriendStatus.none)
                                ? 'Add Friend'
                                : (friendStatus == FriendStatus.requestReceived)
                                    ? 'Accept Friend Request'
                                    : (friendStatus == FriendStatus.requestSent)
                                        ? 'Request Sent'
                                        : 'Unfriend',
                            color: AppColors.quaternary,
                          ),
                          const SizedBox(height: AppPading.large * 2),
                        ]),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
    );
  }
}
