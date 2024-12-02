import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_drawer.dart';

class PocfirebaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('POC firebase')),
      drawer: MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Proof of concept.  show a connection can be made to firebase and data can be read and saved',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // button to navigate away from screen
            ElevatedButton(
              onPressed: () {
                // navigate to the planner screen
                context.go('/planner');
              },
              child: Text('Meal Planner'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
