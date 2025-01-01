import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';
import 'package:flutter_firebase_template/providers/push_notification_provider.dart';
import 'package:flutter_firebase_template/screens/auth/authenticate.dart';
import 'package:flutter_firebase_template/screens/auth/user_setup_flow.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/meal_plan_root.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/widgets/app_navigation.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
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
    print("Refreshing user state!");
    print("User: $user");
    if (user == null) {
      print("User is not authenticated");

      return const Authenticate();
    } else {
      print("User is authenticated");
      print(user.email);

      return StreamBuilder<UserData?>(
          stream: UserService(uid: user.uid).userDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              UserData? userData = snapshot.data;

              if (userData == null) {
                return Scaffold(
                  body: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.backgroundGradient,
                    ),
                    child: Center(
                      child: AppButton(
                          onPressed: () async {
                            await AuthService().signOut();
                          },
                          text: "Test"),
                      //     CircularProgressIndicator(
                      //   color: Color.fromARGB(255, 1, 22, 24),
                      // ),
                    ),
                  ),
                );
              } else {
                if (userData.hasCompletedTutorial == true) {
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
                } else {
                  return UserSetupFlow(user: user);
                }
                // return FutureBuilder<String?>(
                //     future: Provider.of<LocalStorageProvider?>(context,
                //             listen: false)!
                //         .get(key: "${user.uid}-${LocalStorageKeys.hasVisited}"),
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState == ConnectionState.done) {
                //         String? visited = snapshot.data;

                //         if (visited == null) {
                //           return UserSetupFlow(user: user);
                //         } else {
                //           // Check for any push notifications and handle them appropriately
                //           Provider.of<PushNotificationProvider?>(context,
                //                   listen: false)
                //               ?.setupInteractedMessage(
                //                   (RemoteMessage? message) {
                //             if (message?.data != null) {
                //               _handleMessage(
                //                   context: context,
                //                   message: message!.data,
                //                   currentUser: userData);
                //             }
                //           });

                //           return const AppNavigation();
                //         }
                //       } else {
                //         return Scaffold(
                //           body: Container(
                //             height: double.infinity,
                //             decoration: const BoxDecoration(
                //               gradient: AppGradients.backgroundGradient,
                //             ),
                //             child: const Center(
                //               child: CircularProgressIndicator(
                //                 color: Color.fromARGB(255, 1, 22, 24),
                //               ),
                //             ),
                //           ),
                //         );
                //       }
                //     });
              }
            } else {
              return Scaffold(
                body: Container(
                  height: double.infinity,
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
    if (message["type"] == 'mealplanReady' && message["mealplanId"] != null) {
      Navigator.push(
        context,
        FadeNavigator(
          builder: (context, _, __) => MealPlanRoot(
            mealPlanId: message["mealplanId"],
          ),
        ),
      );
    }
  }
}
