import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';

class Recipe {
  final String title;
  final List<Ingredient> ingredients;
  final String cookingTime;
  final List<String> instructions;
  final String mealType;
  final bool? refreshed;
  final bool? completed;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.cookingTime,
    required this.instructions,
    required this.mealType,
    this.refreshed,
    this.completed,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // print("Title: ${json['title'] as String}");
    // print("Ingredients: ${json['ingredients'] as List}");
    // print("Cooking Time: ${json['cooking_time'] as String}");
    // print("Instructions: ${json['instructions'] as List}");
    // print("HEEWADWAD");
    // print("Meal Type: ${(json['meal_type'] ?? "dinner") as String}");

    return Recipe(
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List)
          .map((ingredient) => Ingredient.fromJson(ingredient))
          .toList(),
      cookingTime: json['cooking_time'] as String,
      instructions: List<String>.from(json['instructions']),
      mealType: (json['meal_type'] ?? "lunch"),
      refreshed: json['refreshed'] as bool?,
      completed: json['completed'] as bool?,
    );
  }

  @override
  String toString() {
    return '$title\nCooking Time: $cookingTime\nIngredients: ${ingredients.join(', ')}\nInstructions: ${instructions.join('\n')}';
  }
}
