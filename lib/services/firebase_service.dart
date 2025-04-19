import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for authentication
import 'package:google_sign_in/google_sign_in.dart'; // for oauth2 authentication
import 'package:intl/intl.dart'; // for date formatting

// this services file contains the class for all database activity
class FirebaseService {
  // firebase database object
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // firebase authentication object
  final FirebaseAuth auth = FirebaseAuth.instance;

  // create a new user document in Firestore
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
          'ingredientsOriginal':
              List<Map<String, dynamic>>.from(data['ingredients']),
          'plannedPortions': data['plannedPortions'] ?? data['portions'] ?? 1,
          'portions': data['portions'] ?? 1,
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
      print(
          'smartlist found for ${DateFormat('yyyy-MM-dd').format(weekStart)} with ${items.length} items');
      return items;
    } else {
      print(
          'Smartlist not found for weekId: ${DateFormat('yyyy-MM-dd').format(weekStart)}');
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
        print('User signed up: ${user.uid}');
        await createUserSignUp(user.uid, email, portions, store);
      }
      return user;
    } catch (e) {
      print('Error signing up: $e');
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
      print('User logged in: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled');
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
        print('User signed in with Google: ${user.uid}');
        await createUserSignUp(
            user.uid, user.email ?? '', 2, "Tesco"); // Default values
      }
      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
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
        print('Creating new user in Firestore: $userId');
        await userDoc.set({
          'email': email,
          'preferredPortions': portions,
          'preferredStore': store,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        print('User already exists in Firestore: $userId');
      }
    } catch (e) {
      print('Error creating user in Firestore: $e');
    }
  }

  // function to get the currently logged in userId
  // returns the userId or returns '' if not logged in.
  String getCurrentUserId() {
    User? user = auth.currentUser; // get the current user
    if (user != null) {
      print('Current User ID: ${user.uid}');
      return user.uid;
    } else {
      print('No user is currently logged in.');
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
      print('Error fetching user details: $e');
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
      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // fetches the list of store names from the "Stores" collection.
  // If no store is found, it creates one with the name "Tesco" and returns it
  Future<List<String>> getStores() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('Stores').get();
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
      print("Error fetching stores: $e");
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
    // testing
    print(
        'getWasteLogsForWeek: ${weekStart.toIso8601String()} to ${weekEnd.toIso8601String()}');
    print('  logs returned: ${snapshot.docs.length}');
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
      print('Error saving user recipes: $e');
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
      print('Error appending recipe: $e');
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
      print('Error removing recipe: $e');
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
    print(
        "Marking stock updated for week: ${DateFormat('yyyy-MM-dd').format(weekStart)}");
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('SmartLists')
        .doc(DateFormat('yyyy-MM-dd').format(weekStart))
        .set({
      'stockUpdated': true,
    }, SetOptions(merge: true));
  }
}
