import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_drawer.dart';
import '../services/firebase_service.dart';
import 'dart:math'; // for randomising test data

class POCFirebaseScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  POCFirebaseScreen({required this.firebaseService});
  @override
  _POCFirebaseScreenState createState() => _POCFirebaseScreenState();
}

class _POCFirebaseScreenState extends State<POCFirebaseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _status = "Press the button to test Firebase";
  String userId = "1"; // Fixed user ID for testing

  // test recipe data
  final List<Map<String, dynamic>> recipes = [
    {
      'title': 'One-Pot Hainanese-Style Chicken & Rice with Pak Choi',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': '',
      'cooktime': 25,
      'preptime': 5,
      'calories': 620,
      'portions': 4,
      'cusine': 'hainanese',
      'category': 'meal',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Long Grain Rice',
          'amount': 130,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Chicken Breast',
          'amount': 2,
          'unit': ''
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Pak Choi',
          'amount': 2,
          'unit': ''
        },
      ],
      'method': [
        {
          'step': 'put the rice in the pot with enough water to cover',
          'image': ''
        },
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Southern Thai-Style Chicken Panang Curry',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': 'Description of recipe.',
      'cooktime': 25,
      'preptime': 5,
      'calories': 1000,
      'portions': 4,
      'cusine': 'thai',
      'category': 'meal',
      'keywords': 'spicy',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Long Grain Rice',
          'amount': 130,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Chicken Thighs',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Thai Red Curry Paste',
          'amount': 40,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Chop the chicken into bite size pieces', 'image': ''},
        {
          'step': 'Add a little oil to a wide based pan, and heat on medium',
          'image': 'https://dummyimage.com/100'
        },
        {'step': 'Add chicken and cook for 3-4 mins until brown', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title':
          'Creole-Style Haddock & Sweet Potato Stew with Garlic Rice extra long title',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description':
          'Longer description taking up more space that previous item and enough words to go onto a second line.',
      'cooktime': 25,
      'preptime': 5,
      'calories': 520,
      'portions': 4,
      'cusine': 'creole',
      'category': 'meal',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Haddock',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Long Grain Rice',
          'amount': 130,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Sweet Potato',
          'amount': 200,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Add the rice to a pot', 'image': ''},
        {
          'step': 'Add cold water to rice',
          'image': 'https://dummyimage.com/100'
        },
        {'step': 'Cook on high until water is boiling', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Rich Mushroom Ragu Linguine (V)',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': 'Description',
      'cooktime': 25,
      'preptime': 5,
      'calories': 520,
      'portions': 4,
      'cusine': 'vegan',
      'category': 'meal',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Flat White Mushrooms',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Linguine',
          'amount': 180,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Chopped Tomato',
          'amount': 200,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Cut mushrooms into thick slices', 'image': ''},
        {
          'step':
              'Add to an oiled wide based pan and fry until starting to brown',
          'image': 'https://dummyimage.com/100'
        },
        {'step': 'Add chopped tomato', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Beef Satay Wraps',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': 'description',
      'cooktime': 25,
      'preptime': 5,
      'calories': 520,
      'portions': 4,
      'cusine': 'hainanese',
      'category': 'indonesian',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Minced Beef',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Soft Tortilla Wraps',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Peanut Butter',
          'amount': 25,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Add minced beef to an oiled wide based pan', 'image': ''},
        {
          'step':
              'cook on medium, breaking up beef until beef starting to brown',
          'image': 'https://dummyimage.com/100'
        },
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
  ];

  // upload test recipes to Firestore
  Future<void> _uploadRecipes() async {
    try {
      CollectionReference recipesCollection = _firestore.collection("recipes");

      for (var recipe in recipes) {
        await recipesCollection.add(recipe);
      }

      setState(() {
        _status = "Recipes uploaded successfully!";
      });
    } catch (e) {
      setState(() {
        _status = "Error uploading recipes: $e";
      });
    }
  }

  // test ingredient and Moq data
  final List<Map<String, dynamic>> ingredients = [
    {
      "name": "Butter",
      "unit": "g",
      "type": "Dairy",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/290920510",
          "amount": 250,
          "units": "g",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    },
    {
      "name": "Yeast",
      "unit": "g",
      "type": "Baking",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/259108442",
          "amount": 56,
          "units": "g",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    },
    {
      "name": "Long Grain Rice",
      "unit": "g",
      "type": "world goods",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/254877356",
          "amount": 1000,
          "units": "g",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    },
    {
      "name": "Chicken Breast",
      "unit": "",
      "type": "meat",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/285210252",
          "amount": 2,
          "units": "g",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    },
    {
      "name": "Pak Choi",
      "unit": "",
      "type": "vegetable",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/252895723",
          "amount": 2,
          "units": "",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    },
    {
      "name": "Chicken Thigh Fillets",
      "unit": "g",
      "type": "meat",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/308469037",
          "amount": 600,
          "units": "",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    },
    {
      "name": "Thai Red Curry Paste",
      "unit": "g",
      "type": "spices & pastes",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/317207605",
          "amount": 180,
          "units": "g",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    },
    {
      "name": "Haddock",
      "unit": "g",
      "type": "fish",
      "Moqs": [
        {
          "storeName": "Tesco",
          "URL": "https://www.tesco.com/groceries/en-GB/products/302286988",
          "amount": 280,
          "units": "g",
          "lastCollected": "2025-01-01T00:00:00.000"
        }
      ]
    }
  ];

  // upload test data ingredients to Firestore with Moqs
  Future<void> _uploadIngredients() async {
    try {
      CollectionReference ingredientsCollection =
          _firestore.collection("Ingredients");

      for (var ingredient in ingredients) {
        await ingredientsCollection.add(ingredient);
      }

      setState(() {
        _status = "Ingredients (with embedded Moqs) uploaded successfully!";
      });
    } catch (e) {
      setState(() {
        _status = "Error uploading ingredients: $e";
      });
    }
  }

  Future<void> _testFirestore() async {
    try {
      // Write test data to Firestore
      await _firestore.collection('test').doc('testDoc').set({
        'message': 'Hello, Firebase!',
        'timestamp': DateTime.now(),
      });

      // Read test data from Firestore
      DocumentSnapshot snapshot =
          await _firestore.collection('test').doc('testDoc').get();

      if (snapshot.exists) {
        setState(() {
          _status = "Data from Firestore: ${snapshot['message']}";
        });
      } else {
        setState(() {
          _status = "No data found!";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
    }
  }

  // function to create User 1 with test data
  Future<void> _createUserWithTestData() async {
    try {
      // check if user already exists
      var userDoc = await widget.firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _status =
              "User 1 already exists in Firestore. No new record created.";
        });
        return;
      }

      // create user with test data
      await widget.firebaseService.createUserPOC(
        userId: userId,
        firebaseId: "firebase_test_id",
        passwordHash: "test_hashed_password",
        preferredPortions: 2,
        preferredStore: "Test Store",
      );

      // add a test meal plan
      await widget.firebaseService.addMealPlan(
        userId: userId,
        mealPlanId: "test_meal_plan_1",
        week: DateTime.now(),
      );

      // add a test meal
      await widget.firebaseService.addMeal(
        userId: userId,
        mealPlanId: "test_meal_plan_1",
        mealId: "test_meal_1",
        recipeId: "test_recipe_1",
        mealDate: DateTime.now(),
        portions: 2,
      );

      // add a test stock item
      await widget.firebaseService.addUserStockItem(
          userId: userId,
          stockItemId: "stock_1",
          ingredientId: "ingr001",
          ingredientAmount: 500.0,
          ingredientUnit: "g",
          ingredientType: "baking");

      // add a test waste log
      await widget.firebaseService.addWasteLog(
        userId: userId,
        wasteId: "waste_1",
        week: DateTime.now(),
        logDate: DateTime.now(),
        amount: 2.0,
        composted: 1.0,
        inedibleParts: 0.5,
      );

      // add a test smartlist
      await widget.firebaseService.addSmartlist(
        userId: userId,
        listId: "smartlist_1",
        storeId: "store_123",
        mealPlanId: "test_meal_plan_1",
        amount: 100.0,
      );

      setState(() {
        _status = "User 1 created successfully with test data!";
      });
    } catch (e) {
      setState(() {
        _status = "Error creating user: $e";
      });
    }
  }

  // generates food waste test data by first removing all existing waste logs
  // for the user and then adding one log per day for the last 6 weeks.
  Future<void> _generateFoodWasteTestData() async {
    setState(() {
      _status = "Generating Food Waste Test Data...";
    });
    // do this for the current userid
    userId = FirebaseService().getCurrentUserId();
    try {
      // Step 1: Delete existing waste logs for the user.
      QuerySnapshot snapshot = await _firestore
          .collection("Users")
          .doc(userId)
          .collection("WasteLogs")
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Step 2: Generate one waste log per day for the last 6 weeks.
      final random = Random();
      DateTime today = DateTime.now();
      DateTime startDate = today.subtract(Duration(days: 6 * 7)); // 42 days

      for (int i = 0; i <= 6 * 7; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));

        // Generate a random time for logDate on the current day.
        int randomHour = random.nextInt(24);
        int randomMinute = random.nextInt(60);
        int randomSecond = random.nextInt(60);
        DateTime logDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          randomHour,
          randomMinute,
          randomSecond,
        );

        // Compute the week date as the most recent Sunday at midnight.
        int daysToSubtract = currentDate.weekday % 7;
        DateTime weekStart = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        ).subtract(Duration(days: daysToSubtract));
        weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day);

        // Generate random waste amounts such that total waste <= 400.
        double totalWaste = random.nextDouble() * 400;
        double composted = random.nextDouble() * totalWaste;
        double inedible = totalWaste - composted;

        // Create a wasteId based on the log date.
        String wasteId =
            "waste_${currentDate.year}${currentDate.month.toString().padLeft(2, '0')}${currentDate.day.toString().padLeft(2, '0')}";

        // Use the firebaseService to add the waste log.
        await widget.firebaseService.addWasteLog(
          userId: userId,
          wasteId: wasteId,
          week: weekStart,
          logDate: logDate,
          amount: totalWaste,
          composted: composted,
          inedibleParts: inedible,
        );
      }
      userId = "1"; // set back to 1 so other buttons work
      setState(() {
        _status = "Food Waste Test Data generated successfully!";
      });
    } catch (e) {
      setState(() {
        _status = "Error generating food waste test data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Test"),
      ),
      drawer: MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testFirestore,
              child: Text("Test Firestore"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadRecipes,
              child: Text("Upload Recipes to Firestore"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createUserWithTestData,
              child: Text("Create a test user with id 1"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadIngredients,
              child: Text("Upload test Ingredients to Firestore"),
            ),
            SizedBox(height: 10),
            // button for generating food waste test data.
            ElevatedButton(
              onPressed: _generateFoodWasteTestData,
              child: Text("Generate Food Waste Test Data for current user"),
            ),
          ],
        ),
      ),
    );
  }
}
