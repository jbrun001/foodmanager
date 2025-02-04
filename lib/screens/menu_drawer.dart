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
            title: Text('Recipe Search'),
            onTap: () => context.go('/recipes'),
          ),
          ListTile(
            title: Text('Meal Planner'),
            onTap: () => context.go('/planner'),
          ),
          ListTile(
            title: Text('Ingredient Stock'),
            onTap: () => context.go('/ingredient'),
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
