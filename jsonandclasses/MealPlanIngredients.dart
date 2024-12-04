class MealPlanIngredient {
  int itemId;
  int mealplanId;
  int ingredientId;
  int amount;
  String units;

  MealPlanIngredient({
    required this.itemId,
    required this.mealplanId,
    required this.ingredientId,
    required this.amount,
    required this.units,
  });
}
