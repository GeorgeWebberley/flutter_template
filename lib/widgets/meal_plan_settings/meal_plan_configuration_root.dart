import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/meal_plan_configuration.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/meal_plan_root.dart';
import 'package:flutter_firebase_template/services/meal_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/diet_summary.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/meal_plan_options.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/meal_plan_settings.dart';
import 'package:provider/provider.dart';

class MealPlanConfigurationRoot extends StatefulWidget {
  const MealPlanConfigurationRoot({super.key});

  @override
  State<MealPlanConfigurationRoot> createState() =>
      _MealPlanConfigurationRootState();
}

class _MealPlanConfigurationRootState extends State<MealPlanConfigurationRoot> {
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);

    return FutureBuilder<UserData?>(
        future: UserService(uid: user.uid).getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            UserData userData = snapshot.data!;

            int people = 1;
            int breakfasts = 0;
            int lunches = 0;
            int dinners = 0;

            List<String> requirements = userData.requirements ?? [];
            List<String> allergies = userData.allergies ?? [];
            List<String> tools = userData.tools ?? [];
            List<String> tastes = userData.tastes ?? [];
            List<String> extras = userData.extras ?? [];
            List<RecipeStub>? recipes;
            List<RecipeStub> suggestedBreakfasts = [];
            List<RecipeStub> suggestedLunches = [];
            List<RecipeStub> suggestedDinners = [];
            bool hasGenerated = false;

            return StatefulBuilder(builder: (context, buildSetState) {
              bool settingsHasChanged =
                  !listsAreTheSame(requirements, userData.requirements ?? []) ||
                      !listsAreTheSame(allergies, userData.allergies ?? []) ||
                      !listsAreTheSame(tools, userData.tools ?? []) ||
                      !listsAreTheSame(tastes, userData.tastes ?? []) ||
                      !listsAreTheSame(extras, userData.extras ?? []);

              return Container(
                decoration: const BoxDecoration(
                    gradient: AppGradients.backgroundGradient),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    MealPlanSettings(
                        initialBreakfasts: breakfasts,
                        initialDinners: dinners,
                        initialLunches: lunches,
                        initialPeople: people,
                        onContinue: (
                            {required int numberOfPeople,
                            required int numberOfBreakfasts,
                            required int numberOfLunches,
                            required int numberOfDinners}) {
                          pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                          buildSetState(() {
                            people = numberOfPeople;
                            breakfasts = numberOfBreakfasts;
                            lunches = numberOfLunches;
                            dinners = numberOfDinners;
                          });
                        }),
                    DietSummary(
                      hasChanged: !hasGenerated && settingsHasChanged,
                      allergies: allergies,
                      requirements: requirements,
                      tools: tools,
                      tastes: tastes,
                      extras: extras,
                      onRequirementsChanged: (newValues) {
                        buildSetState(() {
                          requirements = newValues;
                        });
                      },
                      onAllergiesChanged: (newValues) {
                        buildSetState(() {
                          allergies = newValues;
                        });
                      },
                      onToolsChanged: (newValues) {
                        buildSetState(() {
                          tools = newValues;
                        });
                      },
                      onTastesChanged: (newValues) {
                        buildSetState(() {
                          tastes = newValues;
                        });
                      },
                      onExtrasChanged: (newValues) {
                        buildSetState(() {
                          extras = newValues;
                        });
                      },
                      isTutorial: false,
                      onProceed: (
                          {required List<String> tools,
                          required List<String> requirements,
                          required List<String> tastes,
                          required List<String> allergies,
                          required List<String> extras}) async {
                        if (hasGenerated) {
                          pageController.animateToPage(2,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        } else {
                          buildSetState(() {
                            hasGenerated = true;
                          });

                          pageController.animateToPage(2,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                          List<RecipeStub> recipesResponse = await MealService()
                              .getRecipeStubs(
                                  numberOfPeople: people,
                                  breakfasts: (breakfasts * 1.5).ceil(),
                                  lunches: (lunches * 1.5).ceil(),
                                  dinners: (dinners * 1.5).ceil(),
                                  requirements: requirements,
                                  allergies: allergies,
                                  tools: tools,
                                  tastes: tastes,
                                  extras: extras);
                          buildSetState(() {
                            recipes = recipesResponse;
                          });
                        }
                      },
                      onBack: () async {
                        pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                    ),
                    MealPlanOptions(
                      onBack: () async {
                        pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      recipes: recipes,
                      onBreakfastsSelected: (recipes) {
                        buildSetState(() {
                          suggestedBreakfasts = recipes;
                        });
                      },
                      onLunchesSelected: (recipes) {
                        buildSetState(() {
                          suggestedLunches = recipes;
                        });
                      },
                      onDinnersSelected: (recipes) {
                        buildSetState(() {
                          suggestedDinners = recipes;
                        });
                      },
                      onSubmit: () async {
                        String planId = await UserService(uid: user!.uid)
                            .addMealPlan(MealPlanConfiguration(
                          breakfasts: suggestedBreakfasts.length,
                          lunches: suggestedLunches.length,
                          dinners: suggestedDinners.length,
                          numberOfPeople: people,
                          requirements: requirements,
                          allergies: allergies,
                          tools: tools,
                          tastes: tastes,
                          extras: extras,
                        ));

                        MealService().createMealPlan(
                          mealPlanId: planId,
                          breakfasts:
                              suggestedBreakfasts.map((e) => e.title).toList(),
                          lunches:
                              suggestedLunches.map((e) => e.title).toList(),
                          dinners:
                              suggestedDinners.map((e) => e.title).toList(),
                          numberOfPeople: people,
                          requirements: requirements,
                          allergies: allergies,
                          tools: tools,
                          tastes: tastes,
                          extras: extras,
                        );

                        Navigator.pushReplacement(
                          context,
                          FadeNavigator(
                              builder: (context, _, __) => MealPlanRoot(
                                    mealPlanId: planId,
                                  )),
                        );
                      },
                    ),
                  ],
                ),
              );
            });
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
              ),
            );
          }
        });
  }
}
