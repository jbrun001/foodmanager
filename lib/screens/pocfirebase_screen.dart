import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_drawer.dart';

class POCFirebaseScreen extends StatefulWidget {
  @override
  _POCFirebaseScreenState createState() => _POCFirebaseScreenState();
}

class _POCFirebaseScreenState extends State<POCFirebaseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _status = "Press the button to test Firebase";

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
          ],
        ),
      ),
    );
  }
}
