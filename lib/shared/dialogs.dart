import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/services/friend_service.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

// Displays confirmation to delete friend. Returns a message to be displayed to the user.
Future<String?> removeFriendConfirmationDialog(
    {required BuildContext context,
    required String currentUserId,
    required String friendId}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Remove from your friends?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                await FriendService(uid: currentUserId).removeFriend(friendId);
                Navigator.pop(dialogContext, 'Friend removed!');
              },
              child: const Text('Confirm')),
        ],
      );
    },
  );
}

void showToast(
    {required BuildContext context,
    required String message,
    EdgeInsetsGeometry? margin,
    Color? color = AppColors.secondary}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: margin,
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ),
  );
}
