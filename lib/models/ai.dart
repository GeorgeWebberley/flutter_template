import 'package:flutter_firebase_template/models/recipe.dart';

class AiResponse {
  final String status;
  final List<Recipe> messages;

  AiResponse({
    required this.status,
    required this.messages,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      status: json['status'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((msg) => Recipe.fromJson(Map<String, dynamic>.from(msg)))
          .toList(),
    );
  }
}
