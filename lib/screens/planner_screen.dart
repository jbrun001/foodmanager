import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // for date formatting
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect

// use template of recipe_screen as that is a stateful widget

class PlannerScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  PlannerScreen({required this.firebaseService});

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  // holds the current userId
  String userId = '';

  // test data based on work in recipes_screen
  // this data should be replaced by data passed from the recipes_screen
  final List<Map<String, dynamic>> addedRecipes = [
    {
      'title': 'One-Pot Hainanese-Style Chicken & Rice with Pak Choi',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': '',
      'cooktime': 25,
      'preptime': 5,
      'calories': 620,
      'portions': 4,
      'cusine': 'hainanese',
      'category': 'meal',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Long Grain Rice',
          'amount': 130,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Chicken Breast',
          'amount': 2,
          'unit': ''
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Pak Choi',
          'amount': 2,
          'unit': ''
        },
      ],
      'method': [
        {
          'step': 'put the rice in the pot with enough water to cover',
          'image': ''
        },
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Southern Thai-Style Chicken Panang Curry',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': 'Description of recipe.',
      'cooktime': 25,
      'preptime': 5,
      'calories': 1000,
      'portions': 4,
      'cusine': 'thai',
      'category': 'meal',
      'keywords': 'spicy',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Long Grain Rice',
          'amount': 130,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Chicken Thighs',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Thai Red Curry Paste',
          'amount': 40,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Chop the chicken into bite size pieces', 'image': ''},
        {
          'step': 'Add a little oil to a wide based pan, and heat on medium',
          'image': 'https://dummyimage.com/100'
        },
        {'step': 'Add chicken and cook for 3-4 mins until brown', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title':
          'Creole-Style Haddock & Sweet Potato Stew with Garlic Rice extra long title',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description':
          'Longer description taking up more space that previous item and enough words to go onto a second line.',
      'cooktime': 25,
      'preptime': 5,
      'calories': 520,
      'portions': 4,
      'cusine': 'creole',
      'category': 'meal',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Haddock',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Long Grain Rice',
          'amount': 130,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Sweet Potato',
          'amount': 200,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Add the rice to a pot', 'image': ''},
        {
          'step': 'Add cold water to rice',
          'image': 'https://dummyimage.com/100'
        },
        {'step': 'Cook on high until water is boiling', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Rich Mushroom Ragu Linguine (V)',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': 'Description',
      'cooktime': 25,
      'preptime': 5,
      'calories': 520,
      'portions': 4,
      'cusine': 'vegan',
      'category': 'meal',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Flat White Mushrooms',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Linguine',
          'amount': 180,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Chopped Tomato',
          'amount': 200,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Cut mushrooms into thick slices', 'image': ''},
        {
          'step':
              'Add to an oiled wide based pan and fry until starting to brown',
          'image': 'https://dummyimage.com/100'
        },
        {'step': 'Add chopped tomato', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Beef Satay Wraps',
      'thumbnail': 'https://dummyimage.com/100',
      'image': 'https://dummyimage.com/200',
      'description': 'description',
      'cooktime': 25,
      'preptime': 5,
      'calories': 520,
      'portions': 4,
      'cusine': 'hainanese',
      'category': 'indonesian',
      'keywords': '',
      'ingredients': [
        {
          'ingredient_id': 1,
          'ingredient_name': 'Minced Beef',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Soft Tortilla Wraps',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Peanut Butter',
          'amount': 25,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Add minced beef to an oiled wide based pan', 'image': ''},
        {
          'step':
              'cook on medium, breaking up beef until beef starting to brown',
          'image': 'https://dummyimage.com/100'
        },
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
  ];
  DateTime selectedWeekStart = DateTime.now(); // get today
  Map<String, List<Map<String, dynamic>>> plan = {}; // use JSON format
  bool isLoading = true; // for loading indicator

  @override
  void initState() {
    super.initState();
    // get the current userId and redirect to login if no current user
    userId = FirebaseService().getCurrentUserId();
    if (userId == '') {
      print("No user logged in. Redirecting to login page...");
      context.go('/');
    }
    initialisePlanner();
  }

  @override
  void dispose() {
    saveMealPlan();
    super.dispose();
  }

  Future<void> saveMealPlan() async {
    try {
      // used for testing
      // String userId = "1";
      await widget.firebaseService
          .saveMealPlan(userId, selectedWeekStart, plan);
    } catch (e) {
      print("Error saving meal plan: $e");
    }
  }

  void initialisePlanner() {
    // default the date to the sunday of the current week
    // create the date using only year, month, day
    // so time stays at 00:00
    // sunday = 0, .weekday gets the numerical value of the weekday
    // so subtracting this from the current date will always get
    // the previous sunday
    selectedWeekStart = DateTime(selectedWeekStart.year,
            selectedWeekStart.month, selectedWeekStart.day)
        .subtract(Duration(days: selectedWeekStart.weekday % 7));

    // https://blog.stackademic.com/how-to-flutter-running-functions-after-widget-initialization-7d7b4150b147
    // wait for UI to be built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPlannerData(); // fetch firebase data is fetched after UI is built
    });
  }

  Future<void> fetchPlannerData() async {
    setState(() => isLoading = true);
    try {
      //String userId = "1"; // Test Firebase user ID
      DateTime endDate =
          selectedWeekStart.add(Duration(days: 6)); // End of the week
      Map<String, List<Map<String, dynamic>>> fetchedPlan = await widget
          .firebaseService
          .getMealPlan(userId, selectedWeekStart, endDate);
// debug what is the format of the stored data - does it match what's expected?
      print("Fetched days from Firebase: ${fetchedPlan.keys.toList()}");
      print("Expected days in planner: ${createEmptyPlanner().keys.toList()}");
      // data from firebase only contains days in plan that have recipes
      // create an empty plan with all days initialised
      Map<String, List<Map<String, dynamic>>> fullWeekPlan =
          createEmptyPlanner();
      // add entries from firebase to the fullweekplan. now all days
      // are initialised
      fetchedPlan.forEach((day, recipes) {
        fullWeekPlan[day] = recipes;
      });
      setState(() {
        // use the fullweekplan which has firebase data and other days
        // initialised even if no recipes in them
        plan = fullWeekPlan;
        isLoading = false;
      });
      print("Final plan after merging missing days: ${plan.keys.toList()}");
    } catch (e) {
      print("Error fetching meal plan: $e");
      setState(() {
        plan = createEmptyPlanner();
        isLoading = false;
      });
    }
  }

  // create a empty week
  Map<String, List<Map<String, dynamic>>> createEmptyPlanner() {
    Map<String, List<Map<String, dynamic>>> emptyPlan = {};
    for (int i = 0; i < 7; i++) {
      final day =
          DateFormat('EEEE').format(selectedWeekStart.add(Duration(days: i)));
      emptyPlan[day] = []; // Initialize empty lists for each day
    }
// debug - check format of empty plan
    print("Creating planner for week starting: ${selectedWeekStart}");
    print("Generated days: ${emptyPlan.keys.toList()}");
    return emptyPlan;
  }

  // date picker
  void pickStartDate(BuildContext context) async {
    // if using the date picker save the current meal plan
    saveMealPlan();
    // get the result from showDatePicker as a datetime variable
    final DateTime? picked = await showDatePicker(
      context: context, // date picker to show at current context (the button)
      initialDate: selectedWeekStart,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedWeekStart) {
      // adjust picked date to the closest Sunday - subtract the mod 7 days
      final int offsetToSunday = picked.weekday % 7; // 0 for Sun, 1 for Mon
      setState(() {
        // trigger user interface re-build with the new data
        selectedWeekStart = DateTime(
          picked.year,
          picked.month,
          picked.day, // reset time to midnight, by not including time
        ).subtract(Duration(days: offsetToSunday));
        fetchPlannerData();
      });
    }
  }

  @override
  // full build of the user interface
  Widget build(BuildContext context) {
    // generate a list of the 7 days including the start date
    // for the drop zones for the recipes
    final weekDays = List.generate(
      7,
      (index) => selectedWeekStart.add(Duration(days: index)),
    );
    return Scaffold(
      appBar: AppBar(
        // top bar
        title: Text('Meal Planner'), // screen name
      ),
      drawer: MenuDrawer(), // menu icon in top bar
      body: Column(
        // main display column
        children: [
          // button to trigger date picker, shows start date of the week
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
// remove title looks better without title, more space on mobile
//                Text(
//                  'Week starting:',
//                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                ),
                OutlinedButton(
                  onPressed: () => pickStartDate(context),
                  child: Text(DateFormat('yMMMd').format(selectedWeekStart)),
                ),
              ],
            ),
          ),

          // weekdays display with drop zones for dragging the recipes
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // use a different component for this?
                crossAxisCount: 1,
                childAspectRatio: 3 / 0.8, // this controls how deep box is
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = DateFormat('EEEE')
                    .format(weekDays[index]); // day of the week
                return DragTarget<Map<String, dynamic>>(
                  onAcceptWithDetails: (details) {
                    // trigger for recipe dropped
                    final recipe = details.data; // extract the dragged recipe
                    setState(() {
// degub - check if day matches any day in the plan
                      print(
                          "Checking if $day exists in plan: ${plan.containsKey(day)}");
                      // update the UI
                      plan[day]
                          ?.add(recipe); // Add the recipe to the selected day
// debug
// temp save meal plan here so can see what's happening
                      saveMealPlan();
                      print('Added recipe to $day: ${recipe['title']}');
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Card(
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${day}, ${DateFormat('yMMMd').format(weekDays[index])}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: plan[day]?.isEmpty ?? true
                                ? Center(
                                    child: Text(
                                      'Drag recipes here',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView(
                                    children: plan[day]!.map((recipe) {
                                      return ListTile(
// remove thumbnail? need more space on screen
//                                        leading: ClipRRect(
//                                          borderRadius:
//                                              BorderRadius.circular(8),
//                                          child: Image.network(
//                                            recipe['thumbnail']!,
//                                           width: 50,
//                                            height: 50,
//                                            fit: BoxFit.cover,
//                                          ),
//                                        ),
                                        title: Text(
                                          recipe['title']!,
                                          style: TextStyle(
                                            fontSize:
                                                recipe['titleFontSize'] ?? 12.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // sticky bar for recipes that can be added to the plan
          Container(
            height: 100,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: addedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = addedRecipes[index];
                return LongPressDraggable<Map<String, dynamic>>(
                  data: recipe, // dragged data
// debug
                  onDragStarted: () {
                    print('Dragging started for: ${recipe['title']}');
                  },
                  onDragCompleted: () {
                    print('Dragging completed for: ${recipe['title']}');
                  },
                  onDragEnd: (details) {
                    print('Dragging ended for: ${recipe['title']}');
                  },
// end debug
                  feedback: Material(
                    color: Colors
                        .transparent, // make sure not white so we can see it
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: recipe['thumbnail']!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.white,
                          ),
                        ),
                        // Error Placeholder (Broken Image Icon)
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Opacity(
                      opacity: 0.5, // change appearance of item when dragging
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: recipe['thumbnail']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.white,
                            ),
                          ),
                          // Error Placeholder (Broken Image Icon)
                          errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: recipe['thumbnail']!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.white,
                          ),
                        ),
                        // Error Placeholder (Broken Image Icon)
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
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
