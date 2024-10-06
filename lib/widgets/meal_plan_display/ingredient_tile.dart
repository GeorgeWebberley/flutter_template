import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class IngredientTile extends StatelessWidget {
  const IngredientTile({
    super.key,
    required this.ingredient,
    this.onEdit,
  });

  final Ingredient ingredient;
  final Function? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•').h5(),
        const SizedBox(
          width: AppPading.medium,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${ingredient.name.capitalize()}: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 16, // Assuming h5 is similar to headline5
                  ),
                ),
                TextSpan(
                  text: formatIngredientQuantity(ingredient),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
