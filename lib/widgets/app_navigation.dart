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
  int _selectedIndex = 2;

  List<NavigationItem> navigationItems = [
    NavigationItem(
        title: 'Meal Plans',
        icon: Icons.home,
        page: const ViewMealPlansScreen()),
    NavigationItem(
      title: 'Chat',
      hideAppBar: true,
      icon: Icons.chat,
      page: const AiChatScreen(),
    ),
    NavigationItem(
        title: 'My Profile',
        icon: Icons.person,
        page: const Account(),
        hideAppBar: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // floatingActionButton: _selectedIndex == 1
          //     ? null
          //     : FloatingActionButton(
          //         onPressed: () {},
          //         //params
          //       ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.endContained,
          // bottomNavigationBar: AnimatedBottomNavigationBar(
          //   icons: [
          //     Icons.abc,
          //     Icons.person,
          //     Icons.settings,
          //     Icons.wordpress_outlined
          //   ],
          //   activeIndex: _selectedIndex,
          //   gapLocation: GapLocation.end,
          //   notchSmoothness: NotchSmoothness.verySmoothEdge,
          //   // leftCornerRadius: _selectedIndex == 1 ? null : 32,
          //   // rightCornerRadius: _selectedIndex == 1 ? null : 32,
          //   onTap: (index) => setState(() => _selectedIndex = index),
          //   //other params
          // ),
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
