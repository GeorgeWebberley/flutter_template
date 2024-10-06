import 'dart:convert';

import 'package:flutter_firebase_template/models/recipe.dart';

/// A more advanced Message that can handle multiple types of responses, including
/// text responses and recipe responses.
class Message {
  final String role;
  final String? textResponse;
  final List<Recipe>? recipes;
  final String?
      responseType; // Indicates the type of response (e.g., "text" or "recipe")

  Message({
    required this.role,
    this.textResponse,
    this.recipes,
    this.responseType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Extract the first content object and its text value
    final List<dynamic> contentList = json['content'] as List<dynamic>;
    final contentObject = contentList.isNotEmpty ? contentList.first : null;

    String? parsedTextResponse;
    List<Recipe>? parsedRecipes;
    String? responseType;

    if (contentObject != null && contentObject['type'] == 'text') {
      final textValue = contentObject['text']['value'];
      dynamic parsedJson = jsonDecode(textValue);

      if (parsedJson?['properties'] != null) {
        parsedJson = parsedJson['properties'];
      }

      responseType = parsedJson['response_type'];

      if (responseType == 'text') {
        parsedTextResponse = parsedJson['text_response'];
      } else if (responseType == 'recipe' && parsedJson['recipes'] is List) {
        parsedRecipes = (parsedJson['recipes'] as List)
            .map((recipe) => Recipe.fromJson(recipe))
            .toList();
      } else if (responseType == 'recipe' && parsedJson['recipe'] is Map) {
        // TODO: Figure out why AI is returning a "recipe" that is a Map rather than "recipes" that is list (only happens when asking for a single recipe)
        parsedRecipes = [Recipe.fromJson(parsedJson['recipe'])];
      }
    }

    return Message(
      role: json['role'] as String,
      textResponse: parsedTextResponse,
      recipes: parsedRecipes,
      responseType: responseType,
    );
  }
}
