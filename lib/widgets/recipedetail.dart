import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class RecipeDetail extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetail({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image and Title
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: recipe['image'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 200, color: Colors.white),
                ),
                // Error Placeholder (Broken Image Icon)
                errorWidget: (context, url, error) =>
                    Icon(Icons.broken_image, size: 200),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Title, cooktime, and Calories
          Text(recipe['title'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 20, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                  'Total ${recipe['cooktime']}min, prep ${recipe['preptime']}min',
                  style: TextStyle(fontSize: 16)),
              SizedBox(width: 16),
              Icon(Icons.local_fire_department, size: 20, color: Colors.grey),
              SizedBox(width: 4),
              Text('${recipe['calories']}kcal', style: TextStyle(fontSize: 16)),
            ],
          ),

          // Portions
          SizedBox(height: 16),
          Text('Serves: ${recipe['portions']} people',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          // Ingredients
          Text('Ingredients:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          // ... spread operator allows insertion from one list into another in
          // this case we have a list of ingredients which we want to add to the widget
          // which is a list of UI elements
          // https://medium.com/@abhaykumarbhumihar/spread-operator-in-flutter-a-simple-guide-cdd00dc9bc7e
          ...recipe['ingredients'].map<Widget>((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                  '${ingredient['amount']}${ingredient['unit']} ${ingredient['ingredient_name']}',
                  style: TextStyle(fontSize: 16)),
            );
          }).toList(),
          if (recipe['additional_ingredients']?.isNotEmpty ?? false) ...[
            SizedBox(height: 8),
            Text('Additional Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(recipe['additional_ingredients'].join(', '),
                style: TextStyle(fontSize: 16)),
          ],
          // Method
          SizedBox(height: 16),
          Text('Method:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...recipe['method'].map<Widget>((step) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((step['image'] ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(step['image'],
                            width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    ),
                  Expanded(
                      child:
                          Text(step['step'], style: TextStyle(fontSize: 16))),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
