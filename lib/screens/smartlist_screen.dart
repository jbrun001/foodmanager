import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

class SmartlistScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  SmartlistScreen({required this.firebaseService});

  @override
  _SmartlistScreenState createState() => _SmartlistScreenState();
}

class _SmartlistScreenState extends State<SmartlistScreen> {
  DateTime selectedWeekStart =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .subtract(Duration(days: DateTime.now().weekday % 7));
  // set the user to user "1" for testing - replace with auth code later
  String userId = "1";

  String? _selectedStore;
  List<Map<String, dynamic>> _smartlistItems = [];

  // testing - just use tesco - add read from \Stores collection later
  final List<String> _stores = ['Tesco'];

  @override
  void initState() {
    super.initState();
    _selectedStore = _stores[0];
    _loadSmartlist();
  }

  void pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedWeekStart,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedWeekStart) {
      // adjust picked date to the closest Sunday - subtract the mod 7 days
      final int offsetToSunday = picked.weekday % 7; // 0 for Sun, 1 for Mon
      setState(() {
        // trigger user interface re-build with the new data
        selectedWeekStart = DateTime(
          picked.year,
          picked.month,
          picked.day, // reset time to midnight, by not including time
        ).subtract(Duration(days: offsetToSunday));
        _loadSmartlist();
      });
    }
  }

  // fetches data from firebase
  // updated to calculate required ingredients from the mealplan
  Future<void> _loadSmartlist() async {
    // list of all the ingredients for the mealplan in the selected week
    List<Map<String, dynamic>> mealPlanIngredients =
        await _fetchMealPlanIngredients();
    // list of all the items entered manually in the smart list
    List<Map<String, dynamic>> manualItems =
        await widget.firebaseService.getSmartlist(userId, selectedWeekStart);
    // List of all the ingredients this user has
    List<Map<String, dynamic>> stockItems =
        await widget.firebaseService.getStockItems(userId); // Fetch stock items

    // list of unique ingredients and their total amounts based on
    // meal plan ingredients and existing smartlist items
    Map<String, Map<String, dynamic>> aggregatedItems = {};

    // convert stock items into a map with ingredient name and amount
    // Convert stock list into a lookup map (ingredient name -> amount)
    Map<String, double> userStock = {};
    for (var stockItem in stockItems) {
      userStock[stockItem['name']] = (stockItem['amount'] as num).toDouble();
    }

    // for every ingredient in the meal plan add it to agregatedItems
    // if it exists already then increase the amount
    for (var ingredient in mealPlanIngredients) {
      // check that there is an ingredient name
      String name = ingredient['ingredient_name'] ?? 'Unknown Ingredient';
      // check units are strings
      String unit = ingredient['unit'] ?? 'unit';
      double amount = (ingredient['amount'] as num).toDouble();
      // check there is a type - if not then create a type of general
      String type = ingredient.containsKey('type') && ingredient['type'] != null
          ? ingredient['type']
          : 'General';

      if (aggregatedItems.containsKey(name)) {
        aggregatedItems[name]!['amount'] += amount;
      } else {
        aggregatedItems[name] = {
          'name': name,
          'amount': amount,
          'unit': unit,
          'type': type,
          'purchased': false,
          'isManual': false, // items from meal plan
          'stock': userStock[name] ?? 0.0, // get the amount from StockItems
          'needed': 0.0, // place to store how much is needed to be purchased
        };
      }
    }

    // add manually entered items and merge duplicates
    for (var item in manualItems) {
      String name = item['name'] ?? 'Unknown Item';
      String unit = item['unit'] ?? 'unit';
      double amount = (item['amount'] as num).toDouble();
      String type = item.containsKey('type') && item['type'] != null
          ? item['type']
          : 'General';

      if (aggregatedItems.containsKey(name)) {
        aggregatedItems[name]!['amount'] += amount;
      } else {
        aggregatedItems[name] = {
          'name': name,
          'amount': amount,
          'unit': unit,
          'type': type,
          'purchased': item['purchased'] ?? false,
          'isManual': true, // manually added items
          'stock': userStock[name] ?? 0.0, // get the amount from StockItems
          'needed': 0.0, // place to store how much is needed to be purchased
        };
      }
    }

    // go through smartlist and calculate needed amounts
    aggregatedItems.forEach((key, value) {
      double required = value['amount'];
      double stock = value['stock'];
      value['needed'] = required > stock ? required - stock : 0.0;
      // if the item is requred by the meal plan and is not needed to
      // purchase because it's already in stock then mark as already
      // purchased
      if (value['needed'] == 0.0 && value['amount'] > 0.0) {
        value['purchased'] = true;
      }
    });

    setState(() {
      _smartlistItems = aggregatedItems.values.toList();
    });
  }

  // get all of the meal plan ingredients for the selected week
  // into a list for processing
  Future<List<Map<String, dynamic>>> _fetchMealPlanIngredients() async {
    Map<String, List<Map<String, dynamic>>> mealPlan =
        await widget.firebaseService.getMealPlan(userId, selectedWeekStart,
            selectedWeekStart.add(Duration(days: 6)));
//debug
    print("Fetched Meal Plan: $mealPlan");
    List<Map<String, dynamic>> ingredientsList = [];

    for (var meals in mealPlan.values) {
      for (var meal in meals) {
        // make ingredient exists and is a list
        if (meal.containsKey('ingredients') && meal['ingredients'] is List) {
          // make sure the data is
          List<dynamic> rawIngredients = meal['ingredients'];
          List<Map<String, dynamic>> mealIngredients = rawIngredients
              .where((ingredient) => ingredient is Map<String, dynamic>)
              .map((ingredient) => ingredient as Map<String, dynamic>)
              .toList();

          ingredientsList.addAll(mealIngredients);
        }
      }
    }
//debug
    print("Extracted Ingredients: $ingredientsList");
    return ingredientsList;
  }

  void _togglePurchased(String name, bool currentStatus) {
    widget.firebaseService
        .updateSmartlistItem(userId, name, selectedWeekStart, !currentStatus);
    setState(() {
      _smartlistItems = _smartlistItems.map((item) {
        if (item['name'] == name) {
          item['purchased'] = !currentStatus;
        }
        return item;
      }).toList();
    });
  }

  void _addItem() {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _amountController = TextEditingController();
    TextEditingController _unitController = TextEditingController();
    TextEditingController _typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Item Name"),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(labelText: "Unit"),
              ),
              TextField(
                controller: _typeController,
                decoration:
                    InputDecoration(labelText: "Type (e.g., Dairy, Meat)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Add"),
              // when the button is pressed the database must be
              // updated before the UI is re-built so the new
              // data displays. using async / await so this works
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty &&
                    _unitController.text.isNotEmpty &&
                    _typeController.text.isNotEmpty) {
                  await widget.firebaseService.addSmartlistItem(
                    userId: userId,
                    name: _nameController.text,
                    amount: int.tryParse(_amountController.text) ?? 1,
                    unit: _unitController.text,
                    type: _typeController.text,
                    date: selectedWeekStart,
                  );

                  await _loadSmartlist();
                  // this only happens when the data has been saved AND
                  // the new data is loaded
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smartlist')),
      drawer: MenuDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => pickStartDate(context),
                  child: Text(DateFormat('yMMMd').format(selectedWeekStart)),
                ),
                DropdownButton<String>(
                  value: _selectedStore,
                  items: _stores.map((String store) {
                    return DropdownMenuItem<String>(
                        value: store, child: Text(store));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStore = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _smartlistItems.isEmpty
                ? Center(child: Text("No items in the smartlist"))
                : ListView.builder(
                    itemCount: _smartlistItems.length,
                    itemBuilder: (context, index) {
                      final item = _smartlistItems[index];
                      return Dismissible(
                        key: Key(item['name']),
                        background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (direction) {
                          widget.firebaseService.deleteSmartlistItem(
                              userId, item['name'], selectedWeekStart);
                          setState(() {
                            _smartlistItems.removeAt(index);
                          });
                        },
                        child: ListTile(
                          leading: Checkbox(
                            value: item['purchased'],
                            onChanged: (bool? value) => _togglePurchased(
                                item['name'], item['purchased']),
                          ),
                          title: Text(
                            // output all the data from the aggregated list
                            // for testing
                            "${item['name']} (Plan: ${item['amount']} ${item['unit']})\n"
                            "Stock: ${item['stock']} ${item['unit']} | Needed: ${item['needed']} ${item['unit']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: item['purchased']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            "Category: ${item['type']}",
                            style: TextStyle(
                              decoration: item['purchased']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
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
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
