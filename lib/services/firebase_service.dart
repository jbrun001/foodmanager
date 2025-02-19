import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for date formatting

// this services file contains the class for all database activity
class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // create a new user document in Firestore
  Future<void> createUser({
    required String userId,
    required String firebaseId,
    required String passwordHash,
    required int preferredPortions,
    required String preferredStore,
  }) async {
    await firestore.collection('Users').doc(userId).set({
      'firebaseId': firebaseId,
      'pwhash': passwordHash,
      'preferredPortions': preferredPortions,
      'preferredStore': preferredStore,
      'MealPlans': {},
      'StockItems': {},
      'WasteLogs': {},
      'Smartlists': {},
    }).then((_) {
      print('User created successfully');
    }).catchError((error) {
      print('Error creating user: $error');
    });
  }

  // add a meal plan to a user
  Future<void> addMealPlan({
    required String userId,
    required String mealPlanId,
    required DateTime week,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('MealPlans')
        .doc(mealPlanId)
        .set({
      'week': week,
      'Meals': {},
    }).then((_) {
      print('Meal Plan added successfully');
    }).catchError((error) {
      print('Error adding meal plan: $error');
    });
  }

  // add a meal to a users meal plan
  Future<void> addMeal({
    required String userId,
    required String mealPlanId,
    required String mealId,
    required String recipeId,
    required DateTime mealDate,
    required int portions,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('MealPlans')
        .doc(mealPlanId)
        .collection('Meals')
        .doc(mealId)
        .set({
      'recipeId': recipeId,
      'mealDate': mealDate,
      'portions': portions,
    }).then((_) {
      print('Meal added successfully');
    }).catchError((error) {
      print('Error adding meal: $error');
    });
  }

  // add a waste log record to a user
  Future<void> addWasteLog({
    required String userId,
    required String wasteId,
    required DateTime week,
    required DateTime logDate,
    required double amount,
    required double composted,
    required double inedibleParts,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('WasteLogs')
        .doc(wasteId)
        .set({
      'week': week,
      'logdate': logDate,
      'amount': amount,
      'composted': composted,
      'inedibleParts': inedibleParts,
    }).then((_) {
      print('Waste Log added successfully');
    }).catchError((error) {
      print('Error adding waste log: $error');
    });
  }

  // add a samartlist to a user
  Future<void> addSmartlist({
    required String userId,
    required String listId,
    required String storeId,
    required String mealPlanId,
    required double amount,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('Smartlists')
        .doc(listId)
        .set({
      'storeId': storeId,
      'mealPlanId': mealPlanId,
      'amount': amount,
      'SmartlistItems': {},
    }).then((_) {
      print('Smartlist added successfully');
    }).catchError((error) {
      print('Error adding smartlist: $error');
    });
  }

  // add a stock item to a user
  Future<void> addIngredient({
    required String userId,
    required String stockItemId,
    required String ingredientId,
    required double ingredientAmount,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('StockItems')
        .doc(stockItemId)
        .set({
      'ingredientId': ingredientId,
      'ingredientAmount': ingredientAmount,
    }).then((_) {
      print('Stock Item added successfully');
    }).catchError((error) {
      print('Error adding stock item: $error');
    });
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('recipes').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching recipes: $e");
      return [];
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getMealPlan(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('Users') // reference the main users collection
          .doc(userId) // target the specific user document
          .collection('MealPlans') // uery inside their mealPlans subcollection
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      Map<String, List<Map<String, dynamic>>> plan = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime mealDate = DateTime.parse(data['date']);
        String day = DateFormat('EEEE').format(mealDate);

        if (!plan.containsKey(day)) {
          plan[day] = [];
        }

        plan[day]!.add({
          'title': data['title'],
          'thumbnail': data['thumbnail'],
          'description': data['description'],
          'ingredients': data['ingredients'],
        });
      }

      return plan;
    } catch (e) {
      print("Error fetching meal plan: $e");
      return {};
    }
  }

  // saves current meal plan.
  // checks for existing meals so it doesn't duplicate
  // updates new ones
  // deletes any that don't exist any more
  Future<void> saveMealPlan(String userId, DateTime startDate,
      Map<String, List<Map<String, dynamic>>> plan) async {
    try {
      CollectionReference mealPlansRef =
          firestore.collection('Users').doc(userId).collection('MealPlans');

      // fetch existing meal plans from Firestore for the selected week
      QuerySnapshot existingMealsSnapshot = await mealPlansRef
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date',
              isLessThanOrEqualTo:
                  startDate.add(Duration(days: 6)).toIso8601String())
          .get();

      // convert existing meals into a set of document IDs
      Set<String> existingMealIds =
          existingMealsSnapshot.docs.map((doc) => doc.id).toSet();
      Set<String> newMealIds =
          {}; // track meal IDs that should exist after saving

      for (var entry in plan.entries) {
        String day = entry.key;
        List<Map<String, dynamic>> meals = entry.value;

        print('saveMealPlan: day is $day');

        for (var meal in meals) {
          String mealId =
              '${startDate.add(Duration(days: _dayOffset(day))).toIso8601String()}-${meal['title']}';
          newMealIds.add(mealId); // keep track of meals that should remain

          print(' mealId: saving: $mealId');

          await mealPlansRef.doc(mealId).set({
            'userId': userId,
            'date': startDate
                .add(Duration(days: _dayOffset(day)))
                .toIso8601String(),
            'title': meal['title'],
            'thumbnail': meal['thumbnail'] ?? '',
            'description': meal['description'] ?? '',
            'ingredients': meal['ingredients'] ?? [],
          });
        }
      }

      // find meals that were deleted and remove them from Firestore
      Set<String> mealsToDelete = existingMealIds.difference(newMealIds);
      for (String mealId in mealsToDelete) {
        await mealPlansRef.doc(mealId).delete();
      }

      print("Meal plan updated successfully");
    } catch (e) {
      print("Error saving meal plan: $e");
    }
  }

  int _dayOffset(String day) {
    const dayOffsets = {
      'Sunday': 0,
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
    };
    return dayOffsets[day] ?? 0;
  }

  Future<List<Map<String, dynamic>>> getStockItems(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('Users')
          .doc(userId)
          .collection('StockItems')
          .orderBy('ingredientId') // sort
          .get();
//debug
      print(
          "Stock Items Query Snapshot: ${snapshot.docs.map((d) => d.data())}");

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
//debug
        print("Document ID: ${doc.id}, Data: $data");

        return {
          'id': doc.id,
          'name': data['ingredientId'] ?? 'Unknown',
          'amount': data['ingredientAmount'] ?? 0,
          'unit':
              data.containsKey('unit') ? data['unit'] : 'g', // default to grams
          'type': data.containsKey('type')
              ? data['type']
              : 'Unknown', // default category
        };
      }).toList();
    } catch (e) {
      print("Error fetching stock items: $e");
      return [];
    }
  }

  Future<void> addUserStockItem(
      {required String userId,
      required String stockItemId,
      required String ingredientId,
      required double ingredientAmount,
      required String ingredientUnit,
      required String ingredientType}) async {
//debug
    print("Saving ingredient to Firestore...");
    print(
        "User ID: $userId, StockItem ID: $stockItemId, Ingredient ID: $ingredientId");
    print(
        "Amount: $ingredientAmount, Unit: $ingredientUnit, Type: $ingredientType");

    try {
      await firestore
          .collection('Users')
          .doc(userId)
          .collection('StockItems')
          .doc(stockItemId)
          .set({
        'ingredientId': ingredientId,
        'ingredientAmount': ingredientAmount,
        'unit': ingredientUnit,
        'type': ingredientType,
      });
    } catch (e) {
      print("Firestore save failed: $e");
    }
  }

  // fetch smartlist items for a specific user and date
  Future<List<Map<String, dynamic>>> getSmartlist(
      String userId, DateTime date) async {
    try {
      String dateKey = date.toIso8601String(); // Store date as ISO 8601
// debug
      print("Fetching smartlist for user $userId on date $dateKey");

      QuerySnapshot querySnapshot = await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .where('date', isEqualTo: dateKey)
          .get();

// debug
      print("Fetched ${querySnapshot.docs.length} items");

      return querySnapshot.docs.map((doc) {
// debug
        print("Retrieved item: ${doc['name']}, purchased: ${doc['purchased']}");
        return {
          'id': doc.id,
          'name': doc['name'],
          'amount': doc['amount'],
          'unit': doc['unit'],
          'type': doc['type'],
          'purchased': doc['purchased'],
          'date': doc['date'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching smartlist: $e");
      return [];
    }
  }

  // add a new item to the smartlist if it does not already exist
  Future<void> addSmartlistItem({
    required String userId,
    required String name,
    required int amount,
    required String unit,
    required String type,
    required DateTime date,
  }) async {
    try {
      String dateKey = date.toIso8601String(); // convert date to ISO 8601
      String docId = "${dateKey}_$name"; // unique key: ISO date + item name

// debug
      print(
          "Checking if item '$name' already exists for user $userId on date $dateKey");

      DocumentSnapshot docSnapshot = await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .doc(docId)
          .get();

      if (!docSnapshot.exists) {
// debug
        print("Item '$name' does not exist, adding to Firestore.");

        await firestore
            .collection('Users')
            .doc(userId)
            .collection('SmartLists')
            .doc(docId)
            .set({
          'name': name,
          'amount': amount,
          'unit': unit,
          'type': type,
          'purchased': false,
          'date': dateKey,
        });

        print("Item '$name' successfully added to Firestore.");
      } else {
        print(
            "Item '$name' already exists on '$dateKey', not adding duplicate.");
      }
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  // update item status (toggle purchased state)
  Future<void> updateSmartlistItem(
      String userId, String name, DateTime date, bool purchased) async {
    try {
      String dateKey = date.toIso8601String();
      String docId = "${dateKey}_$name";

// debug
      print(
          "Updating item '$name' for user $userId on date $dateKey to purchased: $purchased");

      await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .doc(docId)
          .update({'purchased': purchased});

      print("Successfully updated '$name' purchased status to: $purchased");
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  // delete an item from the smartlist
  Future<void> deleteSmartlistItem(
      String userId, String name, DateTime date) async {
    try {
      String dateKey = date.toIso8601String();
      String docId = "${dateKey}_$name";

// debug: Logging deletion attempt
      print(
          "Attempting to delete item '$name' for user $userId on date $dateKey");

      await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .doc(docId)
          .delete();
      print("Successfully deleted '$name' from Firestore.");
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  // fetch all ingredients from firestore
  // used when adding a new ingredient to user stock items
  Future<List<Map<String, dynamic>>> getIngredients() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('Ingredients').get();

      // map Firebase data to a list of maps
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? '',
          'unit': data['unit'] ?? '',
          'type': data['type'] ?? '',
          'Moqs': data['Moqs'] ?? [],
        };
      }).toList();
    } catch (e) {
      print("Error fetching ingredients: $e");
      return [];
    }
  }

  // get the minimum order quantities for the passed storename
  Future<Map<String, double>> getMoQsForStore(String storeName) async {
    try {
      QuerySnapshot snapshot = await firestore.collection('Ingredients').get();

      Map<String, double> moqMap = {};

      print(
          "Fetched ${snapshot.docs.length} documents from Ingredients collection.");

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        print(
            "Document ID: ${doc.id}, Data: $data"); // Debug full document data

        if (data.containsKey('Moqs') && data['Moqs'] is List) {
          List<dynamic> moqList = data['Moqs']; // list

          for (var moqData in moqList) {
            if (moqData is Map<String, dynamic> &&
                moqData.containsKey('storeName') &&
                moqData['storeName'] == storeName &&
                moqData.containsKey('amount')) {
              String ingredientName = data['name'] ?? doc.id;
              double moq = (moqData['amount'] as num).toDouble();
              String moqUnit = moqData['units'] ?? 'unit';

              print("Matched MOQ for Store: $storeName");
              print("Ingredient: $ingredientName, MOQ: $moq $moqUnit");

              moqMap[ingredientName] = moq;
            }
          }
        } else {
          print("No valid 'Moqs' field found for document ID: ${doc.id}");
        }
      }

      print("Final MOQ Map: $moqMap");
      return moqMap;
    } catch (e) {
      print("Error fetching MOQ data: $e");
      return {};
    }
  }
}
