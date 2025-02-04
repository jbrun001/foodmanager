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
            title: Text('Smart List'),
            onTap: () => context.go('/smartlist'),
          ),
          ListTile(
            title: Text('Preview Left Over Ingredients'),
            onTap: () => context.go('/preview_left_over_ingredients'),
          ),
          ListTile(
            title: Text('Ingredient Tracking'),
            onTap: () => context.go('/ingredient_tracking'),
          ),
          ListTile(
            title: Text('Add Ingredients'),
            onTap: () => context.go('/add_ingredients'),
          ),
          ListTile(
            title: Text('Food Waste Log'),
            onTap: () => context.go('/food_waste_log'),
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
