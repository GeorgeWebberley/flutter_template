import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/providers/in_app_purchase_provider.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Dummy plan details
  final String _monthlyPrice = '\$4.99/month';
  final String _yearlyPrice = '\$24.99/year';
  ProductDetails? _monthlyPlan;
  ProductDetails? _yearlyPlan;

  @override
  void initState() {
    super.initState();
    initialiseProducts();
  }

  initialiseProducts() {
    List<ProductDetails> products =
        Provider.of<InAppPurchaseProvider>(context, listen: false).products;

    // Monthly plan is the cheaper of the two
    if (products.length == 2) {
      ProductDetails product1 = products[0];
      ProductDetails product2 = products[1];
      if (product1.price.compareTo(product2.price) == -1) {
        _yearlyPlan = product1;
        _monthlyPlan = product2;
      } else {
        _monthlyPlan = product1;
        _yearlyPlan = product2;
      }
    }

    for (ProductDetails product in products) {
      print(product.id);
      print(product.title);
      print(product.description);
      print(product.price);
    }
  }

  // Callback for “Skip” (free trial) logic
  void _onSkip() {
    // Navigate or update state to reflect skipping purchase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Skipped subscription — Free trial started.')),
    );
  }

  // Callback for plan selection logic
  void _onPlanSelected(ProductDetails product) {
    Provider.of<InAppPurchaseProvider>(context, listen: false)
        .buyProduct(product)
        .catchError((e) {
      // Handle errors here (e.g., show a message to the user)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // A simple gradient background for a polished look
        decoration: const BoxDecoration(
          // gradient: AppGradients.buttonPrimaryGradient,
          // Add a background image
          image: DecorationImage(
            image: AssetImage('assets/images/subscribe_1_edit_3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Header / Title
            Padding(
              padding: EdgeInsets.only(top: screenSize.width * 0.25),
              child: Text(
                "Go Premium",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: screenSize.width * 0.6,
              child: Text(
                "Enjoy unlimited access and exclusive features",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
            ),
            SizedBox(height: screenSize.width * 0.3),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPading.page),
              child: Column(
                children: [
                  _buildFeatureDescription("Personalised meal plans"),
                  SizedBox(height: 5),
                  _buildFeatureDescription("Unlimited recipes"),
                  SizedBox(height: 5),
                  _buildFeatureDescription("Compiled shopping lists"),
                  SizedBox(height: 5),
                  _buildFeatureDescription("AI assistant chef"),
                ],
              ),
            ),
            SizedBox(height: AppPading.large),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display subscription options as buttons
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppPading.page, vertical: AppPading.page),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                            clipBehavior: Clip
                                .none, // Allow the badge to extend outside the button
                            children: [
                              if (_yearlyPlan != null)
                                ElevatedButton(
                                  onPressed: () =>
                                      _onPlanSelected(_yearlyPlan!),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Yearly Plan',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '£49.99',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.w400,
                                                  decorationColor: Colors.red,
                                                  decorationThickness: 2,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "${_yearlyPlan?.price ?? ''}/year",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: -14, // Extend the badge outside the button
                                right: -10, // Position it at the corner
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 227, 175, 45),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Best Value!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          // Monthly plan
                          if (_monthlyPlan != null)
                            ElevatedButton(
                              onPressed: () => _onPlanSelected(_monthlyPlan!),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.4),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monthly Plan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "${_monthlyPlan?.price ?? ''}/month",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // SizedBox(height: 20),
                          // Yearly plan
                          // Stack(
                          //   clipBehavior: Clip
                          //       .none, // Allow the badge to extend outside the button
                          //   children: [
                          //     ElevatedButton(
                          //       onPressed: () => _onPlanSelected('yearly'),
                          //       style: ElevatedButton.styleFrom(
                          //         elevation: 0,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(20),
                          //         ),
                          //         backgroundColor: AppColors.primary,
                          //       ),
                          //       child: Padding(
                          //         padding:
                          //             const EdgeInsets.symmetric(vertical: 15),
                          //         child: Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             Text(
                          //               'Yearly Plan',
                          //               style: TextStyle(
                          //                 color: Colors.white,
                          //                 fontSize: 20,
                          //               ),
                          //             ),
                          //             Text(
                          //               _yearlyPrice,
                          //               style: TextStyle(
                          //                 color: Colors.white,
                          //                 fontSize: 20,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //     Positioned(
                          //       top: -10, // Extend the badge outside the button
                          //       right: -10, // Position it at the corner
                          //       child: Container(
                          //         padding: const EdgeInsets.symmetric(
                          //             horizontal: 10, vertical: 5),
                          //         decoration: BoxDecoration(
                          //           color: AppColors.tertiary,
                          //           borderRadius: BorderRadius.circular(15),
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: Colors.black26,
                          //               blurRadius: 5,
                          //               offset: Offset(2, 2),
                          //             ),
                          //           ],
                          //         ),
                          //         child: Row(
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: [
                          //             Icon(
                          //               Icons.star,
                          //               color: Colors.white,
                          //               size: 16,
                          //             ),
                          //             const SizedBox(width: 5),
                          //             Text(
                          //               'Best Value!',
                          //               style: TextStyle(
                          //                 color: Colors.white,
                          //                 fontWeight: FontWeight.bold,
                          //                 fontSize: 12,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: AppPading.large,
                                right: AppPading.large,
                                left: AppPading.large),
                            child: Row(children: [
                              Expanded(
                                  child: Divider(
                                color: Colors.black.withOpacity(0.5),
                              )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppPading.medium),
                                child: Text("or",
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                    )).h4(),
                              ),
                              Expanded(
                                  child: Divider(
                                color: Colors.black.withOpacity(0.5),
                              )),
                            ]),
                          ),

                          // Skip button
                          TextButton(
                            onPressed: _onSkip,
                            child: Text(
                              'Skip for now',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.75),
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row _buildFeatureDescription(String text) {
    return Row(
      children: [
        // Display checkmark image
        Image.asset(
          'assets/icons/check.png',
          width: 40,
          height: 40,
        ),

        SizedBox(width: 15),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
      ],
    );
  }
}
