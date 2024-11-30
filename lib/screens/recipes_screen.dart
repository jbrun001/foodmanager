import 'package:flutter/material.dart';
import 'menu_drawer.dart';

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
          'ingredient_name': 'Spaghetti',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Eggs',
          'amount': 3,
          'unit': ''
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Pancetta',
          'amount': 100,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Boil the spaghetti.', 'image': ''},
        {'step': 'Fry pancetta.', 'image': 'https://via.placeholder.com/100'},
        {'step': 'Mix eggs and cheese.', 'image': ''},
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
          'ingredient_name': 'Spaghetti',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Eggs',
          'amount': 3,
          'unit': ''
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Pancetta',
          'amount': 100,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Boil the spaghetti.', 'image': ''},
        {'step': 'Fry pancetta.', 'image': 'https://via.placeholder.com/100'},
        {'step': 'Mix eggs and cheese.', 'image': ''},
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
          'ingredient_name': 'Spaghetti',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Eggs',
          'amount': 3,
          'unit': ''
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Pancetta',
          'amount': 100,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Boil the spaghetti.', 'image': ''},
        {'step': 'Fry pancetta.', 'image': 'https://via.placeholder.com/100'},
        {'step': 'Mix eggs and cheese.', 'image': ''},
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
          'ingredient_name': 'Spaghetti',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Eggs',
          'amount': 3,
          'unit': ''
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Pancetta',
          'amount': 100,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Boil the spaghetti.', 'image': ''},
        {'step': 'Fry pancetta.', 'image': 'https://via.placeholder.com/100'},
        {'step': 'Mix eggs and cheese.', 'image': ''},
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
          'ingredient_name': 'Spaghetti',
          'amount': 200,
          'unit': 'g'
        },
        {
          'ingredient_id': 2,
          'ingredient_name': 'Eggs',
          'amount': 3,
          'unit': ''
        },
        {
          'ingredient_id': 3,
          'ingredient_name': 'Pancetta',
          'amount': 100,
          'unit': 'g'
        },
      ],
      'method': [
        {'step': 'Boil the spaghetti.', 'image': ''},
        {'step': 'Fry pancetta.', 'image': 'https://via.placeholder.com/100'},
        {'step': 'Mix eggs and cheese.', 'image': ''},
      ],
      'additional_ingredients': ['Salt', 'Pepper'],
    },
  ];

  final List<Map<String, dynamic>> addedRecipes = [];

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
        title: Text('Recipes'),
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
                    // Add search logic here
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 100, // reduce this so more space on mobile
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(recipe[
                                    'thumbnail']!), // if thumbnail is null do nothing
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                              child: Image.network(
                                recipe['image']!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
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
                child: Image.network(
                  recipe['image']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
