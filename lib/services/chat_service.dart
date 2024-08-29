import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_firebase_template/models/message.dart';

class ChatService {
  ChatService();

  Future<Message> sendMessage(String message, {String? mealPlanId}) async {
    try {
      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendMessage');

      Map<String, dynamic> body = {
        'message': message,
      };

      if (mealPlanId != null) {
        body['mealPlanId'] = mealPlanId;
      }

      final response = await callable.call(body);

      // Parse the JSON response into a Message object
      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(response.data['message']);
      return Message.fromJson(responseData);
    } catch (e) {
      // Handle any errors here
      print('Error in ChatService: $e');
      throw Exception('Failed to send message');
    }
  }
}
