import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/smartlist_screen.dart';
import 'screens/ingredientsearch_screen.dart';
import 'screens/previewleftovers_screen.dart';
import 'screens/pocfirebase_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/waste_log_screen.dart';
import 'screens/wasteloganalysis_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // needed to support cross platform
import 'services/firebase_service.dart'; // all the database interaction
import 'screens/cooking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // create database object for use in the app
  final FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Food Manager',
      routerConfig: _router(firebaseService),
    );
  }
}

// Define the GoRouter
GoRouter _router(FirebaseService firebaseService) {
  return GoRouter(
    initialLocation: '/', // Start at the login screen
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            LoginScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/planner',
        builder: (context, state) =>
            PlannerScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/recipes',
        builder: (context, state) =>
            RecipesScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) =>
            PreviewLeftoversScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/smartlist',
        builder: (context, state) =>
            SmartlistScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/ingredient',
        builder: (context, state) =>
            IngredientSearchScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/smartlist',
        builder: (context, state) =>
            SmartlistScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/cooking',
        builder: (context, state) =>
            CookingScreen(firebaseService: FirebaseService()),
      ),
      GoRoute(
        path: '/waste',
        builder: (context, state) =>
            WasteLogScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) =>
            WasteLogAnalysisScreen(firebaseService: firebaseService),
      ),
      GoRoute(
        path: '/firebase',
        builder: (context, state) =>
            POCFirebaseScreen(firebaseService: firebaseService),
      ),
      GoRoute(
          path: '/signup',
          builder: (context, state) =>
              SignupScreen(firebaseService: firebaseService)),
      GoRoute(
          path: '/profile',
          builder: (context, state) =>
              UserProfileScreen(firebaseService: firebaseService)),
    ],
  );
}
