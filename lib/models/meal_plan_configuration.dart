class MealPlanConfiguration {
  final int breakfasts;
  final int lunches;
  final int dinners;
  final int numberOfPeople;
  final List<String>? requirements;
  final List<String>? allergies;
  final List<String>? tools;
  final List<String>? tastes;
  final List<String>? extras;

  MealPlanConfiguration({
    this.breakfasts = 0,
    this.lunches = 0,
    this.dinners = 0,
    required this.numberOfPeople,
    this.requirements,
    this.allergies,
    this.tools,
    this.tastes,
    this.extras,
  });

  factory MealPlanConfiguration.fromJson(Map<String, dynamic> json) {
    return MealPlanConfiguration(
      breakfasts: json['breakfasts'] as int,
      lunches: json['lunches'] as int,
      dinners: json['dinners'] as int,
      numberOfPeople: json['numberOfPeople'] as int,
      requirements: (json['requirements'] as List)
          .map((requirement) => requirement as String)
          .toList(),
      allergies: (json['allergies'] as List)
          .map((allergy) => allergy as String)
          .toList(),
      tools: (json['tools'] as List).map((tool) => tool as String).toList(),
      tastes: (json['tastes'] as List).map((taste) => taste as String).toList(),
      extras: (json['extras'] as List).map((extra) => extra as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfasts': breakfasts,
      'lunches': lunches,
      'dinners': dinners,
      'numberOfPeople': numberOfPeople,
      'requirements': requirements,
      'allergies': allergies,
      'tools': tools,
      'tastes': tastes,
      'extras': extras,
    };
  }
}
