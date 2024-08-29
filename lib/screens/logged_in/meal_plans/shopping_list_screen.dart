import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({
    super.key,
    required this.totalIngredients,
  });

  final List<String>? totalIngredients; // New field for total ingredients

  @override
  Widget build(BuildContext context) {
    print("totalIngredients");
    print(totalIngredients);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppPading.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTitle(title: "Shopping list"),
                AppBox(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPading.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Ingredients").h4(),
                        const SizedBox(
                          height: AppPading.large,
                        ),
                        if (totalIngredients != null)
                          ...totalIngredients!
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppPading.medium),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('•').h5(),
                                      const SizedBox(
                                        width: AppPading.medium,
                                      ),
                                      Expanded(
                                        child: Text(
                                          entry,
                                          style: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.8)),
                                        ).h5(),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
