import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/account.dart';
import 'package:flutter_firebase_template/screens/logged_in/screen_one.dart';
import 'package:flutter_firebase_template/screens/logged_in/screen_two.dart';
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
        title: 'Screen one', icon: Icons.home, page: const ScreenOne()),
    NavigationItem(
      title: 'Screen two',
      icon: Icons.add,
      page: const ScreenTwo(),
    ),
    NavigationItem(title: 'Account', icon: Icons.person, page: const Account()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Hide the appbar if 'hideAppBar' is true
        appBar: navigationItems[_selectedIndex].hideAppBar
            ? null
            : AppBar(title: Text(navigationItems[_selectedIndex].title).h2()),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.primary,
          items: navigationItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.title,
                  ))
              .toList(),
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.tertiary,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
        body: navigationItems[_selectedIndex].page);
  }
}
