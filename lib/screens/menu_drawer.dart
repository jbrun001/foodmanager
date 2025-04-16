import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for authentication'

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
            title: Text('Recipe Search'),
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
            title: Text('Cooking helper'),
            onTap: () => context.go('/cooking'),
          ),
          ListTile(
            title: Text('Ingredient Stock'),
            onTap: () => context.go('/ingredient'),
          ),
          ListTile(
            title: Text('Smart Shopping List'),
            onTap: () => context.go('/smartlist'),
          ),
//          ListTile(
//            title: Text('Preview Left Over Ingredients'),
//            onTap: () => context.go('/preview'),
//          ),
          ListTile(
            title: Text('Food Waste Log'),
            onTap: () => context.go('/waste'),
          ),
          ListTile(
            title: Text('Waste Efficiency'),
            onTap: () => context.go('/analysis'),
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
          ListTile(
            title: Text('POC firebase'),
            onTap: () => context.go('/firebase'),
          ),
//          ListTile(
//            title: Text('POC JSON API'),
//            onTap: () => context.go('/jsonapi'),
//          ),
//          ListTile(
//            title: Text('POC firebase'),
//            onTap: () => context.go('/firebase'),
//          ),
//          ListTile(
//            title: Text('Smartlist'),
//            onTap: () => context.go('/smartlist'),
//          ),
        ],
      ),
    );
  }
}
