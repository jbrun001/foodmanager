import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_drawer.dart';
import '../services/firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/smartlist_service.dart';

class PreviewLeftoversScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  PreviewLeftoversScreen({
    required this.firebaseService,
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
  // R1.LO.02 add recipes to user recipes for use in meal planning screen
  List<Map<String, dynamic>> addedRecipes = [];
  List<Map<String, dynamic>> aggregatedItems = [];
  bool _isLoading = true; // to stop screen displaying before data is there

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
    setState(() => _isLoading = true);
    try {
      await _loadAggregatedSmartlist(); // update and retrieve smartlist
      await _loadCombinedStock(); // get user stock items and merge lefovers from smartlist
      await _loadRecipes(); // get recipes for matching
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAggregatedSmartlist() async {
    final DateTime now = DateTime.now();
    final DateTime weekStart =
        now.subtract(Duration(days: now.weekday % 7)); // current week Sunday

    aggregatedItems = await loadSmartlist(
      firebaseService: widget.firebaseService,
      userId: userId,
      selectedWeekStart: weekStart,
      selectedStore: 'Tesco',
      fetchMealPlanIngredients: () async {
        Map<String, List<Map<String, dynamic>>> mealPlan = await widget
            .firebaseService
            .getMealPlan(userId, weekStart, weekStart.add(Duration(days: 6)));

        return mealPlan.values.expand((meals) {
          return meals.expand((meal) {
            if (meal['ingredients'] is List) {
              return (meal['ingredients'] as List)
                  .whereType<Map<String, dynamic>>();
            }
            return <Map<String, dynamic>>[];
          });
        }).toList();
      },
    );
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
    for (var item in aggregatedItems) {
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
        double required = (ingredient['amount'] is num)
            ? (ingredient['amount'] as num).toDouble()
            : 0.0;
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
      // gets rid of those recipes where less than 59% match
      if (matchScore > 49.0) {
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

  // add one recipe to existing meal plan sticky bar (AddedRecipes)
  void addRecipe(Map<String, dynamic> recipe) {
    if (!addedRecipes.contains(recipe)) {
      setState(() {
        addedRecipes.add(recipe);
      });
      widget.firebaseService.appendUserRecipe(userId, recipe);
    }
  }

  // remove recipe from sticky var
  void removeRecipe(Map<String, dynamic> recipe) {
    setState(() {
      addedRecipes.remove(recipe);
    });
    widget.firebaseService.removeUserRecipe(userId, recipe);
  }

  String getLeftoverSummary() {
    // take each item in aggregated items and if there are
    // missing fields create the fields with default values
    final leftovers = aggregatedItems
        .map((item) {
          return {
            'name': item['name'] ?? '',
            'amount': (item['left_over_amount'] as num?)?.toDouble() ?? 0.0,
            'unit': item['unit'] ?? '',
          };
        })
        .where((item) => item['amount'] > 0) // filter out items with 0 amounts
        .toList();

    leftovers.sort((a, b) => b['amount'].compareTo(a['amount']));

    final formatted = leftovers.map((item) {
      final amount = item['amount'];
      final unit = item['unit'];
      final name = item['name'];
      return '${amount}${unit} $name';
    }).toList();

    return formatted.isEmpty ? 'None' : formatted.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go('/planner', extra: widget.firebaseService);
            },
            icon: Icon(Icons.arrow_forward, color: Colors.black),
            label: Text(
              'Plan',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredients left at end of the week',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            getLeftoverSummary(),
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recipes that you will have all or some of the ingredients to make.",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
                                //final score = recipe['matchScore'] as double;
                                final fraction =
                                    recipe['matchFraction'] as String;
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: recipe['thumbnail'] ??
                                            'https://via.placeholder.com/100',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.white,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.broken_image, size: 100),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recipe['title'] ?? 'Untitled',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                                //                                        "Match: ${score.toStringAsFixed(1)}% ($fraction ingredients)",
                                                "$fraction ingredients",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => addRecipe(recipe),
                                        child: Text('Add'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    color: Colors.white,
                    child: addedRecipes.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: addedRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = addedRecipes[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => removeRecipe(recipe),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: recipe['thumbnail'] ??
                                          'https://via.placeholder.com/100',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.broken_image,
                                              size: 80, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text('No recipes added yet',
                                style: TextStyle(color: Colors.grey))),
                  ),
                ),
              ],
            ),
    );
  }
}
