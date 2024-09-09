import 'package:flutter/material.dart';

class RecipeStub {
  final String title;
  final String mealType;
  bool isSelected;

  RecipeStub({
    required this.title,
    required this.mealType,
    this.isSelected = false,
  });

  factory RecipeStub.fromJson(Map<String, dynamic> json) {
    try {
      return RecipeStub(
          title: json['title'] as String, mealType: json['meal_type']);
    } catch (e) {
      debugPrint(e.toString());
      return nullRecipeStub;
    }
  }

  @override
  String toString() {
    return title;
  }
}

RecipeStub nullRecipeStub = RecipeStub(title: 'Null', mealType: '');
