import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionProduct {
  final String title;
  final double amount;
  final String currency;

  SubscriptionProduct({
    required this.title,
    required this.amount,
    required this.currency,
  });

  factory SubscriptionProduct.fromProductDetails(
      ProductDetails productDetails) {
    return SubscriptionProduct(
      title: productDetails.title,
      amount: productDetails.rawPrice,
      currency: productDetails.currencySymbol,
    );
  }
}
