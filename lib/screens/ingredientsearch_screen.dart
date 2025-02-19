import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import '../services/firebase_service.dart';

class IngredientSearchScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  IngredientSearchScreen({required this.firebaseService});
  @override
  _IngredientSearchScreenState createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  // Ingredients in stock
  List<Map<String, dynamic>> ingredients = [
    {'name': 'Flour', 'amount': 500, 'unit': 'g', 'type': 'Baking'},
    {'name': 'Sugar', 'amount': 300, 'unit': 'g', 'type': 'Baking'},
    {'name': 'Milk', 'amount': 1, 'unit': 'L', 'type': 'Dairy'},
    {'name': 'Eggs', 'amount': 6, 'unit': '', 'type': 'Protein'},
  ];

  // Filtered list of ingredients for search
  List<Map<String, dynamic>> filteredIngredients = [];
  TextEditingController searchController = TextEditingController();
  // sticky bar on add screen so multiple ingredients can be added at once
  List<Map<String, dynamic>> selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    // fetch data after UI built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchStockItems();
    });
  }

  void fetchStockItems() async {
    String userId = '1'; // For testing
    List<Map<String, dynamic>> stockItems =
        await widget.firebaseService.getStockItems(userId);

// debug
    print("Fetched stock items from firebase: $stockItems");

    setState(() {
      ingredients = stockItems;
      filteredIngredients = ingredients;
    });
  }

  void filterIngredients(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredIngredients = ingredients;
      } else {
        filteredIngredients = ingredients
            .where((ingredient) =>
                ingredient['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // called on exit of the amnount field
  // updates firebase with new amount.
  void _updateIngredientAmount(
      Map<String, dynamic> ingredient, int newAmount) async {
    setState(() {
      ingredient['amount'] = newAmount;
    });
    String userId = '1'; // for testing only
    try {
      await widget.firebaseService.addUserStockItem(
        userId: userId,
        stockItemId: ingredient['name'],
        ingredientId: ingredient['name'],
        ingredientAmount: newAmount.toDouble(),
        ingredientUnit: ingredient['unit'],
        ingredientType: ingredient['type'],
      );
      print("Updated ingredient in Firebase: ${ingredient['name']}");
    } catch (e) {
      print("Failed to update ingredient: $e");
    }
  }

  // add ingredients to sticky area
  void addToStickyArea(Map<String, dynamic> ingredient) {
    setState(() {
      if (!selectedIngredients
          .any((item) => item['name'] == ingredient['name'])) {
        selectedIngredients
            .add({...ingredient, 'amount': ingredient['amount'] ?? 0});
      }
    });
  }

  // update ingredient amount in sticky area
  void updateStickyAmount(int index, String value) {
    setState(() {
      selectedIngredients[index]['amount'] =
          int.tryParse(value) ?? selectedIngredients[index]['amount'];
    });
  }

  // clear all ingredients from sticky area
  void clearStickyArea() {
    setState(() {
      selectedIngredients.clear();
    });
  }

  // add ingredient to the list (from the add ingredient screen)
  void addNewIngredient(Map<String, dynamic> newIngredient) async {
    String userId = '1';
//debug
    print("Attempting to add ingredient: $newIngredient");

    bool exists =
        ingredients.any((item) => item['name'] == newIngredient['name']);
    // only add if the ingredient isn't already there
    if (!exists) {
      try {
        await widget.firebaseService.addUserStockItem(
            userId: userId,
            stockItemId: newIngredient['name'],
            ingredientId: newIngredient['name'],
            ingredientAmount: newIngredient['amount'].toDouble(),
            ingredientUnit: newIngredient['unit'],
            ingredientType: newIngredient['type']);
        //debug
        print("Attempting to add ingredient: $newIngredient");
        fetchStockItems(); // refresh UI
      } catch (e) {
        print("Error adding ingredient: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingredient Search'),
      ),
      drawer: MenuDrawer(), // menu icon in top bar
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Ingredients',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterIngredients,
            ),
          ),
          // Scrollable List of Ingredients

          Expanded(
            child: ListView.builder(
              itemCount: filteredIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = filteredIngredients[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(ingredient['name']),
                    subtitle: Text(
                        'Type: ${ingredient['type']} - Unit: ${ingredient['unit']}'),
                    trailing: SizedBox(
                      width: 60,
                      child: TextFormField(
                        // Use initialValue instead of a controller.
                        initialValue: ingredient['amount'].toString(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (value) {
                          int newAmount =
                              int.tryParse(value) ?? ingredient['amount'];
                          _updateIngredientAmount(ingredient, newAmount);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddIngredientScreen(
                  onAddIngredient: addNewIngredient,
                  firebaseService: widget.firebaseService),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Add Ingredient Screen
class AddIngredientScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddIngredient;
  final FirebaseService firebaseService;

  AddIngredientScreen(
      {required this.onAddIngredient, required this.firebaseService});

  @override
  _AddIngredientScreenState createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  // Mock data for ingredients not in stock
  List<Map<String, dynamic>> availableIngredients = [
    {'name': 'Butter', 'unit': 'g', 'type': 'Dairy'},
    {'name': 'Yeast', 'unit': 'g', 'type': 'Baking'},
    {'name': 'Salt', 'unit': 'g', 'type': 'Spices'},
    {'name': 'Vanilla Extract', 'unit': 'ml', 'type': 'Baking'},
  ];

  List<Map<String, dynamic>> filteredIngredients = [];
  List<Map<String, dynamic>> selectedIngredients =
      []; // Sticky area ingredients
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchIngredients(); // fetch ingredients from database
    filteredIngredients = availableIngredients;
  }

  void fetchIngredients() async {
    availableIngredients = await widget.firebaseService.getIngredients();
    setState(() {
      filteredIngredients = availableIngredients;
    });
  }

  void filterIngredients(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredIngredients = availableIngredients;
      } else {
        filteredIngredients = availableIngredients
            .where((ingredient) =>
                ingredient['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void addToStickyArea(Map<String, dynamic> ingredient) {
    setState(() {
      if (!selectedIngredients.contains(ingredient)) {
        selectedIngredients.add({...ingredient, 'amount': 0});
      }
    });
  }

  void submitSelectedIngredients() {
    for (var ingredient in selectedIngredients) {
      print("Calling onAddIngredient for: $ingredient");
      widget.onAddIngredient(ingredient);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Ingredients'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Ingredients',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterIngredients,
            ),
          ),
          // Scrollable List of Ingredients
          Expanded(
            child: ListView.builder(
              itemCount: filteredIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = filteredIngredients[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(ingredient['name']),
                    subtitle: Text('Type: ${ingredient['type']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            controller: TextEditingController(
                              text: ingredient['amount'].toString(),
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                filteredIngredients[index]['amount'] =
                                    int.tryParse(value) ?? ingredient['amount'];
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(ingredient['unit']),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            addToStickyArea(ingredient);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Sticky Area
          Container(
            height: 100,
            color: Colors.grey[200],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = selectedIngredients[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(ingredient['name']),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Amount',
                            ),
                            keyboardType: TextInputType.number,
                            onSubmitted: (value) {
                              setState(() {
                                ingredient['amount'] = int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitSelectedIngredients, // Submit and return
        child: Icon(Icons.check),
      ),
    );
  }
}
