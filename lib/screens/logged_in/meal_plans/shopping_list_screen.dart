import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/ingredient_tile.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/shared/unit_converter.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({
    super.key,
    required this.totalIngredients,
  });

  final List<Ingredient> totalIngredients; // New field for total ingredients

  @override
  Widget build(BuildContext context) {
    List<Ingredient> exampleList = [
      Ingredient(name: 'Chia seeds', quantity: 30, unit: 'grams'),
      Ingredient(name: 'Chia seeds', quantity: 100, unit: 'grams'),
      Ingredient(name: 'Chia seeds', quantity: 2, unit: 'tablespoons'),
      Ingredient(name: 'Tomatoes', quantity: 500, unit: 'milliliters'),
      Ingredient(name: 'Tomatoes', quantity: 0.5, unit: 'liters'),
      Ingredient(name: 'Olive Oil', quantity: 1, unit: 'tablespoons'),
      Ingredient(name: 'Olive Oil', quantity: 2, unit: 'ml'),
      Ingredient(name: 'Olive Oil', quantity: 200, unit: 'milliliters'),
      Ingredient(name: 'Olive Oil', quantity: 50, unit: 'milliliters'),
      Ingredient(name: 'Salt', quantity: 1, unit: 'tablespoons'),
      Ingredient(name: 'Flour', quantity: 200, unit: 'grams'),
      Ingredient(name: 'Flour', quantity: 0.5, unit: 'kilograms'),
      Ingredient(name: 'Garlic', quantity: 5, unit: 'cloves'),
      Ingredient(name: 'Garlic', quantity: 2, unit: 'cloves'),
      Ingredient(name: 'Milk', quantity: 1, unit: 'cups'),
      Ingredient(name: 'Butter', quantity: 100, unit: 'grams'),
      Ingredient(name: 'Butter', quantity: 2, unit: 'tablespoons'),
      Ingredient(name: 'Sugar', quantity: 150, unit: 'grams'),
      Ingredient(name: 'Sugar', quantity: 50, unit: 'grams'),
      Ingredient(name: 'Sugar', quantity: 2, unit: 'cups'),
      Ingredient(name: 'Honey', quantity: 3, unit: 'tablespoons'),
      Ingredient(name: 'Honey', quantity: 50, unit: 'ml'),
      Ingredient(name: 'Water', quantity: 500, unit: 'milliliters'),
      Ingredient(name: 'Water', quantity: 1, unit: 'liters'),
      Ingredient(name: 'Eggs', quantity: 3, unit: 'pieces'),
      Ingredient(name: 'Eggs', quantity: 2, unit: 'pieces'),
      Ingredient(name: 'Pepper', quantity: 5, unit: 'grams'),
      Ingredient(name: 'Pepper', quantity: 1, unit: 'teaspoons'),
      Ingredient(name: 'Cinnamon', quantity: 2, unit: 'teaspoons'),
      Ingredient(name: 'Cinnamon', quantity: 10, unit: 'grams'),
      Ingredient(name: 'Nutmeg', quantity: 1, unit: 'teaspoons'),
      Ingredient(name: 'Nutmeg', quantity: 1, unit: 'tablespoons'),
      Ingredient(name: 'Basil', quantity: 20, unit: 'grams'),
      Ingredient(name: 'Basil', quantity: 3, unit: 'teaspoons'),
      Ingredient(name: 'Butter', quantity: 50, unit: 'grams'),
      Ingredient(name: 'Butter', quantity: 1, unit: 'cups'),
      Ingredient(name: 'Yogurt', quantity: 2, unit: 'cups'),
      Ingredient(name: 'Yogurt', quantity: 100, unit: 'milliliters'),
      Ingredient(name: 'Apple', quantity: 1, unit: 'pieces'),
      Ingredient(name: 'Apple', quantity: 2, unit: 'pieces'),
      Ingredient(name: 'Mango', quantity: 300, unit: 'grams'),
      Ingredient(name: 'Mango', quantity: 1, unit: 'pieces'),
    ];

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
            child: Column(
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
          ),
        ),
      ),
    );
  }
}
