import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_template/models/dietary_preference/dietary_preference.dart';

class UserData {
  final String uid;
  final String? name;
  final String email;
  final List<String>? providers;
  final List<DietaryPreference>? dietaryPreferences;
  final List<DocumentReference>? favourites;
  final bool? hasCompletedTutorial;
  final List<String>? requirements;
  final List<String>? allergies;
  final List<String>? tools;
  final List<String>? tastes;
  final List<String>? extras;

  UserData({
    required this.uid,
    this.name,
    required this.email,
    this.providers,
    this.dietaryPreferences,
    this.favourites,
    this.hasCompletedTutorial,
    this.requirements,
    this.allergies,
    this.tools,
    this.tastes,
    this.extras,
  });

  // Factory method to create UserData from a Firestore document (JSON)
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      providers: json['providers'] != null
          ? List<String>.from(json['providers'])
          : null,
      dietaryPreferences: json['dietaryPreferences'] != null
          ? (json['dietaryPreferences'] as List<dynamic>)
              .map((e) => DietaryPreference.fromJson(e))
              .toList()
          : null,
      favourites: json['favourites'] != null
          ? (json['favourites'] as List<dynamic>)
              .map((e) => e as DocumentReference)
              .toList()
          : null,
      hasCompletedTutorial: json['hasCompletedTutorial'],
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      tools: json['tools'] != null ? List<String>.from(json['tools']) : null,
      tastes: json['tastes'] != null ? List<String>.from(json['tastes']) : null,
      extras: json['extras'] != null ? List<String>.from(json['extras']) : null,
    );
  }

  // Convert UserData to JSON (for storing in Firestore)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'providers': providers,
      'dietaryPreferences': dietaryPreferences?.map((e) => e.toJson()).toList(),
      'favourites': favourites?.map((e) => e.path).toList(),
      'hasCompletedTutorial': hasCompletedTutorial,
    };
  }
}
