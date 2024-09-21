import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';

class UnitConverter {
  // Conversion tables (unchanged from your original code)
  static const Map<String, double> _volumeConversionTable = {
    'ml': 1.0,
    'milliliters': 1.0,
    'l': 1000.0,
    'liters': 1000.0,
    'tbsp': 15.0,
    'tablespoons': 15.0,
    'tsp': 5.0,
    'teaspoons': 5.0,
    'cups': 240.0,
  };

  static const Map<String, double> _weightConversionTable = {
    'g': 1.0,
    'grams': 1.0,
    'kg': 1000.0,
    'kilograms': 1000.0,
    'oz': 28.35,
    'pounds': 453.592,
  };

  static const Map<String, double> _ambiguousConversionTable = {
    'tbsp': 15.0,
    'tablespoons': 15.0,
    'tsp': 5.0,
    'teaspoons': 5.0,
    'cups': 240.0,
  };

  static String _normalizeUnit(String unit) => unit.toLowerCase();

  static bool _isVolumeUnit(String unit) =>
      _volumeConversionTable.containsKey(_normalizeUnit(unit));

  static bool _isWeightUnit(String unit) =>
      _weightConversionTable.containsKey(_normalizeUnit(unit));

  static bool _isAmbiguousUnit(String unit) =>
      _ambiguousConversionTable.containsKey(_normalizeUnit(unit));

  static bool _isRecognizedUnit(String unit) =>
      _isVolumeUnit(unit) || _isWeightUnit(unit) || _isAmbiguousUnit(unit);

  static double _convertToBaseUnit(double quantity, String unit) {
    String normalizedUnit = _normalizeUnit(unit);
    if (_isVolumeUnit(normalizedUnit)) {
      return quantity * _volumeConversionTable[normalizedUnit]!;
    } else if (_isWeightUnit(normalizedUnit)) {
      return quantity * _weightConversionTable[normalizedUnit]!;
    } else if (_isAmbiguousUnit(normalizedUnit)) {
      return quantity * _ambiguousConversionTable[normalizedUnit]!;
    }
    return quantity;
  }

  static double _convertFromBaseUnit(double baseQuantity, String unit) {
    String normalizedUnit = _normalizeUnit(unit);
    if (_isVolumeUnit(normalizedUnit)) {
      return baseQuantity / _volumeConversionTable[normalizedUnit]!;
    } else if (_isWeightUnit(normalizedUnit)) {
      return baseQuantity / _weightConversionTable[normalizedUnit]!;
    }
    return baseQuantity;
  }

  List<Ingredient> combineIngredients(List<Ingredient> ingredients) {
    Map<String, double> combinedQuantities = {};
    Map<String, String> finalUnits = {};
    Map<String, String> finalTypes = {}; // Track the ingredient types
    Map<String, List<Ingredient>> ambiguousIngredients = {};

    ingredients = ingredients
        .map((ingredient) => Ingredient(
            name: ingredient.name,
            quantity: ingredient.quantity,
            unit: ingredient.unit.endsWith('s')
                ? ingredient.unit.toLowerCase()
                : ingredient.unit.toLowerCase() + 's',
            ingredientType: ingredient
                .ingredientType)) // Ensure we preserve the ingredient type
        .toList();

    for (var ingredient in ingredients) {
      String normalizedUnit = _normalizeUnit(ingredient.unit);
      String key = ingredient.name.toLowerCase();

      // Handle unrecognized units
      if (!_isRecognizedUnit(normalizedUnit)) {
        String uniqueKey = key;
        // If we want the brackets after the name e.g. Onions (pieces)
        // String uniqueKey = '$key (${ingredient.unit})';
        if (combinedQuantities.containsKey(uniqueKey)) {
          combinedQuantities[uniqueKey] =
              combinedQuantities[uniqueKey]! + ingredient.quantity;
        } else {
          combinedQuantities[uniqueKey] = ingredient.quantity;
          finalUnits[uniqueKey] = ingredient.unit;
          finalTypes[uniqueKey] = ingredient.ingredientType ?? "other";
        }
        continue;
      }

      if (_isAmbiguousUnit(normalizedUnit)) {
        if (ambiguousIngredients.containsKey(key)) {
          ambiguousIngredients[key]!.add(ingredient);
        } else {
          ambiguousIngredients[key] = [ingredient];
        }
        continue;
      }

      double baseQuantity =
          _convertToBaseUnit(ingredient.quantity, normalizedUnit);

      if (combinedQuantities.containsKey(key)) {
        combinedQuantities[key] = combinedQuantities[key]! + baseQuantity;
      } else {
        combinedQuantities[key] = baseQuantity;
        finalTypes[key] =
            ingredient.ingredientType ?? "other"; // Preserve the ingredientType
        if (_isVolumeUnit(normalizedUnit)) {
          finalUnits[key] = 'milliliters';
        } else if (_isWeightUnit(normalizedUnit)) {
          finalUnits[key] = 'grams';
        } else {
          finalUnits[key] = normalizedUnit;
        }
      }
    }

    // Resolve ambiguous units (similar to your current approach)
    for (var entry in ambiguousIngredients.entries) {
      String key = entry.key;
      List<Ingredient> ambiguousList = entry.value;

      if (combinedQuantities.containsKey(key)) {
        String? targetType = finalTypes[key];

        for (var ambiguousIngredient in ambiguousList) {
          double baseQuantity = _convertToBaseUnit(
              ambiguousIngredient.quantity, ambiguousIngredient.unit);

          if (targetType == 'volume') {
            combinedQuantities[key] = combinedQuantities[key]! + baseQuantity;
            finalUnits[key] = 'milliliters';
          } else if (targetType == 'weight') {
            combinedQuantities[key] = combinedQuantities[key]! + baseQuantity;
            finalUnits[key] = 'grams';
          }
        }
      }
    }

    // Convert back to original or preferred units
    return combinedQuantities.entries.map((entry) {
      String unit = finalUnits[entry.key]!;
      double quantity = entry.value;
      String ingredientType = finalTypes[entry.key]!; // Include the type

      if (_isRecognizedUnit(unit)) {
        quantity = _convertFromBaseUnit(entry.value, unit);
      }

      return Ingredient(
        name: entry.key,
        quantity: quantity,
        unit: unit,
        ingredientType: ingredientType, // Return the ingredientType
      );
    }).toList();
  }
}
