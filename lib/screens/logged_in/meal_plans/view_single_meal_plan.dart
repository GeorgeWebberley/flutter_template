import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/meal_plan/meal_plan.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/shopping_list_screen.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/view_recipe_list_screen.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';
import 'package:provider/provider.dart';

class ViewSingleMealPlan extends StatefulWidget {
  const ViewSingleMealPlan({
    super.key,
    required this.mealPlan,
  });

  final MealPlan mealPlan;

  @override
  State<ViewSingleMealPlan> createState() => _ViewSingleMealPlanState();
}

class _ViewSingleMealPlanState extends State<ViewSingleMealPlan> {
  PageController pageController = PageController();
  late List<Recipe>? breakfasts;
  late List<Recipe>? lunches;
  late List<Recipe>? dinners;

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);

    return StreamBuilder<List<Recipe>>(
        stream: UserService(uid: user.uid).getRecipes(widget.mealPlan.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('An error occurred: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Recipe> recipes = snapshot.data!;
            breakfasts = recipes
                .where((recipe) => recipe.mealType == "breakfast")
                .toList();
            lunches =
                recipes.where((recipe) => recipe.mealType == "lunch").toList();
            dinners =
                recipes.where((recipe) => recipe.mealType == "dinner").toList();
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppPading.page),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTitle(
                      title: formatDateWithSuffix(widget.mealPlan.createdAt,
                          includeTime: false),
                    ),
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
                                          getTotalIngredients(recipes),
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
                              loading:
                                  widget.mealPlan.breakfastRefreshing == true,
                              title: widget.mealPlan.breakfastRefreshing == true
                                  ? "Fetching new..."
                                  : 'Breakfasts',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SlideNavigator(
                                      builder: (context, _, __) =>
                                          ViewRecipeListScreen(
                                              mealPlan: widget.mealPlan,
                                              title: 'Breakfasts',
                                              mealType: 'breakfast')),
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
                              loading: widget.mealPlan.lunchRefreshing == true,
                              title: widget.mealPlan.lunchRefreshing == true
                                  ? "Fetching new..."
                                  : 'Lunches',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SlideNavigator(
                                      builder: (context, _, __) =>
                                          ViewRecipeListScreen(
                                              mealPlan: widget.mealPlan,
                                              title: 'Lunches',
                                              mealType: 'lunch')),
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
                              loading: widget.mealPlan.dinnerRefreshing == true,
                              title: widget.mealPlan.dinnerRefreshing == true
                                  ? "Fetching new..."
                                  : 'Dinners',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SlideNavigator(
                                      builder: (context, _, __) =>
                                          ViewRecipeListScreen(
                                              mealPlan: widget.mealPlan,
                                              title: 'Dinners',
                                              mealType: 'dinner')),
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
          } else {
            return const Center(
              child: Text('No meal plan found'),
            );
          }
        });
  }
}
