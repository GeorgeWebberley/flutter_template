import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
//import for GooglePlayProductDetails
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
//import for SkuDetailsWrapper
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'dart:io';

class InAppPurchaseProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  static const Set<String> _subscriptionIds = {
    'com.nutriveat.app.subscription',
    // 'com.nutriveat.app.monthly',
    // 'com.nutriveat.app.yearly',
  };

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  String? _queryProductError;
  String? get queryProductError => _queryProductError;

  UserService userService;

  String platform = Platform.isAndroid ? 'android' : 'ios';

  InAppPurchaseProvider({required this.userService});

  void init() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  //   purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
  //     if (purchaseDetails.status == PurchaseStatus.pending) {
  //       // _showPendingUI();
  //     } else {
  //       if (purchaseDetails.status == PurchaseStatus.error) {
  //         // _handleError(purchaseDetails.error!);
  //       } else if (purchaseDetails.status == PurchaseStatus.purchased ||
  //           purchaseDetails.status == PurchaseStatus.restored) {
  //         // bool valid = await _verifyPurchase(purchaseDetails);
  //         // if (valid) {
  //         //   // _deliverProduct(purchaseDetails);
  //         // } else {
  //         //   // _handleInvalidPurchase(purchaseDetails);
  //         // }
  //       }
  //       if (purchaseDetails.pendingCompletePurchase) {
  //         await _inAppPurchase.completePurchase(purchaseDetails);
  //       }
  //     }
  //   });
  // }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // You might want to show a loading indicator.
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle the error (e.g., show an error message).
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // IMPORTANT: In a production app, verify the receipt on your backend
          // (e.g., via a Firebase Cloud Function) before delivering the product.
          await validateSubscription(
            platform: platform,
            productId: purchaseDetails.productID,
            purchaseDetails: purchaseDetails,
          );
          await _deliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    String subscriptionPlan;
    if (purchaseDetails.productID == 'com.nutriveat.app.yearly') {
      subscriptionPlan = 'yearly';
    } else if (purchaseDetails.productID == 'com.nutriveat.app.monthly') {
      subscriptionPlan = 'monthly';
    } else {
      subscriptionPlan = 'unknown';
    }

    // Now update the user’s subscription status in Firestore.
    // (Make sure you have access to the current user's UID.)
    // You might also want to save additional info (e.g., purchase date, expiry, etc.)
    try {
      // TODO: I think I should eventually make a single UserService provider that is updated with the user ID when the user logs in
      await userService.updateUserData(
        key: 'subscriptionStatus',
        value: subscriptionPlan,
      );
      // Optionally, show a success message or update app state.
    } catch (e) {
      // Handle errors in updating Firestore.
      debugPrint('Error updating subscription status: $e');
    }
  }

  /// Initializes the in-app purchase flow by checking availability
  /// and querying for product details.
  Future<void> initStoreInfo() async {
    // 1. Check if the device supports in-app purchases
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      // The store on this device or simulator is not available.
      _queryProductError = 'Store not available.';
      notifyListeners();
      return;
    }

    // 2. Query product details
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_subscriptionIds);

    if (response.error != null) {
      print("Error: ${response.error!.message}");
      _queryProductError = response.error!.message;
      notifyListeners();
      return;
    }

    if (response.productDetails.isEmpty) {
      print("Error: No products found.");
      _queryProductError = 'No products found.';
      notifyListeners();
      return;
    }

    // 3. Store the product details for display in the UI
    _products = response.productDetails;

    _queryProductError = null;
    notifyListeners();
  }

  Future<void> buyProduct(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    // For subscriptions (non-consumable products).
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> validateSubscription({
    required String platform, // "ios" or "android"
    required String productId,
    required PurchaseDetails purchaseDetails,
  }) async {
    // Extract receipt data based on platform.
    dynamic receiptData;
    if (platform == 'ios') {
      // For iOS, use the serverVerificationData (Base64 encoded receipt)
      receiptData = purchaseDetails.verificationData.serverVerificationData;
    } else if (platform == 'android') {
      // For Android, you might need to extract a map with packageName, productId, and purchaseToken.
      // Depending on your implementation, this might be part of the purchase details or built manually.
      receiptData = {
        'packageName': purchaseDetails
            .productID, // example placeholder, replace with actual package name
        'productId': productId,
        'purchaseToken':
            purchaseDetails.verificationData.serverVerificationData,
      };
    } else {
      throw Exception('Unsupported platform');
    }

    final callable =
        FirebaseFunctions.instance.httpsCallable('validateSubscription');
    try {
      final result = await callable.call({
        'platform': platform,
        'productId': productId,
        'receiptData': receiptData,
      });
      if (result.data['success'] == true) {
        // Handle successful subscription validation (e.g., update your UI)
        print('Subscription validated: ${result.data['subscriptionPlan']}');
      }
    } catch (error) {
      // Handle errors from the function call (display error messages, etc.)
      print('Subscription validation failed: $error');
    }
  }
}
