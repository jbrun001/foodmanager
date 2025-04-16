import '../services/firebase_service.dart';
import 'package:flutter/material.dart';

// calculates smart list from multiple data sources
Future<List<Map<String, dynamic>>> loadSmartlist({
  required FirebaseService firebaseService,
  required String userId,
  required DateTime selectedWeekStart,
  required String? selectedStore,
  required Future<List<Map<String, dynamic>>> Function()
      fetchMealPlanIngredients,
}) async {
  // list of the ingredients for the mealplan in the selected week
  List<Map<String, dynamic>> mealPlanIngredients =
      await fetchMealPlanIngredients();
  // list of the items entered manually in the smart list
  List<Map<String, dynamic>> manualItems =
      await firebaseService.getManualSmartlistItems(userId, selectedWeekStart);
  // list of the ingredients this user has
  List<Map<String, dynamic>> stockItems =
      await firebaseService.getStockItems(userId);
  // list of moqs for all ingredients in the currently selected store,
  // if no store then default to tesco
  Map<String, double> moqs =
      await firebaseService.getMoQsForStore(selectedStore ?? 'Tesco');

  // list of unique ingredients and their total amounts based on
  // meal plan ingredients and existing smartlist items
  Map<String, Map<String, dynamic>> aggregatedItems = {};

  // convert stock items into a map with ingredient name and amount
  Map<String, double> userStock = {};
  for (var stockItem in stockItems) {
    userStock[stockItem['name']] = (stockItem['amount'] as num).toDouble();
  }

  // for every ingredient in the meal plan add it to agregatedItems
  // if it exists already then increase the amount
  for (var ingredient in mealPlanIngredients) {
    // check for null values and manage
    String name = ingredient['ingredient_name'] ?? 'Unknown Ingredient';
    String unit = ingredient['unit'] ?? 'unit';
    double amount = (ingredient['amount'] as num).toDouble();
    String type = ingredient.containsKey('type') && ingredient['type'] != null
        ? ingredient['type']
        : 'General';

    if (aggregatedItems.containsKey(name)) {
      aggregatedItems[name]!['amount'] += amount;
    } else {
      aggregatedItems[name] = {
        'name': name,
        'amount': amount,
        'unit': unit,
        'type': type,
        'purchased': false,
        'isManual': false, // items from meal plan will not isManual
        'stock': userStock[name] ?? 0.0, // gets the amount based on key
        'needed': 0.0, // holder for calculating amount needed for meal plan
        'moq': moqs[name] ?? 0.0, // gets the amount based on key
        'purchase_amount': 0.0, // holder for calculating amount to purchase
        'left_over_amount':
            0.0, // holder for calculating what will be left over
      };
    }
  }

  // add manually created items, to existing ingredients if they are there
  // or as new list entries if they are not
  for (var item in manualItems) {
    String name = item['name'] ?? 'Unknown Item';
    String unit = item['unit'] ?? 'unit';
    double amount = (item['amount'] as num).toDouble();
    String type = item.containsKey('type') && item['type'] != null
        ? item['type']
        : 'General';
    // if the ingredient is already in the list from the mealplan data
    // add in the amount from the manual item else create a new item
    if (aggregatedItems.containsKey(name)) {
      aggregatedItems[name]!['amount'] += amount;
    } else {
      aggregatedItems[name] = {
        'name': name,
        'amount': amount,
        'unit': unit,
        'type': type,
        'purchased': item['purchased'] ?? false,
        'isManual': true,
        'stock': userStock[name] ?? 0.0,
        'needed': 0.0,
        'moq': moqs[name] ?? 0.0,
        'purchase_amount': 0.0,
        'left_over_amount': 0.0,
      };
    }
  }

  // go through smartlist and calculate needed amounts,
  // and what the stock level will be when the meal
  // has been cooked - left_over_amount
  aggregatedItems.forEach((key, value) {
    double required = value['amount'];
    double stock = value['stock'];
    double moq = value['moq'];
    // find out how much more is needed
    // if required > stock then we need required-stock
    // else we don't need any more so 0.0
    value['needed'] = required > stock ? required - stock : 0.0;
    // if the item is requred by the meal plan and is not needed to
    // purchase because it's already in stock then mark as already
    // purchased
    if (value['needed'] == 0.0 && value['amount'] > 0.0) {
      value['purchased'] = true;
    }
    // take account of minimum order quantities for each inggredient
    // only if we need to buy more
    if (value['needed'] > 0.0) {
      if (moq > 0.0) {
        // calculate purchase amount based on MOQ
        // value[needed]/moq finds out how many packs we need
        // the .ceil rounds this up to the nearest integer
        // moq * gets you the amount in units
        value['purchase_amount'] = moq * (value['needed'] / moq).ceil();
      } else {
        value['purchase_amount'] = value['needed'];
      }
      // testing
      if (moq == 0.0) print('smartlist calculation: $key has no MOQ set');
      print(
          'smartlist calculation: $key: Required: $required stock: $stock Needed: ${value['needed']} MOQ: $moq');
    } else {
      value['purchase_amount'] = 0.0;
      value['purchased'] = required > 0.0;
    }
    // calculate what the stock level will be after the meal is cooked
    value['left_over_amount'] = stock + value['purchase_amount'] - required;
  });

  List<Map<String, dynamic>> sortedItems = aggregatedItems.values.toList();
  sortedItems.sort((a, b) {
    if (a['purchased'] != b['purchased']) {
      return a['purchased'] ? 1 : -1;
    }
    return a['type']
        .toString()
        .toLowerCase()
        .compareTo(b['type'].toString().toLowerCase());
  });

  await firebaseService.saveSmartlistForWeek(
    userId: userId,
    weekStart: selectedWeekStart,
    items: sortedItems,
  );

  return sortedItems;
}
