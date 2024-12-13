import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';

class MealService {
  MealService();

  Future<List<RecipeStub>> getRecipeStubs({
    required int numberOfPeople,
    required int breakfasts,
    required int lunches,
    required int dinners,
    List<String>? requirements,
    List<String>? allergies,
    List<String>? tools,
    List<String>? tastes,
    List<String>? extras,
  }) async {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'getRecipeListNew',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'numberOfPeople': numberOfPeople,
        'breakfasts': breakfasts,
        'lunches': lunches,
        'dinners': dinners,
        'requirements': requirements,
        'allergies': allergies,
        'tools': tools,
        'tastes': tastes,
        'extras': extras,
      };

      final response = await callable.call(body);

      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(response.data['message']);

      final String valueString = responseData['content'][0]['text']['value'];
      final Map<String, dynamic> valueMap = jsonDecode(valueString);
      final List<dynamic> recipes = valueMap['recipes'];

      return recipes
          .map((recipeStub) => RecipeStub.fromJson(recipeStub))
          .toList();
    } catch (e) {
      // Handle any errors here
      debugPrint('Error in MealService: $e');
      throw Exception('Failed to send message');
    }
  }

  void createMealPlan({
    required String mealPlanId,
    required int numberOfPeople,
    List<String> breakfasts = const [],
    List<String> lunches = const [],
    List<String> dinners = const [],
    List<String> requirements = const [],
    List<String> allergies = const [],
    List<String> tools = const [],
    List<String> tastes = const [],
    List<String> extras = const [],
  }) {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'generateRecipesNew',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'breakfasts': breakfasts,
        'lunches': lunches,
        'dinners': dinners,
        'numberOfPeople': numberOfPeople,
        'mealPlanId': mealPlanId,
        'requirements': requirements,
        'allergies': allergies,
        'tools': tools,
        'tastes': tastes,
        'extras': extras,
      };
      // We don't wait for the promise, since it will take a long time
      callable.call(body);
    } catch (e) {
      debugPrint('Error in MealService: $e');
      throw Exception('Failed to send message');
    }
  }

  void refreshRecipes({
    required List<String> recipesToRefresh,
    required String type,
    required String mealPlanId,
  }) {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'refreshRecipe',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'recipesToRefresh': recipesToRefresh,
        'type': type,
        'mealPlanId': mealPlanId,
      };
      // We don't wait for the promise, since it will take a long time
      callable.call(body);
    } catch (e) {
      debugPrint('Error in MealService: $e');
      throw Exception('Failed to send message');
    }
  }
}
