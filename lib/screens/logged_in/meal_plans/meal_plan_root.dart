import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/meal_plan/meal_plan.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/view_single_meal_plan.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';
import 'package:provider/provider.dart';

class MealPlanRoot extends StatefulWidget {
  const MealPlanRoot({
    super.key,
    required this.mealPlanId,
  });

  final String mealPlanId;

  @override
  State<MealPlanRoot> createState() => _MealPlanRootState();
}

class _MealPlanRootState extends State<MealPlanRoot> {
  @override
  Widget build(BuildContext context) {
    AppUser? user = Provider.of<AppUser?>(context);

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
        body: StreamBuilder<MealPlan>(
            stream: UserService(uid: user!.uid).getMealPlan(widget.mealPlanId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred'),
                );
              } else if (snapshot.hasData) {
                MealPlan plan = snapshot.data!;

                if (plan.loading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 150),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LottieController(
                              repeat: false,
                              location:
                                  'assets/lottie/preparing_meal_plan.json',
                              height: 220),
                          SizedBox(
                            height: AppPading.page * 2,
                          ),
                          Text(
                            "Preparing Meal Plan...",
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ).h2(),
                          SizedBox(
                            height: AppPading.small,
                          ),
                          Text("Please check back later").h5(),
                        ],
                      ),
                    ),
                  );
                } else {
                  List<Recipe>? breakfasts = plan.recipes
                      ?.where((recipe) => recipe.mealType == "breakfast")
                      .toList();
                  List<Recipe>? lunches = plan.recipes
                      ?.where((recipe) => recipe.mealType == "lunch")
                      .toList();
                  List<Recipe>? dinners = plan.recipes
                      ?.where((recipe) => recipe.mealType == "dinner")
                      .toList();
                  return ViewSingleMealPlan(
                    title: formatDateWithSuffix(plan.createdAt,
                        includeTime: false),
                    lunches: lunches,
                    dinners: dinners,
                    breakfasts: breakfasts,
                    totalIngredients: plan.totalIngredients,
                  );
                }

                // return Column(
                //   children: [
                //     Text(snapshot.data!.name),
                //     Text(snapshot.data!.description),
                //     Text(snapshot.data!.mealPlanConfiguration.toString()),
                //   ],
                // );
              } else {
                return const Center(
                  child: Text('No meal plan found'),
                );
              }
            }),
      ),
    );
  }
}
