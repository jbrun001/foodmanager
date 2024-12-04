class Recipe {
  int recipeId;
  String title;
  String description;
  String thumbnail;
  String image;
  int cooktime;
  int preptime;
  int calories;
  int portions;
  String cusine;
  String category;
  String keywords;
  List<String> additionalIngredients;
  List<RecipeIngredient> recipeingredients;
  List<RecipeMethod> recipeMethods;

  Recipe({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.image,
    required this.cooktime,
    required this.preptime,
    required this.calories,
    required this.portions,
    required this.cusine,
    required this.category,
    required this.keywords,
    required this.additionalIngredients,
    required this.recipeingredients,
    required this.recipeMethods,
  });
}

class RecipeMethod {
  int recipeMethodId;
  int stepOrder;
  String title;
  String description;
  String image;

  RecipeMethod({
    required this.recipeMethodId,
    required this.stepOrder,
    required this.title,
    required this.description,
    required this.image,
  });
}

class RecipeIngredient {
  int recipeIngredientId;
  int recipeId;
  int amount;
  List<Ingredient> ingredients;

  RecipeIngredient({
    required this.recipeIngredientId,
    required this.recipeId,
    required this.amount,
    required this.ingredients,
  });
}

class Ingredient {
  int ingredientId;
  String ingredientName;
  String units;

  Ingredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.units,
  });
}
