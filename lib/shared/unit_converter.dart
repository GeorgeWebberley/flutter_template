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
  static String _normalizeUnit(String unit) => unit.toLowerCase();

  /// Determine if a unit is a volume, weight, or ambiguous.
  static bool _isVolumeUnit(String unit) =>
      _volumeConversionTable.containsKey(_normalizeUnit(unit));

  static bool _isWeightUnit(String unit) =>
      _weightConversionTable.containsKey(_normalizeUnit(unit));

  static bool _isAmbiguousUnit(String unit) =>
      _ambiguousConversionTable.containsKey(_normalizeUnit(unit));

  static bool _isRecognizedUnit(String unit) =>
      _isVolumeUnit(unit) || _isWeightUnit(unit) || _isAmbiguousUnit(unit);

  /// Convert quantity to base unit (either milliliters or grams).
  static double _convertToBaseUnit(double quantity, String unit) {
    String normalizedUnit = _normalizeUnit(unit);
    if (_isVolumeUnit(normalizedUnit)) {
      return quantity * _volumeConversionTable[normalizedUnit]!;
    } else if (_isWeightUnit(normalizedUnit)) {
      return quantity * _weightConversionTable[normalizedUnit]!;
    } else if (_isAmbiguousUnit(normalizedUnit)) {
      return quantity * _ambiguousConversionTable[normalizedUnit]!;
    }
    return quantity; // Return the quantity as-is for unrecognized units
  }

  /// Convert from base unit back to the preferred unit.
  static double _convertFromBaseUnit(double baseQuantity, String unit) {
    String normalizedUnit = _normalizeUnit(unit);
    if (_isVolumeUnit(normalizedUnit)) {
      return baseQuantity / _volumeConversionTable[normalizedUnit]!;
    } else if (_isWeightUnit(normalizedUnit)) {
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
      String normalizedUnit = _normalizeUnit(ingredient.unit);
      String key = ingredient.name.toLowerCase();

      if (_isAmbiguousUnit(normalizedUnit)) {
        if (ambiguousIngredients.containsKey(key)) {
          ambiguousIngredients[key]!.add(ingredient);
        } else {
          ambiguousIngredients[key] = [ingredient];
        }
        continue; // Skip ambiguous units for now
      }

      double baseQuantity = _isRecognizedUnit(normalizedUnit)
          ? _convertToBaseUnit(ingredient.quantity, normalizedUnit)
          : ingredient.quantity;

      if (combinedQuantities.containsKey(key)) {
        combinedQuantities[key] = combinedQuantities[key]! + baseQuantity;
      } else {
        combinedQuantities[key] = baseQuantity;
        if (_isVolumeUnit(normalizedUnit)) {
          ingredientTypes[key] = 'volume';
          finalUnits[key] = 'milliliters';
        } else if (_isWeightUnit(normalizedUnit)) {
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
          double baseQuantity = _convertToBaseUnit(
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
        // No definite unit entries, handle multiple ambiguous units separately
        Map<String, double> tempQuantities = {};
        for (var ambiguousIngredient in ambiguousList) {
          String unit = ambiguousIngredient.unit;
          if (tempQuantities.containsKey(unit)) {
            tempQuantities[unit] =
                tempQuantities[unit]! + ambiguousIngredient.quantity;
          } else {
            tempQuantities[unit] = ambiguousIngredient.quantity;
          }
        }

        // Add each ambiguous unit as a separate entry
        for (var unitEntry in tempQuantities.entries) {
          String uniqueKey = '$key (${unitEntry.key})';
          combinedQuantities[uniqueKey] =
              _convertToBaseUnit(unitEntry.value, unitEntry.key);
          finalUnits[uniqueKey] = unitEntry.key;
        }
      }
    }

    // Convert combined quantities back to the preferred or original units
    return combinedQuantities.entries.map((entry) {
      String unit = finalUnits[entry.key]!;
      double quantity = entry.value;

      if (_isRecognizedUnit(unit)) {
        quantity = _convertFromBaseUnit(entry.value, unit);
      }

      return Ingredient(name: entry.key, quantity: quantity, unit: unit);
    }).toList();
  }
}
