import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';

class Recipe {
  final String id;
  final String title;
  final List<Ingredient> ingredients;
  final String cookingTime;
  final List<String> instructions;
  final String mealType;
  final bool? refreshed;
  final bool? completed;
  final String? image;
  final int? calories;
  final int? protein;
  final int? carbohydrates;
  final int? fat;
  final bool? loading;
  final bool? favourite;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.cookingTime,
    required this.instructions,
    required this.mealType,
    this.refreshed,
    this.completed,
    this.image,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.loading,
    this.favourite,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // print("Title: ${json['title'] as String}");
    // print("Ingredients: ${json['ingredients'] as List}");
    // print("Cooking Time: ${json['cooking_time'] as String}");
    // print("Instructions: ${json['instructions'] as List}");
    // print("HEEWADWAD");
    // print("Meal Type: ${(json['meal_type'] ?? "dinner") as String}");

    try {
      return Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        ingredients: (json['ingredients'] as List)
            .map((ingredient) => Ingredient.fromJson(ingredient))
            .toList(),
        cookingTime: json['cooking_time'] as String,
        instructions: List<String>.from(json['instructions']),
        mealType: (json['meal_type'] ?? "lunch"),
        refreshed: json['refreshed'] as bool?,
        completed: json['completed'] as bool?,
        image: json['image'] as String?,
        calories: json['calories'] as int?,
        protein: json['protein'] as int?,
        carbohydrates: json['carbohydrates'] as int?,
        fat: json['fat'] as int?,
        loading: json['loading'] as bool?,
        favourite: json['favourite'] as bool?,
      );
    } catch (e) {
      return nullRecipe;
    }
  }

  @override
  String toString() {
    return '$title\nCooking Time: $cookingTime\nIngredients: ${ingredients.join(', ')}\nInstructions: ${instructions.join('\n')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ingredients':
          ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'cooking_time': cookingTime,
      'instructions': instructions,
      'meal_type': mealType,
      'refreshed': refreshed,
      'completed': completed,
      'image': image,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'loading': loading,
      'favourite': favourite,
    };
  }
}

Recipe nullRecipe = Recipe(
  id: '0',
  title: 'No Recipe Found',
  ingredients: [],
  cookingTime: '0',
  instructions: [],
  mealType: 'lunch',
  refreshed: false,
  completed: false,
  image: null,
  calories: 0,
  protein: 0,
  carbohydrates: 0,
  fat: 0,
  loading: false,
  favourite: false,
);
