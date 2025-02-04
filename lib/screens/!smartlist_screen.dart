import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_drawer.dart';
import 'package:intl/intl.dart';

class SmartlistScreen extends StatefulWidget {
  @override
  _SmartlistScreenState createState() => _SmartlistScreenState();
}

class _SmartlistScreenState extends State<SmartlistScreen> {
  DateTime selectedDate = DateTime.now();

  void pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  final List<String> _options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  String? _selectedStore;

  @override
  void initState() {
    super.initState();
    _selectedStore = _options[0];
  }





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
                  child: Text(DateFormat('yMMMd').format(selectedDate)),
                ),
                
                DropdownButton<String>(
                  value: _selectedStore,
                  items: _options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStore = newValue; // Update the selected option
                    });
                  },
                ),
              ],
            ),
          ),
          


          
        ],
      ),
    );
  }
}