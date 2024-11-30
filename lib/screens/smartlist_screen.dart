import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_drawer.dart';

class SmartlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smartlist')),
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
