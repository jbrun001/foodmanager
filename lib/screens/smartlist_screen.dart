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

  final List<String> _stores = ['Store A', 'Store B', 'Store C'];

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

  Future<void> _loadSmartlist() async {
    List<Map<String, dynamic>> items =
        await widget.firebaseService.getSmartlist(userId, selectedWeekStart);
    setState(() {
      _smartlistItems = items;
    });
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
                            "${item['name']} (${item['amount']} ${item['unit']})",
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
