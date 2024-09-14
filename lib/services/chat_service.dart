import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';

class ChatService {
  ChatService();

  Future<Message?> sendMessage(String message,
      {String? mealPlanId, bool isNewConversation = true}) async {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'sendMessage',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'message': message,
      };

      if (isNewConversation) {
        body['isNewConversation'] = isNewConversation;
      }

      if (mealPlanId != null) {
        body['mealPlanId'] = mealPlanId;
        callable.call(body);
        return null;
      } else {
        final response = await callable.call(body);

        // Parse the JSON response into a Message object
        final Map<String, dynamic> responseData =
            Map<String, dynamic>.from(response.data['message']);
        return Message.fromJson(responseData);
      }
    } catch (e) {
      // Handle any errors here
      debugPrint('Error in ChatService: $e');
      throw Exception('Failed to send message');
    }
  }

  Future<Map<String, dynamic>?> sendSimpleMessage(
    String message, {
    String? threadId,
    Recipe? recipe,
  }) async {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'sendMessageRecipeHelp',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'message': message,
      };
      if (threadId != null) {
        body['threadId'] = threadId;
      }
      if (recipe != null) {
        body['recipeJson'] = recipe.toJson();
      }

      final response = await callable.call(body);

      // Parse the JSON response into a Message object
      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(response.data['message']);

      try {
        print("responseData: $responseData");
        //TODO: Make this into a model
        return {
          'message': responseData['content'][0]['text']['value'],
          'threadId': responseData['thread_id'],
        };
      } catch (e) {
        return {
          'message': "Sorry I don't understand that! Can you try again?",
          'threadId': responseData['thread_id']
        };
      }
    } catch (e) {
      // Handle any errors here
      debugPrint('Error in ChatService: $e');
      throw Exception('Failed to send message');
    }
  }

  Future<List<RecipeStub>> getRecipeStubs({
    required int numberOfPeople,
    required int breakfasts,
    required int lunches,
    required int dinners,
    required int snacks,
    required List<String> dietaryPreferences,
  }) async {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'getRecipeList',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'numberOfPeople': numberOfPeople,
        'breakfasts': breakfasts,
        'lunches': lunches,
        'dinners': dinners,
        'snacks': snacks,
        'dietaryPreferences': dietaryPreferences,
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
      debugPrint('Error in ChatService: $e');
      throw Exception('Failed to send message');
    }
  }

  void createMealPlan(
      {required String mealPlanId,
      required int numberOfPeople,
      List<String> breakfasts = const [],
      List<String> lunches = const [],
      List<String> dinners = const [],
      List<String> dietaryPreferences = const []}) {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'generateRecipes',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'breakfasts': breakfasts,
        'lunches': lunches,
        'dinners': dinners,
        'numberOfPeople': numberOfPeople,
        'mealPlanId': mealPlanId,
        'dietaryPreferences': dietaryPreferences,
      };
      // We don't wait for the promise, since it will take a long time
      callable.call(body);
    } catch (e) {
      debugPrint('Error in ChatService: $e');
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
      debugPrint('Error in ChatService: $e');
      throw Exception('Failed to send message');
    }
  }
}
