import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/smartlist_screen.dart';
import 'screens/profile_screen.dart';

void main() {
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
      path: '/profile/:id', // Route with a parameter
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProfileScreen(
            id: id); // pass `id` to the ProfileScreen as a test
      },
    ),
  ],
);
