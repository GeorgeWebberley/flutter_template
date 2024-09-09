import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class EditableIngredient extends StatelessWidget {
  const EditableIngredient({
    super.key,
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
  });

  final Ingredient ingredient;
  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${ingredient.name.capitalize()} ~ ",
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
        IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete,
              color: AppColors.danger,
            )),
        IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.edit,
              color: AppColors.primary,
            )),
      ],
    );
  }
}
