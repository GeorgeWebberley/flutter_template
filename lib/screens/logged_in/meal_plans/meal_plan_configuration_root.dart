import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/diet_summary.dart';
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

            return StatefulBuilder(builder: (context, buildSetState) {
              return Container(
                decoration: const BoxDecoration(
                    gradient: AppGradients.backgroundGradient),
                child: PageView(
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
                          required List<String> extras}) {},
                      onBack: () async {
                        pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
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
