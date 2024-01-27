import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/providers/push_notification_provider.dart';
import 'package:flutter_firebase_template/screens/auth/authenticate.dart';
import 'package:flutter_firebase_template/screens/auth/user_setup_flow.dart';
import 'package:flutter_firebase_template/screens/logged_in/user_profile.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/widgets/app_navigation.dart';
import 'package:provider/provider.dart';

// Wrapper class, to handle switching between auth states
class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final AppUser? user = Provider.of<AppUser?>(context);
    if (user == null) {
      return const Authenticate();
    } else {
      return FutureBuilder<UserData?>(
          future: UserService(uid: user.uid).getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              UserData? userData = snapshot.data;

              if (userData == null) {
                return UserSetupFlow(user: user);
              } else {
                // Check for any push notifications and handle them appropriately
                Provider.of<PushNotificationProvider?>(context, listen: false)
                    ?.setupInteractedMessage((RemoteMessage? message) {
                  if (message?.data != null) {
                    _handleMessage(
                        context: context,
                        message: message!.data,
                        currentUser: userData);
                  }
                });
                return const AppNavigation();
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                ),
              );
            }
          });
    }
  }

  _handleMessage(
      {required BuildContext context,
      required Map<String, dynamic> message,
      required UserData currentUser}) async {
    if (message["type"] == 'friendRequest' && message["friendId"] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfile(
                  friendId: message["friendId"],
                  currentUser: currentUser,
                )),
      );
    }
    // Can handle other notifications here
  }
}
