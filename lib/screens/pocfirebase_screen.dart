import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_drawer.dart';
import '../services/firebase_service.dart';

class POCFirebaseScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  POCFirebaseScreen({required this.firebaseService});
  @override
  _POCFirebaseScreenState createState() => _POCFirebaseScreenState();
}

class _POCFirebaseScreenState extends State<POCFirebaseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _status = "Press the button to test Firebase";

  // test recipe data
  final List<Map<String, dynamic>> recipes = [
    {
      'title': 'One-Pot Hainanese-Style Chicken & Rice with Pak Choi',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
          'image': 'https://via.placeholder.com/100'
        },
        {'step': 'Add chicken and cook for 3-4 mins until brown', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title':
          'Creole-Style Haddock & Sweet Potato Stew with Garlic Rice extra long title',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
          'image': 'https://via.placeholder.com/100'
        },
        {'step': 'Cook on high until water is boiling', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Rich Mushroom Ragu Linguine (V)',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
          'image': 'https://via.placeholder.com/100'
        },
        {'step': 'Add chopped tomato', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Beef Satay Wraps',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/100',
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
          'image': 'https://via.placeholder.com/100'
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
          ],
        ),
      ),
    );
  }
}
