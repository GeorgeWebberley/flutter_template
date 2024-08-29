class Recipe {
  final String title;
  final List<String> ingredients;
  final String cookingTime;
  final List<String> instructions;
  final String mealType;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.cookingTime,
    required this.instructions,
    required this.mealType,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    print("Title: ${json['title']}");
    print("Ingredients: ${json['ingredients']}");
    print("Cooking Time: ${json['cooking_time']}");
    print("Instructions: ${json['instructions']}");
    print("Meal Type: ${json['meal_type']}");

    return Recipe(
        title: json['title'] as String,
        ingredients: List<String>.from(json['ingredients']),
        cookingTime: json['cooking_time'] as String,
        instructions: List<String>.from(json['instructions']),
        mealType: json['meal_type']);
  }

  @override
  String toString() {
    return '$title\nCooking Time: $cookingTime\nIngredients: ${ingredients.join(', ')}\nInstructions: ${instructions.join('\n')}';
  }
}
