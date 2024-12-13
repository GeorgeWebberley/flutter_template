import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/number_input.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_display/recipe_expandable_tile.dart';
import 'package:flutter_firebase_template/widgets/simple_vito.dart';

class MealPlanOptions extends StatefulWidget {
  const MealPlanOptions(
      {super.key,
      required this.onBreakfastsSelected,
      required this.onLunchesSelected,
      required this.onDinnersSelected,
      // required this.selectedBreakfasts,
      // required this.selectedLunches,
      // required this.selectedDinners,
      this.recipes,
      required this.onBack,
      required this.onSubmit});

  final List<RecipeStub>? recipes;
  // final List<RecipeStub> selectedBreakfasts;
  // final List<RecipeStub> selectedLunches;
  // final List<RecipeStub> selectedDinners;
  final Function(List<RecipeStub> recipe) onBreakfastsSelected;
  final Function(List<RecipeStub> recipe) onLunchesSelected;
  final Function(List<RecipeStub> recipe) onDinnersSelected;

  final Future<void> Function() onBack;
  final Future<void> Function() onSubmit;

  @override
  State<MealPlanOptions> createState() => _MealPlanOptionsState();
}

class _MealPlanOptionsState extends State<MealPlanOptions> {
  @override
  Widget build(BuildContext context) {
    if (widget.recipes == null) {
      return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                widget.onBack();
              },
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppPading.page),
              child: SimpleVito(
                text:
                    "Please wait a moment whilst I think up some some suggestions for you...",
                child: Padding(
                  padding: const EdgeInsets.only(top: AppPading.large),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
          ));
    } else {
      List<RecipeStub> breakfastRecipes = widget.recipes!
          .where((element) => element.mealType == "breakfast")
          .toList();

      List<RecipeStub> lunchRecipes = widget.recipes!
          .where((element) => element.mealType == "lunch")
          .toList();

      List<RecipeStub> dinnerRecipes = widget.recipes!
          .where((element) => element.mealType == "dinner")
          .toList();

      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              widget.onBack();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppPading.page,
            0,
            AppPading.page,
            AppPading.page,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recipe Suggestions",
                  style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 40,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: AppPading.large,
                ),
                Text(
                  "Select which recipes you would like to include in your meal plan.",
                ).h5(),
                const SizedBox(
                  height: AppPading.large,
                ),
                AppBox(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPading.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Row(),
                        if (breakfastRecipes.isNotEmpty)
                          RecipeExpandableTile(
                            mealType: "Breakfast",
                            recipes: breakfastRecipes,
                            onChanged: widget.onBreakfastsSelected,
                          ),
                        if (lunchRecipes.isNotEmpty)
                          RecipeExpandableTile(
                            mealType: "Lunch",
                            recipes: lunchRecipes,
                            onChanged: widget.onLunchesSelected,
                          ),
                        if (dinnerRecipes.isNotEmpty)
                          RecipeExpandableTile(
                            mealType: "Dinner",
                            recipes: dinnerRecipes,
                            onChanged: widget.onDinnersSelected,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: AppPading.large,
                ),
                AppButton(
                  disabled:
                      !widget.recipes!.any((element) => element.isSelected),
                  onPressed: () {
                    widget.onSubmit();
                  },
                  text: "Create Meal Plan",
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
