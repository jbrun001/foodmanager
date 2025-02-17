import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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

  // add a stock item to a user
  Future<void> addStockItem({
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

  // add an item to a smartlist
  Future<void> addSmartlistItem({
    required String userId,
    required String listId,
    required String listItemId,
    required String ingredientId,
    required double amount,
    required bool purchased,
    required double leftoverAmount,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('Smartlists')
        .doc(listId)
        .collection('SmartlistItems')
        .doc(listItemId)
        .set({
      'ingredientId': ingredientId,
      'amount': amount,
      'purchased': purchased,
      'leftoverAmount': leftoverAmount,
    }).then((_) {
      print('Smartlist Item added successfully');
    }).catchError((error) {
      print('Error adding smartlist item: $error');
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
}
