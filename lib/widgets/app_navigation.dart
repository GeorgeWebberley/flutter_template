import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/providers/in_app_purchase_provider.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/account.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/view_meal_plans_screen.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/ai_chat_screen.dart';
import 'package:flutter_firebase_template/screens/logged_in/subscription/subscription_screen.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:provider/provider.dart';

class NavigationItem {
  String title;
  IconData icon;
  Widget page;
  bool hideAppBar;

  NavigationItem(
      {required this.title,
      required this.icon,
      required this.page,
      this.hideAppBar = false});
}

class AppNavigation extends StatefulWidget {
  const AppNavigation({Key? key}) : super(key: key);
  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserService userService =
        UserService(uid: Provider.of<AppUser?>(context)?.uid);

    return StreamBuilder<UserData>(
        stream: userService.userDataStream,
        builder: (context, snapshot) {
          List<NavigationItem> navigationItems = [
            NavigationItem(
                title: 'Meal Plans',
                icon: Icons.home,
                page: ViewMealPlansScreen(
                  changeNavigationIndex: _onItemTapped,
                )),
            NavigationItem(
              title: 'Meal Hub',
              hideAppBar: true,
              icon: Icons.chat,
              page: AiChatScreen(
                changeNavigationIndex: _onItemTapped,
              ),
            ),
            NavigationItem(
                title: 'My Profile',
                icon: Icons.person,
                page: const Account(),
                hideAppBar: true),
          ];

          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.hasData) {
            UserData userData = snapshot.data!;

            print("HERE 1");

            if (userData.isSubscribed != true &&
                userData.freeTrialCredits == null) {
              print("HERE 2");

              // TODO: Need to allow users to also see this screen when on a free trial? Since they will want to bring it up when subscribing.
              // Will also require updating the logic on the SubscriptionScreen to allow for free trial users to see the screen.
              return SubscriptionScreen(
                userData: userData,
              );
            } else {
              return Container(
                decoration: const BoxDecoration(
                    gradient: AppGradients.backgroundGradient),
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: navigationItems[_selectedIndex].hideAppBar
                        ? null
                        : AppBar(
                            title: Text(
                              navigationItems[_selectedIndex].title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ).h3(),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                    bottomNavigationBar: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.buttonPrimaryGradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: BottomNavigationBar(
                          backgroundColor: Colors.transparent,
                          items: navigationItems
                              .map((item) => BottomNavigationBarItem(
                                    icon: Icon(
                                      item.icon,
                                      size: _selectedIndex ==
                                              navigationItems.indexOf(item)
                                          ? 30
                                          : 24,
                                    ),
                                    label: item.title,
                                  ))
                              .toList(),
                          currentIndex: _selectedIndex,
                          selectedItemColor:
                              const Color.fromARGB(255, 255, 229, 135),
                          unselectedItemColor: Colors.white,
                          selectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 10,
                          ),
                          onTap: _onItemTapped,
                          elevation: 0,
                        ),
                      ),
                    ),
                    body: navigationItems[_selectedIndex].page),
              );
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
