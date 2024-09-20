import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

// If updating, run:
// flutter pub run build_runner build --delete-conflicting-outputs
@freezed
class Ingredient with _$Ingredient {
  factory Ingredient({
    required String name,
    required double quantity,
    required String unit,
    @JsonKey(name: 'ingredient_type') String? ingredientType,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}
