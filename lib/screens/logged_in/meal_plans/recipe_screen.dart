import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppPading.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTitle(
                  title: recipe.title,
                  subtitle: "Cooking time: ${recipe.cookingTime}",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Image.asset("assets/images/food_example.png"),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppPading.large,
                ),
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
                        ...recipe.ingredients
                            .map(
                              (ingredient) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppPading
                                        .medium), // Add some space between items
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align bullet points to the top of the text
                                  children: [
                                    const Text('•').h5(), // Bullet point
                                    const SizedBox(
                                        width: AppPading
                                            .medium), // Space between bullet and text
                                    Expanded(
                                      child: Text(
                                        ingredient,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8)),
                                      ).h5(), // Ingredient text
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: AppPading.page * 2,
                ),
                AppBox(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPading.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Recipe").h4(),
                        const SizedBox(
                          height: AppPading.large,
                        ),
                        ...recipe.instructions
                            .map(
                              (ingredient) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppPading
                                        .medium), // Add some space between items
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align bullet points to the top of the text
                                  children: [
                                    const Text('•').h5(), // Bullet point
                                    const SizedBox(
                                        width: AppPading
                                            .medium), // Space between bullet and text
                                    Expanded(
                                      child: Text(
                                        ingredient,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8)),
                                      ).h5(), // Ingredient text
                                    ),
                                  ],
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
