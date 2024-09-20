import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_about.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_favourites.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_header.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_privacy.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_settings.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_smart_inventory.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/shared/unit_converter.dart';
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
    // List<Ingredient> exampleList = [
    //   Ingredient(name: 'Red onion', quantity: 0.25, unit: 'pieces'),
    //   Ingredient(name: 'Red onion', quantity: 30, unit: 'grams'),
    //   Ingredient(name: 'Chia seeds', quantity: 30, unit: 'grams'),
    //   Ingredient(name: 'Chia seeds', quantity: 100, unit: 'grams'),
    //   Ingredient(name: 'Chia seeds', quantity: 2, unit: 'tablespoons'),
    //   Ingredient(name: 'Flour', quantity: 200, unit: 'grams'),
    //   Ingredient(name: 'Flour', quantity: 0.5, unit: 'kilograms'),
    //   Ingredient(name: 'Garlic', quantity: 5, unit: 'cloves'),
    //   Ingredient(name: 'Garlic', quantity: 2, unit: 'cloves'),
    //   Ingredient(name: 'Eggs', quantity: 3, unit: 'pieces'),
    //   Ingredient(name: 'Eggs', quantity: 2, unit: 'pieces'),
    //   Ingredient(name: 'Yogurt', quantity: 2, unit: 'cups'),
    //   Ingredient(name: 'Yogurt', quantity: 100, unit: 'milliliters'),
    // ];
    List<Ingredient> exampleList = [
      Ingredient(name: 'Balsamic vinegar', quantity: 15, unit: 'milliliter'),
      Ingredient(name: 'Balsamic vinegar', quantity: 1, unit: 'tablespoon'),
    ];

    List<Ingredient> output = UnitConverter().combineIngredients(exampleList);

    for (var item in output) {
      print(item);
    }

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
              if (user.favourites != null && user.favourites!.isNotEmpty)
                Column(
                  children: [
                    AppBox(
                      child: Column(
                        children: [
                          DetailTile(
                            title: 'Favourite meals',
                            onPressed: () {
                              setScreen(AccountFavourites(
                                      userData: user, backToRoot: backToRoot)
                                  //   AccountSmartInventory(
                                  //   user: user,
                                  //   backToRoot: backToRoot,
                                  // )
                                  );
                            },
                            icon: Icons.favorite,
                            iconColor: AppColors.danger,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: AppPading.large,
                    ),
                  ],
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
                      onPressed: () {
                        setScreen(AccountAbout(
                          backToRoot: backToRoot,
                        ));
                      },
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
