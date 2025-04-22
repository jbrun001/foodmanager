import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for authentication
import 'package:google_sign_in/google_sign_in.dart'; // for oauth2 authentication
import 'package:intl/intl.dart'; // for date formatting
import 'package:flutter/foundation.dart'
    show kIsWeb; // for detecting if running running on web
import 'package:universal_platform/universal_platform.dart'; // for identifying non web platforms
import '../services/testing_service.dart'; // for logging test data

// this services file contains the class for all database activity
class FirebaseService {
  // firebase database object
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // firebase authentication object
  final FirebaseAuth auth = FirebaseAuth.instance;

  // create a new user document in Firestore for testing
  Future<void> createUserPOC({
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
      testLog('fb_service.createUserPoC', 'saved', {'id': firebaseId});
    }).catchError((e) {
      testLog('fb_service.createUserPoC', 'save failed',
          {'id': firebaseId, 'error': e.toString()});
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
      testLog('fb_service.addMealPlan', 'saved', {'meal plan': mealPlanId});
    }).catchError((e) {
      testLog('fb_service.addMealPlan', 'save', {'error': e.toString()});
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
      testLog('fb_service.addMeal', 'saved', {'mealPlanId': mealPlanId});
    }).catchError((e) {
      testLog('fb_service.addMeal', 'save', {'error': e.toString()});
    });
  }

  // add a waste log record to a user
  Future<void> addWasteLog({
    required String userId,
    required String wasteId,
    required DateTime week,
    required DateTime logDate,
    required double amount,
    required double recycled,
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
      'recycled': recycled,
      'composted': composted,
      'inedibleParts': inedibleParts,
    }).then((_) {
      testLog('fb_service.addWasteLog', 'saved', {'wasteId': wasteId});
    }).catchError((e) {
      testLog('fb_service.addWasteLog', 'save failed', {'error': e.toString()});
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
      testLog('fb_service.addSmartList', 'saved', {'listId': listId});
    }).catchError((e) {
      testLog('fb_service.addSmartList', 'save', {'error': e.toString()});
    });
  }

  // add a stock item to a user from an ingredient
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
      testLog('fb_service.addIngredient', 'saved', {'name': ingredientId});
    }).catchError((e) {
      testLog('fb_service.addIngredient', 'save', {'error': e.toString()});
    });
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('recipes').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      testLog('fb_service.getRecipes', 'save', {'error': e.toString()});
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
          'ingredientsOriginal':
              List<Map<String, dynamic>>.from(data['ingredients']),
          'plannedPortions': data['plannedPortions'] ?? data['portions'] ?? 1,
          'portions': data['portions'] ?? 1,
        });
      }

      return plan;
    } catch (e) {
      testLog('fb_service.geMealPlan', 'get', {'error': e.toString()});
      return {};
    }
  }

  // saves current meal plan
  // checks for existing meals so it doesn't duplicate
  // updates new ones
  // deletes any meals that don't exist any more
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
        testLog('fb_service.saveMealPlan', 'processing...', {'day': day});
        for (var meal in meals) {
          String mealId =
              '${startDate.add(Duration(days: _dayOffset(day))).toIso8601String()}-${meal['title']}';
          newMealIds.add(mealId); // keep track of meals that should remain
          testLog('fb_service.saveMealPlan', '  saving...', {'mealId': mealId});
          await mealPlansRef.doc(mealId).set({
            'userId': userId,
            'date': startDate
                .add(Duration(days: _dayOffset(day)))
                .toIso8601String(),
            'title': meal['title'],
            'thumbnail': meal['thumbnail'] ?? '',
            'description': meal['description'] ?? '',
            'ingredients': meal['ingredients'] ?? [],
            'ingredientsOriginal': meal['ingredientsOriginal'] ?? [],
            // add in plannedPortions
            'plannedPortions': meal['plannedPortions'] ?? meal['portions'] ?? 1,
            'portions': meal['portions'] ?? 1,
          });
        }
      }

      // find meals that were deleted and remove them from Firestore
      Set<String> mealsToDelete = existingMealIds.difference(newMealIds);
      for (String mealId in mealsToDelete) {
        await mealPlansRef.doc(mealId).delete();
      }

      testLog('fb_service.saveMealPlan', 'Meal plan updated successfully', {});
    } catch (e) {
      testLog(
          'fb_service.saveMealPlan', 'save failed', {'error': e.toString()});
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
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        testLog('fb_service.getStockItems', 'Stock item',
            {'doc.id': doc.id, 'data': data});
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
      testLog(
          'fb_service.getStockItems', 'get failed', {'error': e.toString()});
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
    testLog('fb_service.addUserStockItem', 'saving', {
      'user': userId,
      'stockItemId': stockItemId,
      'ingredientId': ingredientId,
      'ingredientAmount': ingredientAmount,
      'ingredientUnit': ingredientUnit,
      'ingredientType': ingredientType,
    });

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
      testLog('fb_service.addUserStockItem', 'save failed',
          {'error': e.toString()});
    }
  }

  // fetch smartlist items for a specific user and date
  Future<List<Map<String, dynamic>>> getSmartlist(
      String userId, DateTime date) async {
    try {
      String dateKey = date.toIso8601String(); // Store date as ISO 8601
      testLog('fb_service.getSmartList', 'getting smartlist for',
          {'user': userId, 'date': dateKey});
      QuerySnapshot querySnapshot = await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .where('date', isEqualTo: dateKey)
          .get();
      testLog('fb_service.getSmartList', 'items',
          {'count': querySnapshot.docs.length});
      return querySnapshot.docs.map((doc) {
        testLog('fb_service.getSmartList', 'items',
            {'name': doc['name'], 'purchased': doc['purchased']});
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
      testLog('fb_service.getSmartList', 'get failed',
          {'date': date, 'error': e.toString()});
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

      DocumentSnapshot docSnapshot = await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .doc(docId)
          .get();

      if (!docSnapshot.exists) {
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
        testLog('fb_service.addSmartListItem', 'item saved',
            {'item': name, 'date': dateKey});
      } else {
        testLog('fb_service.addSmartListItem', 'duplicate not added',
            {'item': name, 'date': dateKey});
      }
    } catch (e) {
      testLog('fb_service.addSmartListItem', 'save failed',
          {'item': name, 'error': e.toString()});
    }
  }

  // update item status (toggle purchased state)
  Future<void> updateSmartlistItem(
      String userId, String name, DateTime date, bool purchased) async {
    try {
      String dateKey = date.toIso8601String();
      String docId = "${dateKey}_$name";

      await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .doc(docId)
          .update({'purchased': purchased});
      testLog('fb_service.updateSmartListItem', 'saved',
          {'item': name, 'purchased?': purchased});
    } catch (e) {
      testLog('fb_service.updateSmartListItem', 'save failed',
          {'item': name, 'error': e.toString()});
    }
  }

  // delete an item from the smartlist
  Future<void> deleteSmartlistItem(
      String userId, String name, DateTime date) async {
    try {
      String dateKey = date.toIso8601String();
      String docId = "${dateKey}_$name";
      await firestore
          .collection('Users')
          .doc(userId)
          .collection('SmartLists')
          .doc(docId)
          .delete();
      testLog('fb_service.deleteSmartListItem', 'deleted', {'docId': docId});
    } catch (e) {
      testLog('fb_service.deleteSmartListItem', 'delete failed',
          {'item': name, 'error': e.toString()});
    }
  }

  // save the full smartlist for one week
  // include flag for stock updated
  Future<void> saveSmartlistForWeek({
    required String userId,
    required DateTime weekStart,
    required List<Map<String, dynamic>> items,
    bool stockUpdated = false,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('SmartLists')
        .doc(DateFormat('yyyy-MM-dd').format(weekStart))
        .set({
      'weekStart': weekStart,
      'items': items,
      'stockUpdated': stockUpdated,
    }, SetOptions(merge: true));
  }

  // load the full smartlist for one week
  Future<List<Map<String, dynamic>>> getSmartlistForWeek(
      String userId, DateTime weekStart) async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('SmartLists')
        .doc(DateFormat('yyyy-MM-dd').format(weekStart))
        .get();

    if (doc.exists) {
      final data = doc.data();
      final items = List<Map<String, dynamic>>.from(data?['items'] ?? []);
      testLog('fb_service.getSmartlistForWeek', 'not found', {
        'week': DateFormat('yyyy-MM-dd').format(weekStart),
        'item count': items.length
      });
      return items;
    } else {
      testLog('fb_service.getSmartlistForWeek', 'not found',
          {'week': DateFormat('yyyy-MM-dd').format(weekStart)});
      return [];
    }
  }

  // retrieve only the manual items from the smartlist
  Future<List<Map<String, dynamic>>> getManualSmartlistItems(
      String userId, DateTime weekStart) async {
    final allItems = await getSmartlistForWeek(userId, weekStart);
    return allItems.where((item) => item['isManual'] == true).toList();
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
      testLog(
          'fb_service.getIngredients', 'get failed', {'error': e.toString()});
      return [];
    }
  }

  // get the minimum order quantities for the passed storename
  Future<Map<String, double>> getMoQsForStore(String storeName) async {
    try {
      QuerySnapshot snapshot = await firestore.collection('Ingredients').get();
      Map<String, double> moqMap = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

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
              testLog('fb_service.getMoQForStore', 'matched moq', {
                'storeName': storeName,
                'ingredientName': ingredientName,
                'moq': moq,
                'moqUnit': moqUnit
              });
              moqMap[ingredientName] = moq;
            }
          }
        } else {
          testLog('fb_service.getMoQForStore', 'no valid MOQ field',
              {'docId': doc.id});
        }
      }
      testLog('fb_service.getMoQForStore', 'MoQ result', {'map': moqMap});
      return moqMap;
    } catch (e) {
      testLog('fb_service.getMoQForStore', 'get failed',
          {'item': storeName, 'error': e.toString()});
      return {};
    }
  }

  // authentication methods
  // Email & Password Sign-Up
  Future<User?> signUpWithEmail(
      String email, String password, int portions, String store) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        testLog('fb_service.signUpWithEmail', 'user signing up',
            {'email': email, 'uid': user.uid});
        await createUserSignUp(user.uid, email, portions, store);
      }
      return user;
    } catch (e) {
      testLog('fb_service.signUpWithEmail', 'save failed', {'error': e});
      return null;
    }
  }

  // Email & Password Login
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      testLog('fb_service.signInWithEmail', 'Logged in',
          {'user': userCredential.user?.uid});
      return userCredential.user;
    } catch (e) {
      testLog(
          'fb_service.signInWithEmail', 'Logged in', {'error': e.toString()});
      return null;
    }
  }

  // google Sign-In
  // https://medium.com/@mohantaankit2002/best-practices-for-handling-flutter-web-and-mobile-app-variants-in-a-single-codebase-543f74f67a9a
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
        User? user = userCredential.user;

        if (user != null) {
          testLog('fb_service.signInWithGoogle', 'Google Log in web',
              {'user': user.uid});
          await createUserSignUp(
              user.uid, user.email ?? '', 2, "Tesco"); // default values
        }
        return user;
      } else if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
        // iOS and android use the same function
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          testLog(
              'fb_service.signInWithGoogle', 'google sign in cancelled', {});
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await auth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          testLog('fb_service.signInWithGoogle', 'logged in iOS/Android',
              {'user': user.uid});
          await createUserSignUp(
              user.uid, user.email ?? '', 2, "Tesco"); // default values
        }
        return user;
      } else {
        // if we are here we are not running on web iOS or Android
        // which are the target platforms
        testLog('fb_service.signInWithGoogle', 'platform not supported', {});
        return null;
      }
    } catch (e) {
      testLog('fb_service.signInWithGoogle', 'log in', {'error': e.toString()});
      return null;
    }
  }

  // Create or Update User in Firebase
  Future<void> createUserSignUp(
      String userId, String email, int portions, String store) async {
    try {
      DocumentReference userDoc = firestore.collection('Users').doc(userId);
      DocumentSnapshot doc = await userDoc.get();

      if (!doc.exists) {
        await userDoc.set({
          'email': email,
          'preferredPortions': portions,
          'preferredStore': store,
          'createdAt': FieldValue.serverTimestamp(),
        });
        testLog('fb_service.createUserSignUp', 'saved', {'userId': userId});
      } else {
        testLog('fb_service.createUserSignUp', 'duplicate not saving',
            {'userId': userId});
      }
    } catch (e) {
      testLog('fb_service.createUserSignUp', 'save failed',
          {'error': e.toString()});
    }
  }

  // function to get the currently logged in userId
  // returns the userId or returns '' if not logged in.
  String getCurrentUserId() {
    User? user = auth.currentUser; // get the current user
    if (user != null) {
      testLog('fb_service.getCurrentUserId', '', {'user': user.uid});
      return user.uid;
    } else {
      testLog('fb_service.getCurrentUserId', 'no user logged in', {});
      return '';
    }
  }

  // fetches the user document from Firestore and returns its data as a map
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('Users').doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      testLog(
          'fb_service.getUserDetails', 'get failed', {'error': e.toString()});
      return null;
    }
  }

  // updates the user's profile details in Firestore.
  Future<void> updateUserProfile({
    required String userId,
    required String email,
    required int preferredPortions,
    required String preferredStore,
  }) async {
    try {
      await firestore.collection('Users').doc(userId).update({
        'email': email,
        'preferredPortions': preferredPortions,
        'preferredStore': preferredStore,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      testLog('fb_service.updateUserProfile', 'saved', {'userId': userId});
    } catch (e) {
      testLog('fb_service.updateUserProfile', 'save failed',
          {'error': e.toString()});
    }
  }

  // fetches the list of store names from the "Stores" collection.
  // If no store is found, it creates one with the name "Tesco" and returns it
  Future<List<String>> getStores() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('Store').get();
      if (snapshot.docs.isEmpty) {
        // No stores found – create a default store "Tesco"
        await firestore.collection('Store').add({'name': 'Tesco'});
        return ['Tesco'];
      } else {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['name'] as String;
        }).toList();
      }
    } catch (e) {
      testLog('fb_service.getStores', 'get failed', {'error': e.toString()});
      return [];
    }
  }

  // retrieves waste log records for a week
  // used in the waste log analytics graphs
  Future<List<Map<String, dynamic>>> getWasteLogsForWeek({
    required String userId,
    required DateTime weekStart,
  }) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    QuerySnapshot snapshot = await firestore
        .collection('Users')
        .doc(userId)
        .collection('WasteLogs')
        .where('logdate', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('logdate', isLessThanOrEqualTo: Timestamp.fromDate(weekEnd))
        .get();
    testLog('fb_service.getWasteLogsForWeek', 'got', {
      'from': weekStart.toIso8601String(),
      'to': weekEnd.toIso8601String(),
      'count': snapshot.docs.length
    });
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // save recipes on the recipes screen so they can be retrieved
  // on the planner screen, this replaces all recipes saved
  Future<void> saveUserRecipes(
      String userId, List<Map<String, dynamic>> recipes) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final collectionRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('AddedRecipes');

      // clear existing recipes first
      final snapshot = await collectionRef.get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // add all recipes
      for (final recipe in recipes) {
        final docRef = collectionRef.doc(); // auto generated id
        batch.set(docRef, recipe);
      }

      await batch.commit();
    } catch (e) {
      testLog(
          'fb_service.saveUserRecipes', 'save failed', {'error': e.toString()});
    }
  }

  // add one recipe to the MealPlan sticky bar
  Future<void> appendUserRecipe(
      String userId, Map<String, dynamic> recipe) async {
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('AddedRecipes');

      await collectionRef.add(recipe); // adds one document
    } catch (e) {
      testLog('fb_service.appendUserRecipe', 'save failed', {'recipe': recipe});
    }
  }

  // remove one recipe to the MealPlan sticky bar
  // uses title as the unique key
  Future<void> removeUserRecipe(
      String userId, Map<String, dynamic> recipe) async {
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('AddedRecipes');

      final query = await collectionRef
          .where('title', isEqualTo: recipe['title'])
          .limit(1)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      testLog(
          'fb_service.removeUserRecipe', 'delete failed', {'recipe': recipe});
    }
  }

  // get user recipes - used on the planner_screen to get saved recipes into
  // the sticky bar
  Future<List<Map<String, dynamic>>> getUserRecipes(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('AddedRecipes')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getAllWasteLogsRaw(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('WasteLogs')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getAllSmartlistDocuments(
      String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('SmartLists')
        .get();

    return snapshot.docs
        .map((doc) => {
              'weekId': doc.id,
              'items':
                  List<Map<String, dynamic>>.from(doc.data()['items'] ?? []),
            })
        .toList();
  }

  // this updates stock with the leftovers from a meal plan
  // if there aren't stock items it creates them, if there
  // are items it overwrites them
  Future<void> updateStockItems(
      String userId, List<Map<String, dynamic>> updatedItems) async {
    final stockRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('StockItems');

    final batch = FirebaseFirestore.instance.batch();

    for (var item in updatedItems) {
      final name = item['name'];
      final docRef = stockRef.doc(name);

      batch.set(docRef, {
        'ingredientId': name,
        'ingredientAmount': item['amount'],
        'unit': item['unit'],
        'type': item['type'],
      });
    }
    await batch.commit();
  }

  // record that the stock has been updated for this smart list
  // this freezes the current smart list
  Future<void> markStockUpdatedInSmartlist({
    required String userId,
    required DateTime weekStart,
  }) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('SmartLists')
        .doc(DateFormat('yyyy-MM-dd').format(weekStart))
        .set({
      'stockUpdated': true,
    }, SetOptions(merge: true));
    testLog('fb_service.markStockUpdatedInSmartlist', 'updated',
        {'week': DateFormat('yyyy-MM-dd').format(weekStart)});
  }
}
