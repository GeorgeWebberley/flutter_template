import 'package:flutter_firebase_template/models/ingredient/ingredient.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

String formatTime(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}

String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

String formatDateWithSuffix(DateTime? dateTime,
    {bool includeTime = true, bool includeDate = true}) {
  if (dateTime == null) {
    return "";
  }
  var day = dateTime.day;
  var suffix = "th";

  // Determine the suffix for the day
  int lastDigit = day % 10;
  if ((day > 10 && day < 20) || lastDigit > 3) {
    suffix = "th";
  } else if (lastDigit == 1) {
    suffix = "st";
  } else if (lastDigit == 2) {
    suffix = "nd";
  } else if (lastDigit == 3) {
    suffix = "rd";
  }

  // Formatting the date and time
  String formattedDate =
      DateFormat('d').format(dateTime); // Day without leading zero
  String month = DateFormat('MMMM').format(dateTime); // Month as full name
  String year = DateFormat('y').format(dateTime); // Year with all digits
  String time = DateFormat('jm').format(dateTime); // Time in am/pm format

  return includeTime && includeDate
      ? "$formattedDate$suffix $month $year at $time"
      : includeTime
          ? time
          : "$formattedDate$suffix $month $year";
}

List<Ingredient> getTotalIngredients(List<Recipe> recipes) {
  List<Ingredient> ingredients = [];
  for (var recipe in recipes) {
    for (var ingredient in recipe.ingredients) {
      ingredients.add(ingredient);
    }
  }
  return ingredients.toSet().toList();
}

String formatIngredientQuantity(Ingredient ingredient) {
  String unit = ingredient.unit;
  num quantity = ingredient.quantity;
  if (ingredient.quantity == 1 && ingredient.unit.endsWith('s')) {
    unit = ingredient.unit.substring(0, ingredient.unit.length - 1);
  }

  if (ingredient.quantity == ingredient.quantity.toInt()) {
    quantity = ingredient.quantity.toInt();
  }
  return "$quantity $unit";
}
