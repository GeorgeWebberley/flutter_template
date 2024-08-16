import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';
import 'package:flutter_firebase_template/providers/push_notification_provider.dart';
import 'package:flutter_firebase_template/screens/auth/authenticate.dart';
import 'package:flutter_firebase_template/screens/auth/user_setup_flow.dart';
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
                // TODO: Handle if user is null (should not be the case, since user is created when user is authenticated)
                return Scaffold(
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.backgroundGradient,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 1, 22, 24),
                      ),
                    ),
                  ),
                );
              } else {
                return FutureBuilder<String?>(
                    future: Provider.of<LocalStorageProvider?>(context,
                            listen: false)!
                        .get(key: "hasVisited"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        String? visited = snapshot.data;

                        if (visited == null) {
                          return UserSetupFlow(user: user);
                        } else {
                          // Check for any push notifications and handle them appropriately
                          Provider.of<PushNotificationProvider?>(context,
                                  listen: false)
                              ?.setupInteractedMessage(
                                  (RemoteMessage? message) {
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
                        return Scaffold(
                          body: Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                              gradient: AppGradients.backgroundGradient,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 1, 22, 24),
                              ),
                            ),
                          ),
                        );
                      }
                    });
              }
            } else {
              return Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.backgroundGradient,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 1, 22, 24),
                    ),
                  ),
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
    // Example of handling a friend request notification
    if (message["type"] == 'friendRequest' && message["friendId"] != null) {}
    // Can handle other notifications here
  }
}
