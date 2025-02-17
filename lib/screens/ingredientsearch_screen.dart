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

  @override
  void initState() {
    super.initState();
    filteredIngredients = ingredients; // Initially show all ingredients
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

  // Add ingredient to the list (from the add ingredient screen)
  void addNewIngredient(Map<String, dynamic> newIngredient) {
    setState(() {
      ingredients.add(newIngredient);
      filteredIngredients = ingredients; // Refresh the search results
    });
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
                                ingredient['amount'] =
                                    int.tryParse(value) ?? ingredient['amount'];
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(ingredient['unit']),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddIngredientScreen(onAddIngredient: addNewIngredient),
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

  AddIngredientScreen({required this.onAddIngredient});

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
    filteredIngredients = availableIngredients;
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
                    title: Text('${ingredient['name']}'),
                    subtitle: Text('Type: ${ingredient['type']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Adjustable Size for Amount TextField
                        SizedBox(
                          width: 60, // Adjust width of the text box
                          height: 40, // Optional: Adjust height of the text box
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                vertical:
                                    8, // Adjust vertical padding inside the text box
                                horizontal:
                                    4, // Adjust horizontal padding inside the text box
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            controller: TextEditingController(
                              text: ingredient['amount'].toString(),
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                ingredient['amount'] =
                                    int.tryParse(value) ?? ingredient['amount'];
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8), // Spacing between amount and unit
                        // Fixed Width for Units
                        SizedBox(
                          width: 40, // Fixed width for units
                          child: Text(
                            ingredient['unit'],
                            textAlign: TextAlign.left, // Align text to the left
                          ),
                        ),
                      ],
                    ),
                    onTap: () =>
                        addToStickyArea(ingredient), // Add to sticky area
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
