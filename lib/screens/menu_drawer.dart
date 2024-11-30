import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            title: Text('Meal Planner'),
            onTap: () => context.go('/planner'),
          ),
          ListTile(
            title: Text('Recipes'),
            onTap: () => context.go('/recipes'),
          ),
          ListTile(
            title: Text('Smartlist'),
            onTap: () => context.go('/smartlist'),
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }
}
