import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';
import 'package:flutter_firebase_template/providers/share_provider.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/ingredient_tile.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/shared/unit_converter.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({
    super.key,
    required this.totalIngredients,
  });

  final List<Ingredient> totalIngredients; // New field for total ingredients

  @override
  Widget build(BuildContext context) {
    List<Ingredient> combinedIngredients = UnitConverter()
        .combineIngredients(totalIngredients)
      ..sort((a, b) =>
          a.name.compareTo(b.name)); // New field for combined ingredients

    // Group the ingredients by ingredientType
    Map<String, List<Ingredient>> groupedIngredients = groupBy(
        combinedIngredients,
        (Ingredient ingredient) => ingredient.ingredientType ?? "other");

    // Sort the groups alphabetically
    groupedIngredients = Map.fromEntries(groupedIngredients.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)));

    // // Print the grouped ingredients
    // groupedIngredients.forEach((ingredientType, ingredientList) {
    //   print('$ingredientType:');
    //   ingredientList.forEach((ingredient) => print(' - ${ingredient.name}'));
    // });
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
                  child: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      String text = "** 🛒 Shopping List 🛒 **\n\n";

                      groupedIngredients
                          .forEach((ingredientType, ingredientList) {
                        if (ingredientType != "other") {
                          text += '** ⭐ $ingredientType:**\n';
                        }
                        for (Ingredient ingredient in ingredientList) {
                          text +=
                              " - ${ingredient.name.capitalize()} : ${formatIngredientQuantity(ingredient)}\n";
                        }
                        text += '\n';
                      });

                      await Provider.of<ShareProvider>(context, listen: false)
                          .shareText(text);
                    },
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
                            ...groupedIngredients.keys
                                .map(
                                  (ingredientType) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (ingredientType != "other")
                                        Text(
                                          ingredientType.capitalize(),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ).h5(),
                                      const SizedBox(
                                        height: AppPading.small,
                                      ),
                                      ...groupedIngredients[ingredientType]!
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
                                )
                                .toList(),
                            // ...combinedIngredients
                            //     .map(
                            //       (entry) => Padding(
                            //         padding: const EdgeInsets.only(
                            //             bottom: AppPading.medium),
                            //         child: IngredientTile(
                            //           ingredient: entry,
                            //         ),
                            //       ),
                            //     )
                            //     .toList(),
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
