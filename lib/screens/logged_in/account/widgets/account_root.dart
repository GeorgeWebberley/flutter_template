import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_header.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_privacy.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_settings.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';
import 'package:provider/provider.dart';

class AccountRoot extends StatelessWidget {
  const AccountRoot({
    super.key,
    required this.user,
    required this.setScreen,
    required this.backToRoot,
  });

  final UserData user;
  final void Function(Widget) setScreen;
  final void Function() backToRoot;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w500),
        ).h3(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPading.page),
          child: Column(
            children: [
              const SizedBox(height: AppPading.large),
              AccountHeader(userData: user),
              const SizedBox(
                height: AppPading.large,
              ),
              AppBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailTile(
                      title: 'Settings',
                      onPressed: () {
                        setScreen(AccountSettings(
                          user: user,
                          backToRoot: backToRoot,
                        ));
                      },
                      icon: Icons.settings,
                      iconColor: Colors.black.withOpacity(0.6),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.large),
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
                          SlideNavigator(
                              builder: (context, _, __) =>
                                  const AccountPrivacy()),
                        );
                      },
                      icon: Icons.privacy_tip,
                      iconColor: AppColors.green,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.large),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.large),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.large),
                      child: Divider(
                        height: 0,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
