import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // if you use go_router
import '../services/firebase_service.dart';

class WasteLogScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const WasteLogScreen({Key? key, required this.firebaseService})
      : super(key: key);

  @override
  _WasteLogScreenState createState() => _WasteLogScreenState();
}

class _WasteLogScreenState extends State<WasteLogScreen> {
  // weekStart is the previous Sunday
  DateTime _weekStart =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .subtract(Duration(days: DateTime.now().weekday % 7));

  // fields used on the screen
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _totalWasteController = TextEditingController();
  double _compostedPercentage = 0.0; // 0% - 100%
  double _inediblePercentage = 0.0; // 0% - 100%

  @override
  void dispose() {
    _totalWasteController.dispose();
    super.dispose();
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final int offsetToSunday = picked.weekday % 7; // 0 for Sun, 1 for Mon
      setState(() {
        _selectedDate = picked;
        _weekStart = picked.subtract(Duration(days: offsetToSunday));
      });
    }
  }

  // saves the waste log using firebaseService.
  Future<void> _saveWasteLog() async {
    final userId = widget.firebaseService.getCurrentUserId();
    if (userId.isEmpty) {
      // if user is not logged in, redirect to login
      context.go('/');
      return;
    }

    final wasteAmount = double.tryParse(_totalWasteController.text);
    if (wasteAmount == null || wasteAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid waste amount.')),
      );
      return;
    }

    // calculate composted and inedible amounts in grams
    final compostedAmount = wasteAmount * (_compostedPercentage / 100.0);
    final inedibleAmount = wasteAmount * (_inediblePercentage / 100.0);

    // generate a unique ID for the waste log (e.g. timestamp)
    final wasteId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await widget.firebaseService.addWasteLog(
        userId: userId,
        wasteId: wasteId,
        week: _weekStart, // start of the week for grouping
        logDate: _selectedDate, // actual log date
        amount: wasteAmount,
        composted: compostedAmount,
        inedibleParts: inedibleAmount,
      );

      // Clear inputs
      setState(() {
        _totalWasteController.clear();
        _compostedPercentage = 0.0;
        _inediblePercentage = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waste log added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding waste log: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Food Waste'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Row
            Row(
              children: [
                Text(
                  'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // total waste input
            TextField(
              controller: _totalWasteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Waste (in grams)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // composted slider
            Text(
              'Composted: ${_compostedPercentage.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: _compostedPercentage,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_compostedPercentage.toStringAsFixed(0)}%',
              onChanged: (value) {
                setState(() {
                  _compostedPercentage = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // inedible parts slider
            Text(
              'Inedible Parts: ${_inediblePercentage.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: _inediblePercentage,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_inediblePercentage.toStringAsFixed(0)}%',
              onChanged: (value) {
                setState(() {
                  _inediblePercentage = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _saveWasteLog,
              child: const Text('Log Waste'),
            ),
          ],
        ),
      ),
    );
  }
}
