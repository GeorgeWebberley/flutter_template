import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  static const Set<String> _subscriptionIds = {
    'com.nutriveat.app.subscription',
    'com.nutriveat.app.monthly',
    'com.nutriveat.app.yearly',
  };

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  String? _queryProductError;
  String? get queryProductError => _queryProductError;

  Future<void> init() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      // handle error here.
    });

    await initStoreInfo();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (valid) {
          //   // _deliverProduct(purchaseDetails);
          // } else {
          //   // _handleInvalidPurchase(purchaseDetails);
          // }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
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

    print("Products: ${_products.map((e) => e.title).toList()}");
    _queryProductError = null;
    notifyListeners();
  }
}
