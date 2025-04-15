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

  // live recipes
  final List<Map<String, dynamic>> recipes = [
    {
      "title": "Sweet 'N' Smoky BBQ Chicken Fajitas",
      "thumbnail":
          "https://production-media.gousto.co.uk/cms/mood-image/1115-Smoky-Chicken-Fajitas-With-Red-Pepper-x400.jpg",
      "image":
          "https://production-media.gousto.co.uk/cms/mood-image/1115-Smoky-Chicken-Fajitas-With-Red-Pepper-x400.jpg",
      "description": "",
      "cooktime": 20,
      "preptime": 5,
      "calories": 628,
      "portions": 4,
      "cusine": "Mexican-American",
      "category": "Main Course",
      "keywords": "BBQ, Smokey, Chicken, Fajitas, Quick Dinner",
      "ingredients": [
        {
          "ingredient_id": 1,
          "ingredient_name": "Chicken Breast Strips",
          "amount": 500,
          "unit": "g"
        },
        {
          "ingredient_id": 13,
          "ingredient_name": "Cheddar Cheese",
          "amount": 80,
          "unit": "g"
        },
        {
          "ingredient_id": 28,
          "ingredient_name": "Cherry Tomatoes",
          "amount": 250,
          "unit": "g"
        },
        {
          "ingredient_id": 6,
          "ingredient_name": "Chilli Flakes",
          "amount": 1,
          "unit": "tsp"
        },
        {
          "ingredient_id": 7,
          "ingredient_name": "Garlic Clove",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 8,
          "ingredient_name": "Coriander",
          "amount": 2,
          "unit": "tsp"
        },
        {
          "ingredient_id": 9,
          "ingredient_name": "Cumin",
          "amount": 2,
          "unit": "tsp"
        },
        {
          "ingredient_id": 10,
          "ingredient_name": "Smoked Paprika",
          "amount": 4,
          "unit": "tsp"
        },
        {
          "ingredient_id": 11,
          "ingredient_name": "Yogurt",
          "amount": 160,
          "unit": "g"
        },
        {
          "ingredient_id": 12,
          "ingredient_name": "Tortillas",
          "amount": 12,
          "unit": "pcs"
        },
        {
          "ingredient_id": 13,
          "ingredient_name": "Red Onion",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 14,
          "ingredient_name": "Red Pepper",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 15,
          "ingredient_name": "Spring Onions",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 16,
          "ingredient_name": "Sugar",
          "amount": 2,
          "unit": "tsp"
        }
      ],
      "method": [
        {
          "step":
              "Before you start cooking, take your chicken out of the fridge open the packet and let it air",
          "image": ""
        },
        {"step": "Deseed your pepper(s) and cut into thin strips", "image": ""},
        {"step": "peel and finely slice your Red Onion(s)", "image": ""},
        {
          "step":
              "Heat a large wide based pan with a generous drizzle of olive oil over high heat",
          "image": ""
        },
        {
          "step":
              "once hot, add the pepper strips, sliced onion and chicken breast strips to the pan and cook for 10-12 min or until the vegetables have softend and the chicken is cooked through",
          "image": ""
        },
        {
          "step":
              "While everything is cooking chop your cherry tomatoes roughly then keep chopping them together until they resemble a salsa like consistency",
          "image": ""
        },
        {
          "step":
              "Add the chopped tomatoes to a bowl with your chilli flakes. A pinch of salt and a drizzle of olive oil",
          "image": ""
        },
        {"step": "Stir it all together, this is your salsa", "image": ""},
        {"step": "peal and grate your garlic", "image": ""},
        {
          "step":
              "Combine your smoked paprika, corriander and cumin in a bowl with your sugar.  This is your BBQ spice mix",
          "image": ""
        },
        {
          "step":
              "Once the chicken is cooked through, add the BBQ spice mix and the grated garlic to the pan and cook out for 2-3 min or untill fragrant. This is your sweet 'n' smokey BBQ chicken fajita filling",
          "image": ""
        },
        {
          "step":
              "Add your tortillas to a plate and pop them in the microwave for 20 secs or until warmed through",
          "image": ""
        },
        {"step": "Grate your chedder cheese", "image": ""},
        {"step": "Trim then slice your spring onion(s) finely", "image": ""},
        {
          "step":
              "Serve the sweet 'n' smokey BBQ chicken fajita filling over the tortilas ",
          "image": ""
        },
        {"step": "Top with the greated cheddar and salsa", "image": ""},
        {
          "step":
              "Dollop over your natural yoghurt, garnish with the sliced spring onion and enjoy.",
          "image": ""
        }
      ],
      "additional_ingredients": ["Olive Oil", "Salt"]
    },
    {
      "title": "Fiery Jerk-Spiced Pork & Potato Mash",
      "thumbnail":
          "https://www.bbc.co.uk/food/recipes/jerk_pork_with_sweet_40784",
      "image": "https://www.bbc.co.uk/food/recipes/jerk_pork_with_sweet_40784",
      "description": "",
      "cooktime": 20,
      "preptime": 0,
      "calories": 650,
      "portions": 4,
      "cusine": "Caribbean",
      "category": "Main Course",
      "keywords": "Jerk, Spicy, Pork, Caribbean, Mashed potatoes",
      "ingredients": [
        {
          "ingredient_id": 17,
          "ingredient_name": "Pork Loin Steak",
          "amount": 600,
          "unit": "g"
        },
        {
          "ingredient_id": 18,
          "ingredient_name": "Carrot & Cabbage Slaw Mix",
          "amount": 320,
          "unit": "g"
        },
        {
          "ingredient_id": 19,
          "ingredient_name": "Chicken Stock Mix",
          "amount": 11,
          "unit": "g"
        },
        {
          "ingredient_id": 20,
          "ingredient_name": "Jerk Paste",
          "amount": 48,
          "unit": "g"
        },
        {
          "ingredient_id": 21,
          "ingredient_name": "Mayonnaise",
          "amount": 60,
          "unit": "ml"
        },
        {
          "ingredient_id": 22,
          "ingredient_name": "Sweet Potatoes",
          "amount": 4,
          "unit": "pcs"
        },
        {
          "ingredient_id": 23,
          "ingredient_name": "White Wine Vinegar",
          "amount": 30,
          "unit": "ml"
        },
        {
          "ingredient_id": 24,
          "ingredient_name": "Flour",
          "amount": 4,
          "unit": "tsp"
        },
        {
          "ingredient_id": 25,
          "ingredient_name": "Boiled Water",
          "amount": 250,
          "unit": "ml"
        }
      ],
      "method": [
        {
          "step":
              "Before you start cooking, take your pork steak out of the fridge, open the packet and let it adjust to room temperture, then boil a kettle",
          "image": ""
        },
        {
          "step": "Peel and chop your sweet potato(es) into bite size pieces",
          "image": ""
        },
        {
          "step":
              "Add the chopped sweet potato to a pot of boiled water over a high heat and bring to the boil",
          "image": ""
        },
        {"step": "Cook for 10-12 min or until fork tender", "image": ""},
        {
          "step":
              "Add your pork loin steak(s) to a bowl with hald your jerk paste, half your white wine vinegar and half your flour",
          "image": ""
        },
        {
          "step":
              "Add a pinch of salt and pepper and give everything a good mix up. This is your jerk spiced pork",
          "image": ""
        },
        {
          "step":
              "Heat a large, wide based pan over a high heat wuth a small drizzle of vegetable oil",
          "image": ""
        },
        {
          "step":
              "Once hot, add the jerk spiced pork and cook for 5-6 min on each side or until slightly charred and cooked through",
          "image": ""
        },
        {
          "step":
              "While the pork is cooking reboil half a kettle combine your carrot & cabbage slaw mix with your mayo and the remaining white wine vinegar",
          "image": ""
        },
        {
          "step":
              "Add a pinch of salt and pepper and give everything a good mix up. This is your slaw",
          "image": ""
        },
        {
          "step":
              "Dissolve your chicken stock mix in your boiled water with the remaining jerk paste, a pinch of sugar and a generous pinch of salt and papper. This is your jerk spiced stock",
          "image": ""
        },
        {
          "step": "Once the potatoes are tender, drain, return them to the pot",
          "image": ""
        },
        {
          "step":
              "Add a knob of butter and a pinch of salt to the potatoes and mash them until smooth. This is your sweet potato mash",
          "image": ""
        },
        {"step": "Cover with a lid to keep warm until serving", "image": ""},
        {
          "step":
              "Once the pork is done, transfer the cooked steak to a clean chopping board (reserve the pan) and leave to rest for 2 min",
          "image": ""
        },
        {
          "step":
              "Return the reserved pan to medium heat with the remaining flour and stir for 30 secs",
          "image": ""
        },
        {
          "step":
              "Gradually stir the jerk spiced stock and cook for 2 min until a smooth, thick sauce remains.  This is your jerk spiced sauce",
          "image": ""
        },
        {
          "step":
              "(Scrape any bits from the bottom of the pan as it will add flavour to the sauce)",
          "image": ""
        },
        {"step": "Slice the rested pork", "image": ""},
        {
          "step":
              "Serve the sliced pork with the sweet potato mash and slaw to the side",
          "image": ""
        },
        {
          "step": "Drizzle the jerk spiced sauce over the sliced pork",
          "image": ""
        },
        {"step": "Enjoy", "image": ""}
      ],
      "additional_ingredients": [
        "Pepper",
        "Salt",
        "Sugar",
        "Vegetable Oil",
        "Butter"
      ]
    },
    {
      "title": "Korean Style Chicken Thigh Tacos with Sesame Slaw",
      "thumbnail":
          "https://production-media.gousto.co.uk/cms/mood-image/5369_Korean-Chicken-Thigh-Tacos-with-Sesame-Slaw_001_0-1684414549217-1685433459981-x700.jpg",
      "image":
          "https://production-media.gousto.co.uk/cms/mood-image/5369_Korean-Chicken-Thigh-Tacos-with-Sesame-Slaw_001_0-1684414549217-1685433459981-x700.jpg",
      "description": "",
      "cooktime": 25,
      "preptime": 5,
      "calories": 710,
      "portions": 4,
      "cusine": "Korean Fusion",
      "category": "Main Course",
      "keywords": "Korean, Tacos, Chicken, Fusion, Sesame, Slaw",
      "ingredients": [
        {
          "ingredient_id": 26,
          "ingredient_name": "Diced Chicken Thigh",
          "amount": 500,
          "unit": "g"
        },
        {
          "ingredient_id": 27,
          "ingredient_name": "Carrot",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 19,
          "ingredient_name": "Chicken Stock Mix",
          "amount": 11,
          "unit": "g"
        },
        {
          "ingredient_id": 28,
          "ingredient_name": "Gochujang Paste",
          "amount": 60,
          "unit": "g"
        },
        {
          "ingredient_id": 29,
          "ingredient_name": "Paprika",
          "amount": 2,
          "unit": "tsp"
        },
        {
          "ingredient_id": 21,
          "ingredient_name": "Mayonnaise",
          "amount": 60,
          "unit": "ml"
        },
        {
          "ingredient_id": 12,
          "ingredient_name": "Tortillas",
          "amount": 12,
          "unit": "pcs"
        },
        {
          "ingredient_id": 30,
          "ingredient_name": "Rice Vinegar",
          "amount": 30,
          "unit": "ml"
        },
        {
          "ingredient_id": 31,
          "ingredient_name": "Shredded Red Cabbage",
          "amount": 300,
          "unit": "g"
        },
        {
          "ingredient_id": 15,
          "ingredient_name": "Spring Onion",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 32,
          "ingredient_name": "Toasted Sesame Oil",
          "amount": 20,
          "unit": "ml"
        },
        {
          "ingredient_id": 33,
          "ingredient_name": "Toasted Sesame Seeds",
          "amount": 5,
          "unit": "g"
        },
        {
          "ingredient_id": 41,
          "ingredient_name": "Warm Water",
          "amount": 100,
          "unit": "ml"
        },
        {
          "ingredient_id": 16,
          "ingredient_name": "Sugar",
          "amount": 2,
          "unit": "tsp"
        }
      ],
      "method": [
        {
          "step":
              "Take your chicken out of the fridge, open the packet and let it air",
          "image": ""
        },
        {
          "step":
              "trim then slice your spring onion(s) finely, keeping the whites and greens seperate",
          "image": ""
        },
        {"step": "Top, tail, peel and grate your carrot(s)", "image": ""},
        {
          "step":
              "Heat a large, wide based pan with a drizzle of vegetable oil over a high heat",
          "image": ""
        },
        {
          "step":
              "once hot add your diced chicken thigh and cook for 4-5 min or until lightly browned all over",
          "image": ""
        },
        {
          "step":
              "Dissolve your gochujang paste and chicken stock mix in your warm water",
          "image": ""
        },
        {
          "step":
              "Add your sugar, your paprika, half your rice vinegar and a pinch of salt",
          "image": ""
        },
        {
          "step": "Give everything a mix up this is your gochujang stock",
          "image": ""
        },
        {
          "step":
              "Once the chicken is lightly browned, reduce the heat to a medium high heat and add the gochujang stock",
          "image": ""
        },
        {
          "step":
              "Stir it all together and cook, stirring occasionallly for 6-8 min or until the sauce has thickend and the chicken is cooked through. This is your Korean Style Glazed Chicken",
          "image": ""
        },
        {
          "step":
              "Wile the chicken is cooking, combine your shredded red cabbage grated carrot and spring onion whites in a large bowl this is your slaw mix",
          "image": ""
        },
        {
          "step":
              "Add your mayo, remaining rice vinegar, tosted sesame oil and a generous pint of pepper to the slaw mix",
          "image": ""
        },
        {"step": "Mix untill combined. This is your sesame slaw", "image": ""},
        {
          "step":
              "When the chicken is nearly cooked, add your totillas to a place and pop them in the microwave for 20 secs on high or until warmed though",
          "image": ""
        },
        {
          "step":
              "Load up the warmed tortillas with the sesame slaw and korean style glazed chicken",
          "image": ""
        },
        {
          "step":
              "Drizzle over any remaining glaxe and top with the sliced spring onion greens and toasted sesame seeds",
          "image": ""
        }
      ],
      "additional_ingredients": ["Pepper", "Salt", "Vegetable oil"]
    },
    {
      "title": "Vietmanese-Style Fable Mushroom Rice Bowl",
      "thumbnail": "https://dummyimage.com/100",
      "image": "https://dummyimage.com/200",
      "description": "",
      "cooktime": 20,
      "preptime": 5,
      "calories": 582,
      "portions": 4,
      "cusine": "Vietnamese",
      "category": "Main Course",
      "keywords": "Vietnamese, Mushroom, Rice Bowl, Plant-Based, Vegan, Fable",
      "ingredients": [
        {
          "ingredient_id": 34,
          "ingredient_name": "Pulled Mushrooms",
          "amount": 360,
          "unit": "g"
        },
        {
          "ingredient_id": 27,
          "ingredient_name": "Carrot",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 7,
          "ingredient_name": "Garlic Clove",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 35,
          "ingredient_name": "Gem Lettuce",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 36,
          "ingredient_name": "Lime",
          "amount": 2,
          "unit": "pcs"
        },
        {
          "ingredient_id": 37,
          "ingredient_name": "Red Chilli",
          "amount": 1,
          "unit": "pcs"
        },
        {
          "ingredient_id": 38,
          "ingredient_name": "Roasted Peanuts",
          "amount": 50,
          "unit": "g"
        },
        {
          "ingredient_id": 39,
          "ingredient_name": "Soy Sauce",
          "amount": 60,
          "unit": "ml"
        },
        {
          "ingredient_id": 40,
          "ingredient_name": "White Basmati Rice",
          "amount": 260,
          "unit": "g"
        },
        {
          "ingredient_id": 42,
          "ingredient_name": "Cold Water",
          "amount": 600,
          "unit": "ml"
        },
        {
          "ingredient_id": 16,
          "ingredient_name": "Sugar",
          "amount": 6,
          "unit": "tsp"
        }
      ],
      "method": [
        {
          "step":
              "Add your Basmati Rice and your cold water with a pinch of salt to a pot with a lit and bring to the boil over a high heat",
          "image": ""
        },
        {
          "step":
              "Once boiling reduce the heat to very low and cook, covered for 10-12 min or until all the water has been absorbed and the rice is cooked",
          "image": ""
        },
        {
          "step":
              "Once cooked remove from the hear and keep covered untill serving",
          "image": ""
        },
        {
          "step": "Top, tail, peel and chop your carrot(s) into matchsticks",
          "image": ""
        },
        {
          "step":
              "Wash your lettuce then pat it dry with kitchen paper and shred finely",
          "image": ""
        },
        {
          "step":
              "Slice half your red chilli(es) into rounds and finely chop the rest ",
          "image": ""
        },
        {
          "step": "(If you dont want alot of spice remove the seeds)",
          "image": ""
        },
        {"step": "Peel and finely chop (or grate) your garlic", "image": ""},
        {
          "step":
              "Bash your pulled mushrooms with a rolling pin to break them up",
          "image": ""
        },
        {
          "step":
              "heat a large wide based pan with a generous drizzle of vegetable oil over a medium high heat",
          "image": ""
        },
        {
          "step":
              "once hot add the bashed pulled mushrooms with a generous pint of salt and cook for 5-6 min or until browned breaking them up with a wooden spoon as you go. These are your pulled mushrooms",
          "image": ""
        },
        {
          "step": "While the mushrooms are cooking zest half your lime(s)",
          "image": ""
        },
        {"step": "Chop the lime(s) in half", "image": ""},
        {"step": "Crush your peanuts with a rolling pin", "image": ""},
        {
          "step":
              "Add the finely chopped chilli to a bowl with the juice of the chopped lime(s), half your soy sauce, half the chopped garlic, your sugar and your 6 tbsp of cold water",
          "image": ""
        },
        {
          "step":
              "Give everything a good mix up this is you Vietnamese style dressing",
          "image": ""
        },
        {
          "step":
              "Once the pulled fable mushrooms have browned add the remaining soy sauce, remaining chopped garlic and lime zest to the pan",
          "image": ""
        },
        {
          "step":
              "Stir it all together and cook for a final 1 min or until fragrent. This is your Vietnamese style dressing, garnish with the reserved chilli rounds and crushed peanuts. Enjoy",
          "image": ""
        }
      ],
      "additional_ingredients": ["Salt", "Pepper", "Vegetable oil"]
    }
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
        recycled: 0.5,
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

    userId = FirebaseService().getCurrentUserId();
    try {
      // selete existing waste logs for the user.
      QuerySnapshot snapshot = await _firestore
          .collection("Users")
          .doc(userId)
          .collection("WasteLogs")
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // add one log per Sunday for the last 6 weeks.
      final random = Random();
      DateTime today = DateTime.now();

      for (int i = 0; i < 6; i++) {
        DateTime sunday =
            today.subtract(Duration(days: today.weekday % 7 + (i * 7)));

        // set time part to 00:00:00
        DateTime logDate = DateTime(sunday.year, sunday.month, sunday.day);
        DateTime weekStart = logDate;

        // generate waste values
        double totalWaste = 100 + random.nextDouble() * 150;
        double composted = totalWaste * (random.nextDouble() * 0.6);
        double inedible = totalWaste * (random.nextDouble() * 0.3);

        // create a unique id based on the date.
        String wasteId =
            "waste_${logDate.year}${logDate.month.toString().padLeft(2, '0')}${logDate.day.toString().padLeft(2, '0')}";

        await widget.firebaseService.addWasteLog(
          userId: userId,
          wasteId: wasteId,
          week: weekStart,
          logDate: logDate,
          amount: double.parse(totalWaste.toStringAsFixed(1)),
          recycled: double.parse((totalWaste - composted).toStringAsFixed(1)),
          composted: double.parse(composted.toStringAsFixed(1)),
          inedibleParts: double.parse(inedible.toStringAsFixed(1)),
        );
      }

      userId = "1"; // reset for UI test case compatibility
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
