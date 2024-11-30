import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_drawer.dart';

class PlannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Planner')),
      drawer: MenuDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/recipes'); // Navigate to the recipes screen
          },
          child: Text('Go to Recipes'),
        ),
      ),
    );
  }
}
