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
            child: Text('POC Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: Text('Recipes POC Design'),
            onTap: () => context.go('/recipes'),
          ),
          ListTile(
            title: Text('Meal Planner POC Drag and Drop'),
            onTap: () => context.go('/planner'),
          ),
          ListTile(
            title: Text('POC data send'),
            onTap: () => context.go('/datasend'),
          ),
          ListTile(
            title: Text('POC JSON API'),
            onTap: () => context.go('/jsonapi'),
          ),
          ListTile(
            title: Text('POC firebase'),
            onTap: () => context.go('/firebase'),
          ),
          ListTile(
            title: Text('Smartlist'),
            onTap: () => context.go('/smartlist'),
          ),
        ],
      ),
    );
  }
}
