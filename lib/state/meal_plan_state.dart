import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/meal_plan/meal_plan.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/services/user_service.dart';

class MealPlanState with ChangeNotifier {
  List<MealPlan>? _mealPlans;
  List<Recipe>? _recipes;
  Stream<List<MealPlan>>? _mealPlanStream;
  Stream<List<Recipe>>? _recipeStream;
  final String _uid;

  MealPlanState(this._uid) {
    init();
  }

  void init() {
    _mealPlanStream = UserService(uid: _uid).getMealPlans();
    _mealPlanStream!.listen((mealPlans) {
      _mealPlans = mealPlans;
      notifyListeners();
    });
  }

  void initRecipes(String mealPlanId) {
    _recipeStream =
        UserService(uid: _uid).getRecipes(mealPlanId); // Use _uid here
    _recipeStream!.listen((recipes) {
      _recipes = recipes;
      notifyListeners();
    });
  }

  List<MealPlan>? get mealPlans => _mealPlans;
  List<Recipe>? get recipes => _recipes;
}
