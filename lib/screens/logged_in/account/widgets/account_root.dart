import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_header.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_privacy.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/state/account_state.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';
import 'package:provider/provider.dart';

class AccountRoot extends StatelessWidget {
  const AccountRoot({super.key, required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AccountHeader(userData: user),
          const SizedBox(
            height: AppPading.large,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppBorderRadius.small,
                boxShadow: [AppBoxShadow.small]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailTile(
                  title: 'Settings',
                  onPressed: () {},
                  icon: Icons.settings,
                  iconColor: Colors.black.withOpacity(0.6),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppPading.large),
                  child: Divider(
                    height: 0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                DetailTile(
                  title: 'Data Privacy',
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AccountPrivacy(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0,
                              0.0); // Start from the right side of the screen
                          const end = Offset
                              .zero; // End at the current position (no offset)
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: Icons.privacy_tip,
                  iconColor: AppColors.green,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppPading.large),
                  child: Divider(
                    height: 0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                DetailTile(
                  title: 'About Nutriveat',
                  onPressed: () {},
                  icon: Icons.info,
                  iconColor: AppColors.primary,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppPading.large),
                  child: Divider(
                    height: 0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                DetailTile(
                  title: 'Logout',
                  onPressed: () async {
                    await Provider.of<AuthService>(context, listen: false)
                        .signOut();
                  },
                  icon: Icons.logout,
                  iconColor: AppColors.primary,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
