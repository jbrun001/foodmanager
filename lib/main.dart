import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/smartlist_screen.dart';
import 'screens/ingredientsearch_screen.dart';
import 'screens/previewleftovers_screen.dart';
import 'screens/food_waste_log.dart';
import 'screens/pocfirebase_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

// Define the GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/', // Start at the login screen
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/planner',
      builder: (context, state) => PlannerScreen(),
    ),
    GoRoute(
      path: '/recipes',
      builder: (context, state) => RecipesScreen(),
    ),
    GoRoute(
      path: '/smartlist',
      builder: (context, state) => SmartlistScreen(),
    ),
    GoRoute(
      path: '/ingredient',
      builder: (context, state) => IngredientSearchScreen(),
    ),
    GoRoute(
      path: '/smartlist',
      builder: (context, state) => SmartlistScreen(),
    ),
    GoRoute(
      path: '/preview',
      builder: (context, state) => PreviewleftoversScreen(),
    ),
    GoRoute(
      path: '/waste',
      builder: (context, state) => FoodWasteLogScreen(),
    ),
    GoRoute(
      path: '/firebase',
      builder: (context, state) => POCFirebaseScreen(),
    ),
  ],
);
