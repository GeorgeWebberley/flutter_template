class MealPlanConfiguration {
  final int breakfasts;
  final int lunches;
  final int dinners;
  final int numberOfPeople;
  final List<String> dietaryPreferences;

  MealPlanConfiguration({
    this.breakfasts = 0,
    this.lunches = 0,
    this.dinners = 0,
    required this.numberOfPeople,
    required this.dietaryPreferences,
  });

  factory MealPlanConfiguration.fromJson(Map<String, dynamic> json) {
    return MealPlanConfiguration(
      breakfasts: json['breakfasts'] as int,
      lunches: json['lunches'] as int,
      dinners: json['dinners'] as int,
      numberOfPeople: json['numberOfPeople'] as int,
      dietaryPreferences: (json['dietaryPreferences'] as List)
          .map((preference) => preference as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfasts': breakfasts,
      'lunches': lunches,
      'dinners': dinners,
      'numberOfPeople': numberOfPeople,
      'dietaryPreferences': dietaryPreferences,
    };
  }
}
