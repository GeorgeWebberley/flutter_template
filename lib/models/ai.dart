import 'package:flutter_firebase_template/models/message.dart';

class AiResponse {
  final String status;
  final List<Message> messages;

  AiResponse({
    required this.status,
    required this.messages,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      status: json['status'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((msg) => Message.fromJson(Map<String, dynamic>.from(msg)))
          .toList(),
    );
  }
}
