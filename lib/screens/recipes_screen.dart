import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class RecipesScreen extends StatefulWidget {
  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final List<Map<String, dynamic>> recipes = [
    {
      'title': 'One-Pot Hainanese-Style Chicken & Rice with Pak Choi',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
          'image': 'https://via.placeholder.com/100'
        },
        {'step': 'Add chicken and cook for 3-4 mins until brown', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title':
          'Creole-Style Haddock & Sweet Potato Stew with Garlic Rice extra long title',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
          'image': 'https://via.placeholder.com/100'
        },
        {'step': 'Cook on high until water is boiling', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Rich Mushroom Ragu Linguine (V)',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/200',
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
          'image': 'https://via.placeholder.com/100'
        },
        {'step': 'Add chopped tomato', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
    {
      'title': 'Beef Satay Wraps',
      'thumbnail': 'https://via.placeholder.com/100',
      'image': 'https://via.placeholder.com/100',
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
          'image': 'https://via.placeholder.com/100'
        },
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
  ];

  final List<Map<String, dynamic>> addedRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // initially load 50 recipies - user can serch for more
    filteredRecipes = recipes.take(50).toList();
  }

  void addRecipe(Map<String, dynamic> recipe) {
    setState(() {
      if (!addedRecipes.contains(recipe)) {
        addedRecipes.add(recipe);
      }
    });
  }

  void removeRecipe(Map<String, dynamic> recipe) {
    setState(() {
      addedRecipes.remove(recipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Search'),
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
                    labelText: 'Search Recipes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query.toLowerCase();
                      filteredRecipes = recipes.where((recipe) {
                        final title = recipe['title']?.toLowerCase() ?? '';
                        final keywords =
                            recipe['keywords']?.toLowerCase() ?? '';
                        final ingredients = (recipe['ingredients'] as List)
                            .map((i) =>
                                i['ingredient_name'].toString().toLowerCase())
                            .join(' ');
                        return title.contains(searchQuery) ||
                            keywords.contains(searchQuery) ||
                            ingredients.contains(searchQuery);
                      }).toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // use cached image for speed
                          CachedNetworkImage(
                            imageUrl: recipe['thumbnail']!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 100,
                                height: 100,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                                Icons.broken_image,
                                size: 100), // Error placeholder
                          ),
                          SizedBox(
                              width:
                                  8), // reduce the gap between the image and the text for better mobile fit
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe['title']!,
                                  maxLines: 4, // on mobile could be 4 lines?
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
                                    Text('${recipe['cooktime']!.toString()}min',
                                        style: TextStyle(color: Colors.grey)),
                                    SizedBox(width: 3),
                                    Icon(Icons.local_fire_department,
                                        size: 14, color: Colors.grey),
                                    SizedBox(width: 1),
                                    Text(
                                        '${recipe['calories']!.toString()}kcal',
                                        style: TextStyle(color: Colors.grey)),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailScreen(recipe: recipe),
                                    ),
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
