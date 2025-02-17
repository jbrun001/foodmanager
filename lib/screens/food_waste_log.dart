import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_drawer.dart';
import '../services/firebase_service.dart';

class FoodWasteLogScreen extends StatelessWidget {
  final FirebaseService firebaseService;
  FoodWasteLogScreen({required this.firebaseService});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Waste Log')),
      drawer: MenuDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/planner'); // Navigate back to the planner screen
          },
          child: Text('Back to Planner'),
        ),
      ),
    );
  }
}
