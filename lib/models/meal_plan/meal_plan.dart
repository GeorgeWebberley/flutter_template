import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_template/models/recipe.dart';

// If updating, run:
// flutter pub run build_runner build --delete-conflicting-outputs

class MealPlan {
  final String id;
  final List<Recipe>? recipes;
  final DateTime? createdAt;
  final bool loading;
  final bool? breakfastRefreshing;
  final bool? lunchRefreshing;
  final bool? dinnerRefreshing;

  MealPlan({
    required this.id,
    this.recipes,
    required this.createdAt,
    required this.loading,
    this.breakfastRefreshing,
    this.lunchRefreshing,
    this.dinnerRefreshing,
  });

  factory MealPlan.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    return MealPlan(
      id: snapshot.id,
      recipes: (data['recipes'] as List?)
          ?.map((recipe) => Recipe.fromJson(recipe))
          .toList(),
      createdAt: _dateTimeFromJson(data['createdAt']),
      loading: data['loading'],
      breakfastRefreshing: data['breakfastRefreshing'],
      lunchRefreshing: data['lunchRefreshing'],
      dinnerRefreshing: data['dinnerRefreshing'],
    );
  }

  static DateTime _dateTimeFromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }
}
