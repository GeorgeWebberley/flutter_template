import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String? subscriptionPlan;
  final dynamic receiptData; // It might be a String or a Map
  final String? platform;
  final String? productId;
  final dynamic validationResponse;
  final Timestamp? lastValidated;

  Subscription({
    this.subscriptionPlan,
    this.receiptData,
    this.platform,
    this.productId,
    this.validationResponse,
    this.lastValidated,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionPlan: json['subscriptionPlan'] as String?,
      receiptData: json['receiptData'], // you can cast if needed
      platform: json['platform'] as String?,
      productId: json['productId'] as String?,
      validationResponse: json['validationResponse'],
      lastValidated: json['lastValidated'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionPlan': subscriptionPlan,
      'receiptData': receiptData,
      'platform': platform,
      'productId': productId,
      'validationResponse': validationResponse,
      'lastValidated': lastValidated,
    };
  }
}
