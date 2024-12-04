class MealPlan {
  int mealplanId;
  int userId;
  DateTime mealdate;
  int portions;
  int recipeid;

  MealPlan({
    required this.mealplanId,
    required this.userId,
    required this.mealdate,
    required this.portions,
    required this.recipeid,
  });
}
