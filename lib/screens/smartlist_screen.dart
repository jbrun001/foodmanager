import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect
import '../services/smartlist_service.dart'; // contains loadSmartlist
import '../services/testing_service.dart'; // test logging

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
  String userId = ''; // used to hold the current user

  String? _selectedStore;
  List<String> _stores = []; // stored list of available stores
  List<Map<String, dynamic>> _smartlistItems = [];
  bool _isLoading = true; // to indicate when the smart list has loaded

  @override
  void initState() {
    super.initState();
    userId = FirebaseService().getCurrentUserId();
    if (userId == '') {
      print("No user logged in. Redirecting to login page...");
      context.go('/');
    }
    _loadStores(); // load stores from \Stores collection
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

  // fetches stores from Stores collections and selects first one
  Future<void> _loadStores() async {
    List<String> stores = await widget.firebaseService.getStores();
    setState(() {
      _stores = stores;
      _selectedStore = stores.isNotEmpty ? stores.first : null;
    });
  }

  Future<void> _loadSmartlist() async {
    setState(() => _isLoading = true);

    _smartlistItems = await loadSmartlist(
      firebaseService: widget.firebaseService,
      userId: userId,
      selectedWeekStart: selectedWeekStart,
      selectedStore: _selectedStore,
      fetchMealPlanIngredients: _fetchMealPlanIngredients,
    );

    setState(() => _isLoading = false);
  }

  // R1.SL.01
  // list sorting, purchased items last
  // within purchased/unpurchased sort by ingredient type
  // becuase when shopping these items will be near each other
  int _smartlistSort(Map<String, dynamic> a, Map<String, dynamic> b) {
    // put ticked (purchased items) last
    if (a['purchased'] != b['purchased']) {
      return a['purchased'] ? 1 : -1;
    }
    // force string to lowercase before sorting
    return a['type']
        .toString()
        .toLowerCase()
        .compareTo(b['type'].toString().toLowerCase());
  }

  // get all of the meal plan ingredients for the selected week
  // into a list for processing
  Future<List<Map<String, dynamic>>> _fetchMealPlanIngredients() async {
    Map<String, List<Map<String, dynamic>>> mealPlan =
        await widget.firebaseService.getMealPlan(userId, selectedWeekStart,
            selectedWeekStart.add(Duration(days: 6)));

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
    testLog('smartlist._fetchMealPlanIngredients', 'result',
        {'ingredientsList': ingredientsList});
    return ingredientsList;
  }

  void _togglePurchased(String name, bool currentStatus) async {
    setState(() {
      for (var item in _smartlistItems) {
        if (item['name'] == name && item['isManual'] == true) {
          item['purchased'] = !currentStatus;
        }
      }
      // update: to sort list R1.SL.01
      _smartlistItems.sort(_smartlistSort);
    });

    // Save full smartlist for tracking and analytics
    await widget.firebaseService.saveSmartlistForWeek(
      userId: userId,
      weekStart: selectedWeekStart,
      items: _smartlistItems,
    );
  }

  // input to allow a user to add an item to the smart list manually
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
                    // Add the manual item into _smartlistItems directly
                    setState(() {
                      _smartlistItems.add({
                        'name': _nameController.text,
                        'amount':
                            double.tryParse(_amountController.text) ?? 1.0,
                        'unit': _unitController.text,
                        'type': _typeController.text,
                        'purchased': false,
                        'isManual': true,
                        'stock': 0.0,
                        'needed': 0.0,
                        'moq': 0.0,
                        'purchase_amount': 0.0,
                        'left_over_amount': 0.0,
                      });
                      _smartlistItems.sort(_smartlistSort);
                    });

                    // Save full smartlist (including manual item)
                    await widget.firebaseService.saveSmartlistForWeek(
                      userId: userId,
                      weekStart: selectedWeekStart,
                      items: _smartlistItems,
                    );

                    Navigator.pop(context);
                  }
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
      ),
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
                  child:
                      Text('${DateFormat('yMMMd').format(selectedWeekStart)}'),
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
                      _loadSmartlist(); // reload smartlist for new store
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // loading indicator if _isLoading
                : _smartlistItems.isEmpty // else if smartlist is empty
                    ? Center(
                        child: Text(
                            "There are no items in this week's Smart List.\nPut some recipes in the meal plan for this week\nand then the smartlist will\nautomatically calculate how much of each\ningredent you need to buy"))
                    : ListView.builder(
                        // else display list
                        itemCount: _smartlistItems.length,
                        itemBuilder: (context, index) {
                          final item = _smartlistItems[index];

                          final listTile = ListTile(
                            leading: Checkbox(
                              value: item['purchased'],
                              onChanged: (bool? value) {
                                setState(() {
                                  item['purchased'] = value ?? false;
                                  _smartlistItems.sort(_smartlistSort);
                                });

                                // Only persist purchased status for manual items
                                if (item['isManual'] == true) {
                                  final manualItems = _smartlistItems
                                      .where((i) => i['isManual'] == true)
                                      .toList();

                                  widget.firebaseService.saveSmartlistForWeek(
                                    userId: userId,
                                    weekStart: selectedWeekStart,
                                    items: manualItems,
                                  );
                                }
                              },
                            ),
                            title: Text(
                              "${item['purchase_amount']}${item['unit']} ${item['name']}",
                              // "Plan amount: ${item['amount']}${item['unit']} | Stock: ${item['stock']}${item['unit']} | Needed: ${item['needed']}${item['unit']} | "
                              // "MOQ: ${item['moq']}${item['unit']} | stock after cooking: ${item['stock']}${item['unit']} already in stock ${item['left_over_amount']}${item['unit']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: item['purchased'] == true
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              "Category: ${item['type']}",
                              style: TextStyle(
                                decoration: item['purchased'] == true
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          );

                          if (item['isManual'] == true) {
                            return Dismissible(
                              key: Key(item['name']),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) async {
                                setState(() {
                                  _smartlistItems.removeAt(index);
                                });

                                await widget.firebaseService
                                    .saveSmartlistForWeek(
                                  userId: userId,
                                  weekStart: selectedWeekStart,
                                  items: _smartlistItems,
                                );
                              },
                              child: listTile,
                            );
                          } else {
                            return listTile; // no dismiss swipe
                          }
                        }),
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
