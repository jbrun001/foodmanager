import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for authentication

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: Text('Recipe Select'),
            onTap: () => context.go('/recipes'),
          ),
          ListTile(
            title: Text('Meal Planner'),
            onTap: () => context.go('/planner'),
          ),
          ListTile(
            title: Text('Preview leftovers'),
            onTap: () => context.go('/preview'),
          ),
          ListTile(
            title: Text('Smart Shopping List'),
            onTap: () => context.go('/smartlist'),
          ),
          ListTile(
            title: Text('Items in Stock'),
            onTap: () => context.go('/ingredient'),
          ),
          ListTile(
            title: Text('Waste Efficiency'),
            onTap: () => context.go('/analysis'),
          ),
          ListTile(
            title: Text('Log Food Waste'),
            onTap: () => context.go('/waste'),
          ),
          ListTile(
            title: Text('User Profile'),
            onTap: () => context.go('/profile'),
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              context.go('/'); // redirect to login screen
            },
          ),
/*
          ListTile(
            title: Text('POC firebase'),
            onTap: () => context.go('/firebase'),
          ),
*/
          ListTile(
            title: Text(
              'Version 1.2.2',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.grey),
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
