import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/account.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/view_meal_plans_screen.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/ai_chat_screen.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/text.dart';

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
    return Container(
      decoration:
          const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navigationItems[_selectedIndex].hideAppBar
              ? null
              : AppBar(
                  title: Text(
                    navigationItems[_selectedIndex].title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
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
                            size:
                                _selectedIndex == navigationItems.indexOf(item)
                                    ? 30
                                    : 24,
                          ),
                          label: item.title,
                        ))
                    .toList(),
                currentIndex: _selectedIndex,
                selectedItemColor: const Color.fromARGB(255, 255, 229, 135),
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
}
