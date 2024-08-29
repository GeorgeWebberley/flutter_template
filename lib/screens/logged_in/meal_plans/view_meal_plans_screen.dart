import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/meal_plan/meal_plan.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/meal_plan_root.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_dialog.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:provider/provider.dart';

class ViewMealPlansScreen extends StatelessWidget {
  const ViewMealPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppUser? user = Provider.of<AppUser?>(context);

    return StreamBuilder<List<MealPlan>>(
      stream: UserService(uid: user!.uid).getMealPlans(),
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
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No meal plans found'),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(AppPading.page),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final mealPlan = snapshot.data![index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppPading.large),
                  child: _buildMealPlanCard(
                      context: context, user: user, mealPlan: mealPlan),
                );
              },
            ),
          );
        }
      },
    );
  }

  _buildMealPlanCard(
      {required BuildContext context,
      required MealPlan mealPlan,
      required AppUser user}) {
    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: () => Navigator.push(
              context,
              SlideNavigator(
                  builder: (context, _, __) => MealPlanRoot(
                        mealPlanId: mealPlan.id,
                      )),
            ),
            title: Text(
                formatDateWithSuffix(mealPlan.createdAt, includeTime: false)),
            subtitle: Text(
                formatDateWithSuffix(mealPlan.createdAt, includeDate: false)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    _deleteMealPlan(
                        context: context, mealPlanId: mealPlan.id, user: user);
                  },
                  icon: const Icon(Icons.delete),
                  color: AppColors.danger,
                ),
                const SizedBox(
                  width: AppPading.medium,
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _deleteMealPlan(
      {required BuildContext context,
      required String mealPlanId,
      required AppUser user}) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AppDialog(
              buttonText: "Delete",
              content: Container(),
              title: "Are you sure you want to delete this meal plan?",
              onSave: () async {
                await UserService(uid: user.uid).deleteMealPlan(mealPlanId);

                Navigator.pop(context);
              });
        });
      },
    );
  }
}
