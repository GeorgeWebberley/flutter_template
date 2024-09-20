import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/ingredient_tile.dart';
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Make chat window appear
          },
          child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: AppGradients.buttonPrimaryGradient,
              ),
              child: const Icon(
                Icons.chat,
                size: 40,
                color: Colors.white,
              )),
        ),
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
          child: Stack(
            children: [
              // Positioned(
              //   // top: AppPading.medium,
              //   right: AppPading.medium,
              //   child: IconButton(
              //     iconSize: 30,
              //     icon: const Icon(
              //       Icons.favorite_border,
              //     ),
              //     onPressed: () {
              //       // Add to favourites
              //     },
              //   ),
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        // top: AppPading.medium,
                        left: AppPading.page,
                        right: AppPading.page,
                        bottom: AppPading.small),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(recipe.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            )).h3(),
                        IconButton(
                          onPressed: () {
                            // Add to favourites
                          },
                          icon: Icon(
                            Icons.favorite_border,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppPading.page,
                        right: AppPading.page,
                        bottom: AppPading.large),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined),
                              SizedBox(
                                width: AppPading.small,
                              ),
                              Text(
                                recipe.cookingTime,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ).h5(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.directions_run),
                              SizedBox(
                                width: AppPading.small,
                              ),
                              Text(
                                "${recipe.calories} calories",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ).h5(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.network(recipe.image ?? ""),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SizedBox(
                  //       width: 250,
                  //       child: Image.asset("assets/images/food_example.png"),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(
                    height: AppPading.large,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppPading.page,
                        right: AppPading.page,
                        bottom: AppPading.page),
                    child: Column(
                      children: [
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
                                        child: IngredientTile(
                                          ingredient: ingredient,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
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
                                            const Text('•')
                                                .h5(), // Bullet point
                                            const SizedBox(
                                                width: AppPading
                                                    .medium), // Space between bullet and text
                                            Expanded(
                                              child: Text(
                                                ingredient,
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.8)),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
