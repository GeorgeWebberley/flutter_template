import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/shopping_list_screen.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/view_recipe_list_screen.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';

class ViewSingleMealPlan extends StatefulWidget {
  const ViewSingleMealPlan({
    super.key,
    this.meals,
    required this.title,
  });

  final List<Recipe>? meals;

  final String title;

  @override
  State<ViewSingleMealPlan> createState() => _ViewSingleMealPlanState();
}

class _ViewSingleMealPlanState extends State<ViewSingleMealPlan> {
  PageController pageController = PageController();
  late List<Recipe>? breakfasts;
  late List<Recipe>? lunches;
  late List<Recipe>? dinners;

  @override
  void initState() {
    super.initState();
    breakfasts = widget.meals
        ?.where((recipe) => recipe.mealType == "breakfast")
        .toList();
    lunches =
        widget.meals?.where((recipe) => recipe.mealType == "lunch").toList();
    dinners =
        widget.meals?.where((recipe) => recipe.mealType == "dinner").toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppPading.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTitle(title: widget.title),
            // if (widget.totalIngredients?.isNotEmpty == true)
            AppBox(
              child: DetailTile(
                title: 'Shopping List',
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideNavigator(
                        builder: (context, _, __) => ShoppingListScreen(
                              totalIngredients:
                                  getTotalIngredients(widget.meals!),
                            )),
                  );
                },
                icon: Icons.local_grocery_store,
                iconColor: Colors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(
              height: AppPading.large,
            ),
            AppBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (breakfasts?.isNotEmpty == true)
                    DetailTile(
                      title: 'Breakfasts',
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideNavigator(
                              builder: (context, _, __) => ViewRecipeListScreen(
                                  title: 'Breakfasts', recipes: breakfasts!)),
                        );
                      },
                      icon: Icons.breakfast_dining,
                      iconColor: AppColors.primary,
                    ),
                  // Add divider if there are breakfasts and either lunches or dinners
                  if (breakfasts?.isNotEmpty == true &&
                          (lunches?.isNotEmpty == true) ||
                      (dinners?.isNotEmpty == true))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.large),
                      child: Divider(
                        height: 0,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  if (lunches?.isNotEmpty == true)
                    DetailTile(
                      title: 'Lunches',
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideNavigator(
                              builder: (context, _, __) => ViewRecipeListScreen(
                                  title: 'Lunches', recipes: lunches!)),
                        );
                      },
                      icon: Icons.lunch_dining,
                      iconColor: AppColors.green,
                    ),
                  if (lunches?.isNotEmpty == true &&
                      dinners?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPading.large),
                      child: Divider(
                        height: 0,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  if (dinners?.isNotEmpty == true)
                    DetailTile(
                      title: 'Dinners',
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideNavigator(
                              builder: (context, _, __) => ViewRecipeListScreen(
                                  title: 'Dinners', recipes: dinners!)),
                        );
                      },
                      icon: Icons.dinner_dining,
                      iconColor: AppColors.danger.withOpacity(0.8),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
