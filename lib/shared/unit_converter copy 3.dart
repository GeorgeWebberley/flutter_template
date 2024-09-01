import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';

class UnitConverter {
  // Conversion table for volume units to milliliters
  static const Map<String, double> _volumeConversionTable = {
    'ml': 1.0,
    'milliliters': 1.0,
    'l': 1000.0,
    'liters': 1000.0,
    'tbsp': 15.0, // Convert tablespoons to milliliters
    'tablespoons': 15.0,
    'tsp': 5.0, // Convert teaspoons to milliliters
    'teaspoons': 5.0,
    'cups': 240.0 // Convert cups to milliliters
  };

  // Conversion table for weight units to grams
  static const Map<String, double> _weightConversionTable = {
    'g': 1.0,
    'grams': 1.0,
    'kg': 1000.0,
    'kilograms': 1000.0,
    'oz': 28.35, // Ounces to grams
    'pounds': 453.592, // Pounds to grams
  };

  // Ambiguous units conversion based on context (we'll handle these separately)
  static const Map<String, double> _ambiguousConversionTable = {
    'tbsp': 15.0, // Can be either milliliters (volume) or grams (weight)
    'tablespoons': 15.0,
    'tsp': 5.0,
    'teaspoons': 5.0,
    'cups': 240.0,
  };

  /// Normalize the unit name to a standard form.
  static String normalizeUnit(String unit) {
    unit = unit.toLowerCase();
    if (_volumeConversionTable.containsKey(unit) ||
        _weightConversionTable.containsKey(unit) ||
        _ambiguousConversionTable.containsKey(unit)) {
      return unit;
    }
    return unit; // Return the unit as-is if it's not recognized
  }

  /// Determine if a unit is a volume, weight, or ambiguous.
  static bool isVolumeUnit(String unit) {
    unit = normalizeUnit(unit);
    return _volumeConversionTable.containsKey(unit);
  }

  static bool isWeightUnit(String unit) {
    unit = normalizeUnit(unit);
    return _weightConversionTable.containsKey(unit);
  }

  static bool isAmbiguousUnit(String unit) {
    unit = normalizeUnit(unit);
    return _ambiguousConversionTable.containsKey(unit);
  }

  static bool isRecognizedUnit(String unit) {
    return isVolumeUnit(unit) || isWeightUnit(unit) || isAmbiguousUnit(unit);
  }

  /// Convert quantity to base unit (either milliliters or grams).
  static double convertToBaseUnit(double quantity, String unit) {
    String normalizedUnit = normalizeUnit(unit);
    if (isVolumeUnit(normalizedUnit)) {
      return quantity * _volumeConversionTable[normalizedUnit]!;
    } else if (isWeightUnit(normalizedUnit)) {
      return quantity * _weightConversionTable[normalizedUnit]!;
    } else if (isAmbiguousUnit(normalizedUnit)) {
      return quantity * _ambiguousConversionTable[normalizedUnit]!;
    }
    return quantity; // Return the quantity as-is for unrecognized units
  }

  /// Convert from base unit back to the preferred unit.
  static double convertFromBaseUnit(double baseQuantity, String unit) {
    String normalizedUnit = normalizeUnit(unit);
    if (isVolumeUnit(normalizedUnit)) {
      return baseQuantity / _volumeConversionTable[normalizedUnit]!;
    } else if (isWeightUnit(normalizedUnit)) {
      return baseQuantity / _weightConversionTable[normalizedUnit]!;
    }
    return baseQuantity; // Return the base quantity as-is for unrecognized units
  }

  /// Combine ingredients with a two-pass approach to handle ambiguous units.
  List<Ingredient> combineIngredients(List<Ingredient> ingredients) {
    Map<String, double> combinedQuantities = {};
    Map<String, String> finalUnits = {};
    Map<String, String> ingredientTypes =
        {}; // Track if an ingredient is weight or volume
    Map<String, List<Ingredient>> ambiguousIngredients =
        {}; // To store ambiguous units separately

    // First pass: Handle definite units and store ambiguous ones
    for (var ingredient in ingredients) {
      String normalizedUnit = normalizeUnit(ingredient.unit);
      String key = ingredient.name.toLowerCase();

      if (isAmbiguousUnit(normalizedUnit)) {
        if (ambiguousIngredients.containsKey(key)) {
          ambiguousIngredients[key]!.add(ingredient);
        } else {
          ambiguousIngredients[key] = [ingredient];
        }
        continue; // Skip ambiguous units for now
      }

      double baseQuantity = isRecognizedUnit(normalizedUnit)
          ? convertToBaseUnit(ingredient.quantity, normalizedUnit)
          : ingredient.quantity;

      if (combinedQuantities.containsKey(key)) {
        combinedQuantities[key] = combinedQuantities[key]! + baseQuantity;
      } else {
        combinedQuantities[key] = baseQuantity;
        if (isVolumeUnit(normalizedUnit)) {
          ingredientTypes[key] = 'volume';
          finalUnits[key] = 'milliliters';
        } else if (isWeightUnit(normalizedUnit)) {
          ingredientTypes[key] = 'weight';
          finalUnits[key] = 'grams';
        } else {
          finalUnits[key] =
              normalizedUnit; // Keep the original unit if unrecognized
        }
      }
    }

    // Second pass: Resolve ambiguous units
    for (var entry in ambiguousIngredients.entries) {
      String key = entry.key;
      List<Ingredient> ambiguousList = entry.value;

      if (combinedQuantities.containsKey(key)) {
        // There are already entries with definite units
        String targetType = ingredientTypes[key]!;

        for (var ambiguousIngredient in ambiguousList) {
          double baseQuantity = convertToBaseUnit(
              ambiguousIngredient.quantity, ambiguousIngredient.unit);

          if (targetType == 'volume') {
            // Convert ambiguous to milliliters
            combinedQuantities[key] = combinedQuantities[key]! + baseQuantity;
            finalUnits[key] = 'milliliters';
          } else if (targetType == 'weight') {
            // Convert ambiguous to grams
            combinedQuantities[key] = combinedQuantities[key]! + baseQuantity;
            finalUnits[key] = 'grams';
          }
        }
      } else {
        // No definite unit entries, keep the ambiguous units without conversion
        double totalQuantity = ambiguousList.fold(
            0, (sum, ingredient) => sum + ingredient.quantity);
        String unit = ambiguousList[0].unit;
        combinedQuantities[key] = totalQuantity;
        finalUnits[key] = unit; // Keep as the first ambiguous unit
      }
    }

    // Convert combined quantities back to the preferred or original units
    return combinedQuantities.entries.map((entry) {
      String unit = finalUnits[entry.key]!;
      double quantity = entry.value;

      // For unrecognized or ambiguous units without a defined type, keep original
      if (isRecognizedUnit(unit) &&
          (isVolumeUnit(unit) || isWeightUnit(unit))) {
        quantity = convertFromBaseUnit(entry.value, unit);
      }

      return Ingredient(name: entry.key, quantity: quantity, unit: unit);
    }).toList();
  }
}
