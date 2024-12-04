class Smartlistitem {
  int listitemId;
  int ingredientId;
  int mealplanId;
  double amount;
  bool purchased;
  double purchaseAmount;
  double leftoverAmount;
  double recipeAmount;

  Smartlistitem({
    required this.listitemId,
    required this.ingredientId,
    required this.mealplanId,
    required this.amount,
    required this.purchased,
    required this.purchaseAmount,
    required this.leftoverAmount,
    required this.recipeAmount,
  });
}
