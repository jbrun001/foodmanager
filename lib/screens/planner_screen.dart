import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // for date formatting
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect
import '../widgets/recipedetail.dart';

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

  List<Map<String, dynamic>> addedRecipes = [];

  DateTime selectedWeekStart = DateTime.now(); // get today
  Map<String, List<Map<String, dynamic>>> plan = {}; // use JSON format
  bool isLoading = true; // for loading indicator
  int preferredPortions = 2; // set to 2 incase no data in user profile

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

  void loadUserRecipes() async {
    final saved = await widget.firebaseService.getUserRecipes(userId);
    setState(() {
      addedRecipes = saved;
    });
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
    // added preferred portions use async to all data is recieved before continuing
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchPreferredPortions();
      fetchPlannerData(); // fetch firebase data is fetched after UI is built
      // get recipes saved on recipe screen
      loadUserRecipes();
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

  // get the user profile info and the preferredPortions from that
  Future<void> fetchPreferredPortions() async {
    final userData = await widget.firebaseService.getUserDetails(userId);
    if (userData != null && userData.containsKey('preferredPortions')) {
      setState(() {
        preferredPortions = userData['preferredPortions'];
      });
    }
  }

  // create an empty week
  Map<String, List<Map<String, dynamic>>> createEmptyPlanner() {
    Map<String, List<Map<String, dynamic>>> emptyPlan = {};
    for (int i = 0; i < 7; i++) {
      final day =
          DateFormat('EEEE').format(selectedWeekStart.add(Duration(days: i)));
      emptyPlan[day] = []; // Initialize empty lists for each day
    }
// testing - check format of empty plan
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

  // function to scale ingredients used onchange of portions
  // and also in onAcceptWithDetails when recipe dropped in drag area
  // returns list of scaled ingredients
  List<Map<String, dynamic>> scaleIngredients({
    required List<Map<String, dynamic>> originalIngredients,
    required int originalPortions,
    required int targetPortions,
  }) {
    List<Map<String, dynamic>> scaledIngredients = [];
    print('scale ingredients: from $originalPortions to $targetPortions');

    for (var ingredient in originalIngredients) {
      // create copy of ingredients
      Map<String, dynamic> scaled = Map<String, dynamic>.from(ingredient);
      // force amount to double
      final double originalAmount = (scaled['amount'] ?? 0).toDouble();
      // scale ingredient
      final double scaledAmount =
          (originalAmount / originalPortions) * targetPortions;
      // round up to nearest whole number
      scaled['amount'] = scaledAmount.ceil();
      scaledIngredients.add(scaled);
      print(
          "Scale: ${scaled['ingredient_name']} orginal: ${ingredient['amount']} scaled: ${scaled['amount']}");
    }
    print("end scaling");
    return scaledIngredients;
  }

  // show full recipe details using the scaled ingredients from the planner
  void showPlannedRecipeDetail(
      BuildContext context, Map<String, dynamic> plannedRecipe) {
    // find the full recipe by matching the title
    final fullRecipe = addedRecipes.firstWhere(
      (recipe) => recipe['title'] == plannedRecipe['title'],
      orElse: () => {}, // empty if not found
    );
    // testing
    if (fullRecipe.isEmpty) {
      print("Full recipe not found for: ${plannedRecipe['title']}");
      return;
    }
    // create a new copy of the full recipe
    final mergedRecipe = Map<String, dynamic>.from(fullRecipe);
    // replace the ingredients with the scaled ones from the planner
    mergedRecipe['ingredients'] =
        List<Map<String, dynamic>>.from(plannedRecipe['ingredients'] ?? []);
    // update the portion count as shown in the plan
    mergedRecipe['portions'] = plannedRecipe['plannedPortions'];
    // show the recipe using recipe detail widget
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            child: RecipeDetail(recipe: mergedRecipe),
          ),
        );
      },
    );
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
        title: Text('Plan'),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go('/preview', extra: widget.firebaseService);
            },
            icon: Icon(Icons.arrow_forward, color: Colors.black),
            label: Text(
              'Preview',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                    child: Text(
                        '${DateFormat('yMMMd').format(selectedWeekStart)}')),
              ],
            ),
          ),
          // main screen - draggable target areas for each of the days in the
          // week starting date is the sunday from the date picker
          Expanded(
            child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = DateFormat('EEEE').format(weekDays[index]);
                  return DragTarget<Map<String, dynamic>>(
                    // trigger if a recipe is dropped in the drag target
                    onAcceptWithDetails: (details) {
                      final originalRecipe =
                          Map<String, dynamic>.from(details.data);
                      final int originalPortions =
                          originalRecipe['portions'] ?? 1;
                      final int userPortions = preferredPortions;

                      final scaledRecipe =
                          Map<String, dynamic>.from(originalRecipe);
                      // store a copy of original ingredients
                      final originalIngredients =
                          List<Map<String, dynamic>>.from(
                              originalRecipe['ingredients'] ?? []);
                      scaledRecipe['ingredientsOriginal'] = originalIngredients;
                      // scale from the original
                      scaledRecipe['ingredients'] = scaleIngredients(
                        originalIngredients: originalIngredients,
                        originalPortions: originalPortions,
                        targetPortions: userPortions,
                      );

                      scaledRecipe['plannedPortions'] = userPortions;
                      setState(() {
// degub - check if day matches any day in the plan
                        print(
                            "Checking if $day exists in plan: ${plan.containsKey(day)}");
                        // update the UI
                        plan[day]
                            ?.add(scaledRecipe); // add recipe to selected day
                        saveMealPlan();
                      });
                    },
                    // styling and UI for the dragable area
                    builder: (context, candidateData, rejectedData) {
                      // true if dragged item is above this dragable area
                      final isHovering = candidateData.isNotEmpty;
                      // use AnimatedScale to animate the drag target
                      // when dragging recipe over it
                      // https://medium.com/easy-flutter/animatedscale-in-flutter-simple-scaling-animations-5719a7230f0f
                      return AnimatedScale(
                        scale: isHovering ? 1.02 : 1.0,
                        duration: Duration(milliseconds: 150),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 150),
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isHovering ? Colors.green[50] : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              if (isHovering)
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                            ],
                            border: Border.all(
                              color: isHovering
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: isHovering ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${day}, ${DateFormat('yMMMd').format(weekDays[index])}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              // for the current day if there are any recipes
                              // in the plan (not null ?? []) generate a ListTile for
                              // each one and insert them into the UI widget
                              // tree ... allows multiple items to be inserted
                              // .map(recipe) converts recipe into ListTile
                              ...(plan[day] ?? []).map((recipe) {
                                return ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      DropdownButton<int>(
                                          value: recipe['plannedPortions'] ??
                                              recipe['portions'] ??
                                              1,
                                          items: List.generate(8, (i) => i + 1)
                                              .map((val) => DropdownMenuItem(
                                                  value: val,
                                                  child: Text('$val')))
                                              .toList(),
                                          // if user changes portions
                                          // recalculate the ingredient amounts
                                          onChanged: (val) {
                                            setState(() {
                                              final int newPortions = val ?? 1;
                                              final int originalPortions =
                                                  recipe['portions'] ?? 1;
                                              // make sure ingredientsOriginal exists
                                              recipe['ingredientsOriginal'] ??=
                                                  List<
                                                          Map<String,
                                                              dynamic>>.from(
                                                      recipe['ingredients']);
                                              final originalIngredients = List<
                                                  Map<String,
                                                      dynamic>>.from(recipe[
                                                  'ingredientsOriginal']);
                                              recipe['ingredients'] =
                                                  scaleIngredients(
                                                originalIngredients:
                                                    originalIngredients,
                                                originalPortions:
                                                    originalPortions,
                                                targetPortions: newPortions,
                                              );
                                              recipe['plannedPortions'] =
                                                  newPortions;
                                              saveMealPlan();
                                            });
                                          }),
                                      // make the title text clickable https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showPlannedRecipeDetail(context,
                                                recipe); // show modal with full details
                                          },
                                          child: Text(
                                            recipe['title'] ?? 'Untitled',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              decoration: TextDecoration
                                                  .underline, // make it look like a link
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            plan[day]!.remove(recipe);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              if ((plan[day]?.isEmpty ?? true))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24.0),
                                  child: Center(
                                    child: Text(
                                      'Press and hold a recipe below & drag it to a day',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
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
                  // styling of dragged recipe
                  feedback: Material(
                    color: Colors.transparent,
                    // row with two columns
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // icon for the recipe
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: recipe['thumbnail'] ?? '',
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
                            // manage broken url for the image
                            errorWidget: (context, url, error) => Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // MVP.UAT.002 - add title of recipe to the
                        // draggable object to help users understand
                        // what is being dragged
                        Container(
                          width: 160,
                          height: 80,
                          padding: EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4)
                            ],
                          ),
                          child: Text(
                            recipe['title'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
