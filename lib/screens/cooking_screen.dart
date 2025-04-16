import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // for date formatting
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect

class CookingScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  CookingScreen({required this.firebaseService});

  @override
  _CookingScreenState createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  DateTime selectedWeekStart = DateTime.now();
  Map<String, List<Map<String, dynamic>>> plan = {};
  String userId = '';
  Set<String> cookedRecipeIds = Set();

  @override
  void initState() {
    super.initState();
    userId = FirebaseService().getCurrentUserId();
    if (userId == '') context.go('/');
    initialisePlanner();
  }

  void initialisePlanner() {
    final offset = selectedWeekStart.weekday % 7;
    selectedWeekStart = selectedWeekStart.subtract(Duration(days: offset));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPlannerData();
    });
  }

  void pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedWeekStart,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final offset = picked.weekday % 7;
      setState(() {
        selectedWeekStart = picked.subtract(Duration(days: offset));
        fetchPlannerData();
      });
    }
  }

  void fetchPlannerData() async {
    DateTime endDate = selectedWeekStart.add(Duration(days: 6));
    final fetched = await widget.firebaseService
        .getMealPlan(userId, selectedWeekStart, endDate);
    Map<String, List<Map<String, dynamic>>> fullWeek = {};
    for (int i = 0; i < 7; i++) {
      final day =
          DateFormat('EEEE').format(selectedWeekStart.add(Duration(days: i)));
      fullWeek[day] = fetched[day] ?? [];
    }
    setState(() {
      plan = fullWeek;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDays =
        List.generate(7, (i) => selectedWeekStart.add(Duration(days: i)));
    return Scaffold(
      appBar: AppBar(title: Text('Cook')),
      drawer: MenuDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () => pickStartDate(context),
              child: Text(DateFormat('yMMMd').format(selectedWeekStart)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = DateFormat('EEEE').format(weekDays[index]);
                final dateStr = DateFormat('yMMMd').format(weekDays[index]);
                final recipes = plan[day] ?? [];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('$day, $dateStr',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...recipes.map((recipe) => ListTile(
                              leading: CachedNetworkImage(
                                imageUrl: recipe['thumbnail'] ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              title: Text(recipe['title']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: cookedRecipeIds
                                        .contains(recipe['title']),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          cookedRecipeIds.add(recipe['title']);
                                        } else {
                                          cookedRecipeIds
                                              .remove(recipe['title']);
                                        }
                                      });
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
/*                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RecipeDetailScreen(
                                              recipe: recipe),
                                        ),
                                      );*/
                                    },
                                    child: Text("View"),
                                  ),
                                ],
                              ),
                            )),
                        if (recipes.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: Text('No recipes planned')),
                          ),
                      ],
                    ),
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
