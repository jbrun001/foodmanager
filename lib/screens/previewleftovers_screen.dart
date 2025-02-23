import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_drawer.dart';
import '../services/firebase_service.dart';

class PreviewLeftoversScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final List<Map<String, dynamic>> aggregatedItems;

  PreviewLeftoversScreen({
    required this.firebaseService,
    required this.aggregatedItems,
  });

  @override
  _PreviewLeftoversScreenState createState() => _PreviewLeftoversScreenState();
}

class _PreviewLeftoversScreenState extends State<PreviewLeftoversScreen> {
  String userId = '';
  // Combined available amounts from stock plus leftovers.
  Map<String, double> combinedStock = {};
  // List of recipes augmented with a match score and match fraction.
  List<Map<String, dynamic>> scoredRecipes = [];

  @override
  void initState() {
    super.initState();
    userId = widget.firebaseService.getCurrentUserId();
    if (userId == '') {
      print("No user logged in. Redirecting to login page...");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return;
    }
    _initData();
  }

  Future<void> _initData() async {
    await _loadCombinedStock();
    await _loadRecipes();
  }

  Future<void> _loadCombinedStock() async {
    // Fetch stock items for the user.
    List<Map<String, dynamic>> stockItems =
        await widget.firebaseService.getStockItems(userId);
    // Build a lookup map: ingredient name -> amount.
    for (var item in stockItems) {
      combinedStock[item['name']] = (item['amount'] as num).toDouble();
    }
    // Merge in leftover amounts from aggregatedItems.
    for (var item in widget.aggregatedItems) {
      String name = item['name'];
      double leftover = (item['left_over_amount'] as num).toDouble();
      combinedStock[name] = (combinedStock[name] ?? 0) + leftover;
    }
    setState(() {});
  }

  Future<void> _loadRecipes() async {
    // Fetch recipes from Firebase (assumes getRecipes() exists).
    List<Map<String, dynamic>> recipes =
        await widget.firebaseService.getRecipes();

    List<Map<String, dynamic>> calculatedRecipes = [];

    // For each recipe, calculate how many ingredients are fully available.
    for (var recipe in recipes) {
      List<dynamic> ingredients = recipe['ingredients'];
      int totalIngredients = ingredients.length;
      int fullyMatchedCount = 0;
      for (var ingredient in ingredients) {
        String name = ingredient['ingredient_name'] ?? '';
        double required = (ingredient['amount'] as num).toDouble();
        double available = combinedStock[name] ?? 0.0;
        if (available >= required) {
          fullyMatchedCount++;
        }
      }
      double matchScore = totalIngredients > 0
          ? (fullyMatchedCount / totalIngredients) * 100
          : 0;
      // Save both the percentage score and the fraction string.
      recipe['matchScore'] = matchScore;
      recipe['matchFraction'] = "$fullyMatchedCount/$totalIngredients";
      // only add to the list if some ingredients match
      // gets rid of those recipes where nothing matches
      if (matchScore > 0.0) {
        calculatedRecipes.add(recipe);
      }
    }

    // Sort recipes descending by matchScore.
    calculatedRecipes.sort((a, b) =>
        (b['matchScore'] as double).compareTo(a['matchScore'] as double));

    // Take the top 20 recipes.
    setState(() {
      scoredRecipes = calculatedRecipes.take(20).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Leftovers'),
      ),
      drawer: MenuDrawer(),
      body: Column(
        children: [
          // Optionally display combined stock information.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Recipes matching stock after cooking",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: scoredRecipes.isEmpty
                ? Center(
                    child: Text(
                      "No recipes available with current leftovers and stock.",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: scoredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = scoredRecipes[index];
                      final score = recipe['matchScore'] as double;
                      final fraction = recipe['matchFraction'] as String;
                      return ListTile(
                        title: Text(recipe['title'] ?? 'Untitled Recipe'),
                        subtitle: Text(
                          "Match Score: ${score.toStringAsFixed(1)}% ($fraction)",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
