import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';
import 'package:flutter_firebase_template/providers/local_notification_provider.dart';
import 'package:flutter_firebase_template/providers/share_provider.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/ingredient_tile.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/shared/unit_converter.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({
    super.key,
    required this.totalIngredients,
  });

  final List<Ingredient> totalIngredients; // New field for total ingredients

  @override
  Widget build(BuildContext context) {
    List<Ingredient> combinedIngredients =
        UnitConverter().combineIngredients(totalIngredients);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppPading.page),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fmd_bad),
                        onPressed: () async {
                          await Provider.of<LocalNotificationProvider>(context,
                                  listen: false)
                              .showShoppingListNotification(combinedIngredients
                                  .map((ingredient) =>
                                      "${ingredient.name.capitalize()} : ${formatIngredientQuantity(ingredient)}")
                                  .toList());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () async {
                          String text = "Shopping List\n\n";
                          for (Ingredient ingredient in combinedIngredients) {
                            text +=
                                "${ingredient.name.capitalize()} : ${formatIngredientQuantity(ingredient)}\n";
                          }

                          await Provider.of<ShareProvider>(context,
                                  listen: false)
                              .shareText(text);
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppTitle(title: "Shopping list"),
                    AppBox(
                      child: Padding(
                        padding: const EdgeInsets.all(AppPading.page),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Ingredients").h4(),
                            const SizedBox(
                              height: AppPading.large,
                            ),
                            ...combinedIngredients
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppPading.medium),
                                    child: IngredientTile(
                                      ingredient: entry,
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
