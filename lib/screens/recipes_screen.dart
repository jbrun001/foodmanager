import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect
import '../widgets/recipedetail.dart';

class RecipesScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  RecipesScreen({required this.firebaseService});

  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String userId = ''; // holds the current userId
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> addedRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  String searchQuery = '';
  bool isLoading = true; // is the data loading from the database?
  final List<int?> cookTimeOptions = [
    null,
    10,
    20,
    30,
    40,
    50,
    60,
    70
  ]; // R1.RD.02
  int? selectedCookTime; // null = no filter R1.RD.02
  final List<int?> caloriesOptions = [null, 500, 600, 700, 800, 900];
  int? selectedCalories;

  @override
  void initState() {
    super.initState();
    // get the current userId - if '' then redirect to login screen
    userId = FirebaseService().getCurrentUserId();
    if (userId == '') {
      print("No user logged in. Redirecting to login page...");
      context.go('/');
    }
    fetchRecipes(); // get all the recipes when the screen loads
    // filteredRecipes = recipes.take(50).toList();
  }

  Future<void> fetchRecipes() async {
    try {
      setState(() => isLoading = true); // start loading
      List<Map<String, dynamic>> fetchedRecipes =
          await widget.firebaseService.getRecipes();

      setState(() {
        recipes = fetchedRecipes;
        filteredRecipes = recipes.take(50).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() => isLoading = false);
    }
  }

  void addRecipe(Map<String, dynamic> recipe) {
    if (!addedRecipes.contains(recipe)) {
      setState(() {
        addedRecipes.add(recipe);
      });
      // save recipes here so database is up to date
      // was doing in dispose but planner screen
      // displayed before database operation was finished
      // so recipes didn't display - see also below
      widget.firebaseService.saveUserRecipes(userId, addedRecipes);
    }
  }

  void removeRecipe(Map<String, dynamic> recipe) {
    setState(() {
      addedRecipes.remove(recipe);
    });
    widget.firebaseService.saveUserRecipes(userId, addedRecipes);
  }

  // filter recipes
  void applyFilters() {
    filteredRecipes = recipes.where((recipe) {
      final title = recipe['title']?.toLowerCase() ?? '';
      final keywords = recipe['keywords']?.toLowerCase() ?? '';
      final ingredients = (recipe['ingredients'] as List)
          .map((i) => i['ingredient_name'].toString().toLowerCase())
          .join(' ');

      final matchQuery = title.contains(searchQuery) ||
          keywords.contains(searchQuery) ||
          ingredients.contains(searchQuery);

      bool matchTime;
      if (selectedCookTime == null) {
        matchTime = true; // no filtering
      } else {
        matchTime = recipe['cooktime'] <= selectedCookTime!;
      }

      bool matchCalories;
      if (selectedCalories == null) {
        matchCalories = true;
      } else {
        matchCalories = recipe['calories'] <= selectedCalories!;
      }

      return matchQuery && matchTime && matchCalories;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Select'),
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search by Ingredient, Cusine or Keyword',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query.toLowerCase();
                      applyFilters();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Max Time:", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    DropdownButton<int?>(
                      value: selectedCookTime,
                      onChanged: (value) {
                        setState(() {
                          selectedCookTime = value;
                          applyFilters();
                        });
                      },
                      items: cookTimeOptions.map((time) {
                        return DropdownMenuItem<int?>(
                          value: time,
                          child: Text(time == null ? 'Any' : '$time min'),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 8),
                    Text("Max Kcal:", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<int?>(
                        value: selectedCalories,
                        onChanged: (value) {
                          setState(() {
                            selectedCalories = value;
                            applyFilters();
                          });
                        },
                        items: caloriesOptions.map((cal) {
                          return DropdownMenuItem<int?>(
                            value: cal,
                            child: Text(cal == null ? 'Any' : '$cal'),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredRecipes.isEmpty
                        ? Center(child: Text("No recipes found"))
                        : ListView.builder(
                            itemCount: filteredRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = filteredRecipes[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    // use cached image for speed
                                    CachedNetworkImage(
                                      imageUrl: recipe['thumbnail']!,
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
                                          Icon(Icons.broken_image,
                                              size: 100), // Error placeholder
                                    ),
                                    SizedBox(
                                        width:
                                            8), // reduce the gap between the image and the text for better mobile fit
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe['title']!,
                                            maxLines:
                                                4, // on mobile could be 4 lines?
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                                  16, // make smaller to work with mobile
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
// remove description - not enough space on mobile if title is long
//                                Text(
//                                  recipe['description']!,
//                                  maxLines: 2,
//                                  overflow: TextOverflow.ellipsis,
//                                  style: TextStyle(color: Colors.grey[600]),
//                                ),
//                                SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.schedule,
                                                  size: 14, color: Colors.grey),
                                              SizedBox(width: 1),
                                              Text(
                                                  '${recipe['cooktime']!.toString()}min',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              SizedBox(width: 3),
                                              Icon(Icons.local_fire_department,
                                                  size: 14, color: Colors.grey),
                                              SizedBox(width: 1),
                                              Text(
                                                  '${recipe['calories']!.toString()}kcal',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => addRecipe(recipe),
                                          child: Text('Add'),
                                        ),
                                        OutlinedButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            20)),
                                              ),
                                              builder: (context) {
                                                return DraggableScrollableSheet(
                                                  expand: false,
                                                  initialChildSize: 0.85,
                                                  maxChildSize: 0.95,
                                                  builder: (_, controller) =>
                                                      SingleChildScrollView(
                                                    controller: controller,
                                                    child: RecipeDetail(
                                                        recipe: recipe),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Text('View'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          // put a sticky bar at the bottom to show added recipes
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
                            onTap: () =>
                                removeRecipe(recipe), // Remove recipe on tap
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: recipe['thumbnail']!,
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

/*
class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']!),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image and Title
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: recipe['image']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  // Error Placeholder (Broken Image Icon)
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image,
                    size: 200,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Title, cooktime, and Calories
            Text(
              recipe['title']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                    'Total ${recipe['cooktime']!.toString()}min, prep ${recipe['preptime']!.toString()}min',
                    style: TextStyle(fontSize: 16)),
                SizedBox(width: 16),
                Icon(Icons.local_fire_department, size: 20, color: Colors.grey),
                SizedBox(width: 4),
                Text('${recipe['calories']!.toString()}kcal',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 16),

            // Portions
            Text(
              'Serves: ${recipe['portions']} people',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Ingredients
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // ... spread operator allows insertion from one list into another in
            // this case we have a list of ingredients which we want to add to the widget
            // which is a list of UI elements
            // https://medium.com/@abhaykumarbhumihar/spread-operator-in-flutter-a-simple-guide-cdd00dc9bc7e
            ...recipe['ingredients'].map<Widget>((ingredient) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${ingredient['ingredient_name']} ${ingredient['amount']}${ingredient['unit']} ',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            if (recipe['additional_ingredients'] != null &&
                recipe['additional_ingredients'].isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Additional Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${recipe['additional_ingredients']?.join(', ') ?? 'None'}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 16),

            // Method
            Text(
              'Method:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...recipe['method'].map<Widget>((step) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step['image'] != null && step['image']!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            step['image']!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        step['step'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  } 
}

*/
// call recipedetail widget
class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe['title'])),
      body: RecipeDetail(recipe: recipe),
    );
  }
}
