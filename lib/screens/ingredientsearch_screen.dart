import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect

class IngredientSearchScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  IngredientSearchScreen({required this.firebaseService});
  @override
  _IngredientSearchScreenState createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  // holds the current userId
  String userId = '';
  Map<String, TextEditingController> stockAmountControllers = {};
  // Ingredients in stock
  List<Map<String, dynamic>> ingredients = [];

  // Filtered list of ingredients for search
  List<Map<String, dynamic>> filteredIngredients = [];
  TextEditingController searchController = TextEditingController();
  // sticky bar on add screen so multiple ingredients can be added at once
  List<Map<String, dynamic>> selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    // get the current userId and redirect to login if no current user
    userId = FirebaseService().getCurrentUserId();
    if (userId == '') {
      print("No user logged in. Redirecting to login page...");
      context.go('/');
    }

    // fetch data after UI built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchStockItems();
    });
  }

  void fetchStockItems() async {
    List<Map<String, dynamic>> stockItems =
        await widget.firebaseService.getStockItems(userId);

    stockItems.sort((a, b) {
      final amountA = a['amount'] ?? 0;
      final amountB = b['amount'] ?? 0;
      return (amountA as num).compareTo(amountB as num);
    });

    setState(() {
      ingredients = stockItems;
      filteredIngredients = List.from(stockItems);

      // set up controllers for each ingredientamount
      for (var ing in stockItems) {
        final id = ing['name'];
        final amount = ing['amount'] ?? 0;

        if (!stockAmountControllers.containsKey(id)) {
          stockAmountControllers[id] =
              TextEditingController(text: amount.toString());
        } else {
          stockAmountControllers[id]!.text = amount.toString();
        }
      }
    });
  }

  void filterIngredients(String query) {
    List<Map<String, dynamic>> results;

    if (query.isEmpty) {
      results = List.from(ingredients);
    } else {
      results = ingredients.where((ingredient) {
        final nameMatch = (ingredient['name'] ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());
        final typeMatch = (ingredient['type'] ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());
        return nameMatch || typeMatch;
      }).toList();
    }

    // Debug output
    print('Filtering ingredients with query: $query');
    for (var ing in ingredients) {
      print('${ing['name']} - amount: ${ing['amount']}, type: ${ing['type']}');
    }

    // Sort by amount, default to 0 if null
    results.sort((a, b) {
      final amountA = a['amount'] ?? 0;
      final amountB = b['amount'] ?? 0;
      return (amountA as num).compareTo(amountB as num);
    });

    print('Filtered results:');
    for (var ing in results) {
      print('${ing['name']} - amount: ${ing['amount']}');
    }

    setState(() {
      filteredIngredients = results;
    });
  }

  // called on exit of the amnount field
  // updates firebase with new amount.
  void _updateIngredientAmount(
      Map<String, dynamic> ingredient, int newAmount) async {
    setState(() {
      ingredient['amount'] = newAmount;
    });
    // String userId = '1'; // for testing only
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
    print("Attempting to add ingredient: $newIngredient");
    final exists =
        ingredients.any((item) => item['name'] == newIngredient['name']);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${newIngredient['name']} is already in stock.'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    try {
      await widget.firebaseService.addUserStockItem(
        userId: userId,
        stockItemId: newIngredient['name'],
        ingredientId: newIngredient['name'],
        ingredientAmount: newIngredient['amount'].toDouble(),
        ingredientUnit: newIngredient['unit'],
        ingredientType: newIngredient['type'],
      );
      print("Added new ingredient: $newIngredient");
      fetchStockItems(); // refresh list
    } catch (e) {
      print("Error adding ingredient: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items in Stock'),
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
                labelText: 'Search ingredient or type (i.e. world foods)',
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
                final id = (ingredient['name'] ?? '').toString();
                final amount = ingredient['amount'] ?? 0;

                // Initialize controller once
                if (!stockAmountControllers.containsKey(id)) {
                  stockAmountControllers[id] =
                      TextEditingController(text: amount.toString());
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(id), // using ingredientId as display name
                    subtitle: Text(
                        'Type: ${ingredient['type']} - Unit: ${ingredient['unit']}'),
                    trailing: SizedBox(
                      width: 60,
                      child: TextField(
                        controller: stockAmountControllers[id],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        onSubmitted: (value) {
                          final newAmount = int.tryParse(value) ?? amount;
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
  List<Map<String, dynamic>> availableIngredients = [];
  Map<String, TextEditingController> amountControllers = {};
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
        filteredIngredients = List.from(availableIngredients);
      } else {
        filteredIngredients = availableIngredients.where((ingredient) {
          final nameMatch =
              ingredient['name'].toLowerCase().contains(query.toLowerCase());
          final typeMatch =
              ingredient['type'].toLowerCase().contains(query.toLowerCase());
          return nameMatch || typeMatch;
        }).toList();

        // Safely sort by amount (default to 0 if missing)
        filteredIngredients.sort((a, b) {
          final amountA = a['amount'] ?? 0;
          final amountB = b['amount'] ?? 0;
          return (amountA as num).compareTo(amountB as num);
        });
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
    bool hasError = false; // check for zero or duplicates
    for (var ingredient in selectedIngredients) {
      final name = ingredient['name'];
      final controller = amountControllers[name];
      final parsed = int.tryParse(controller?.text ?? '') ?? 0;

      if (parsed <= 0) {
        hasError = true;
        print('Invalid amount for ${ingredient['name']}: $parsed');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Amount must be greater than 0 for "${ingredient['name']}"'),
          duration: Duration(seconds: 2),
        ));
        break;
      }
      ingredient['amount'] = parsed ?? 0;
      widget.onAddIngredient(ingredient);
    }
    if (!hasError) {
      Navigator.pop(context);
    }
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
                labelText: 'Search ingredient or type (i.e. meat)',
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
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient['name'] ?? 'Unnamed',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('Type: ${ingredient['type'] ?? 'Unknown'}'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            addToStickyArea(ingredient);
                          },
                          child: Text('Add'),
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
            color: Colors.white,
            child: selectedIngredients.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = selectedIngredients[index];
                      final name = ingredient['name'];

                      // Ensure a controller exists for this ingredient
                      if (!amountControllers.containsKey(name)) {
                        amountControllers[name] = TextEditingController(
                          text: ingredient['amount']?.toString() ?? '',
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              height: 30,
                              child: TextField(
                                controller: amountControllers[name],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'amt',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                ),
                                onChanged: (value) {
                                  ingredient['amount'] =
                                      int.tryParse(value) ?? 0;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No ingredients added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitSelectedIngredients, // Submit and return
        child: Icon(Icons.check),
      ),
    );
  }
}
