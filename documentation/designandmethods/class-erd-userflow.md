# Requirements


# UI flow

## user application UI flow
```mermaid
---
config:
#  look: handDrawn
  theme: base
---
flowchart
    login["login<br>process"]
    menudrawer["menu<br>drawer"]
    recipes["recipe<br>select"]
    recipeview[["view<br>recipe"]]
    planner["meal<br>planner"]
    cooked[["remove meal<br>ingredients<br>from stock"]]
    smartlist["smart<br>list"]
    addingredients[["add<br>ingredients<br>to stock"]]
    leftovers["leftover<br>preview"]
    recipesuggest[["suggest<br>recipe"]]
    ingredientstock["ingredient<br>stock"]
    logwaste["log<br>food waste"]
    analysewaste[["analyse<br>waste"]]
    logout["logout<br>process"]

    login-->menudrawer
    login-->planner
    menudrawer-->planner
    planner-->cooked
    menudrawer-->recipes
    recipes-->recipeview
    menudrawer-->smartlist
    menudrawer-->leftovers
    ingredientstock-->addingredients
    leftovers-->recipesuggest
    leftovers-->recipeview
    menudrawer-->ingredientstock
    menudrawer-->logwaste
    logwaste-->analysewaste
    menudrawer-->logout

```

## admin website UI flow
```mermaid
---
config:
#  look: handDrawn
  theme: base
---
flowchart
    login["login<br>process"]
    index["index<br>welcome"]
    menudrawer["menu<br>drawer"]
    users["manage<br>users"]
    quantities["manage<br>quantities"]
    ingredients["manage<br>ingredients"]
    recipes["manage<br>recipes"]
    addingredients[["add<br>ingredients<br>to recipe"]]
    addmethods[["add<br>methods<br>to recipe"]]
    download["download<br>data"]
    logout["logout<br>process"]
    login-->menudrawer
    login-->index
    menudrawer-->users
    menudrawer-->quantities
    menudrawer-->ingredients
    menudrawer-->recipes
    recipes-->addingredients
    recipes-->addmethods
    menudrawer-->download
    menudrawer-->logout
```



# data structures


## Class Diagrams


### high level overview
```mermaid
classDiagram
    class User {
        +int userId
        +Int firebaseId
    }

    class WasteLog {
        +int wasteId
        +int userId
    }

    class Stock {
        +int stockId
        +int userId
        +int ingredientId
    }

    class Smartlist {
        +int listId
        +int mealplanId
        +int userId
        +int storeId
    }

    class Smartlistitem {
        +int listitemId
        +int ingredientId
        +int mealplanId
    }

    class Recipe {
        +int recipeId
    }

    class RecipeIngredient {
        +int recipeIngredientId
        +int recipeId
    }

    class RecipeMethod {
        +int recipeMethodId
        +int stepOrder
    }

    class MealPlan {
        +int mealPlanId
        +int userId
    }

    class MealPlanIngredient {
        +int itemId
        +int mealplanId
        +int ingredientId
    }
    class Store {
        +int storeId
        +String name
    }

    class Moq {
        +int moqId
        +int storeId
        +int ingredientId
    }

    class Ingredient {
        +int ingredientId
    }

    class Stock {
        +int stockId
        +int userId
    }




    User "1" --> "*" WasteLog
    User "1" --> "*" Stock
    User "1" --> "*" Smartlist
    Smartlist "1" --> "*" Smartlistitem
    Smartlistitem "1" --> "1" Ingredient
    Recipe "1" --> "*" RecipeIngredient
    Recipe "1" --> "*" RecipeMethod
    RecipeIngredient "1" --> "1" Ingredient
    MealPlan "1" --> "1" Recipe
    MealPlan "1" --> "*" MealPlanIngredient
    MealPlanIngredient "1" --> "1" Ingredient
    Store "1" --> "*" Moq
    Moq "*" --> "1" Ingredient
    Stock "1" --> "1" Ingredient

```
### User related entities
```mermaid
classDiagram
    class User {
        +int userId
        +Int firebaseId
        -String pwhash
        +int preferredPortions
        +String preferredStore
        +verifyPassword(String inputPassword): bool
        +toJson(): Map<String, dynamic>
        +fromJson(Map<String, dynamic> json): User
        +validateEmail(): bool
    }

    class WasteLog {
        +int wasteId
        +int userId
        +DateTime week
        +DateTime logdate
        +double amount
        +double composted
        +double inedibleParts
    }

    class Stock {
        +int stockId
        +int userId
        +int ingredientId
        +double ingredientAmount
    }

    class Smartlist {
        +int listId
        +int mealplanId
        +int userId
        +int storeId
        +DateTime week
        +double amount
    }

    class Smartlistitem {
        +int listitemId
        +int ingredientId
        +int mealplanId
        +double amount
        +bool purchased
        +double purchaseAmount
        +double leftoverAmount
        +double recipeAmount
    }

    User "1" --> "*" WasteLog
    User "1" --> "*" Stock
    User "1" --> "*" Smartlist
    Smartlist "1" --> "*" Smartlistitem
    Smartlistitem "1" --> "1" Ingredient
```
### Recipe and Meal Planning Entities
```mermaid
classDiagram
    class Recipe {
        +int recipeId
        +String title
        +String description
        +String thumbnail
        +String image
        +int cooktime
        +int preptime
        +int calories
        +int portions
        +String cusine
        +String category
        +String keywords
        +List~String~ additionalIngredients
        +fromJson(Map<String, dynamic> json): Recipe
        +toJson(): Map<String, dynamic>
    }

    class RecipeIngredient {
        +int recipeIngredientId
        +int recipeId
        +double amount
        +List~Ingredient~ ingredients
    }

    class RecipeMethod {
        +int recipeMethodId
        +int stepOrder
        +String title
        +String description
        +String image
    }

    class Ingredient {
        +int ingredientId
        +String ingredientName
        +String units
    }

    class MealPlan {
        +int mealPlanId
        +int userId
        +DateTime mealDate
        +int portions
        +int recipeId
    }

    class MealPlanIngredient {
        +int itemId
        +int mealplanId
        +int ingredientId
        +double amount
        +String units
    }

    Recipe "1" --> "*" RecipeIngredient
    Recipe "1" --> "*" RecipeMethod
    RecipeIngredient "1" --> "1" Ingredient
    MealPlan "1" --> "1" Recipe
    MealPlan "1" --> "*" MealPlanIngredient
    MealPlanIngredient "1" --> "1" Ingredient
```
### Store and Inventory Entities
```mermaid
classDiagram
    class Store {
        +int storeId
        +String name
    }

    class Moq {
        +int moqId
        +int storeId
        +int ingredientId
        +double amount
        +String units
        +String ingredientURL
        +DateTime lastUpdated
    }

    class Ingredient {
        +int ingredientId
        +String ingredientName
        +String units
    }

    class Stock {
        +int stockId
        +int userId
        +int ingredientId
        +double ingredientAmount
    }

    Store "1" --> "*" Moq
    Moq "*" --> "1" Ingredient
    Stock "1" --> "1" Ingredient
```

### Full Class Diagram (too big to include in documentation)

```mermaid
classDiagram
    class User {
        int userId
        int firebaseId
        String pwhash
        int preferredPortions
        String preferredStore
        User(userId: int, email: String, pwhash: String, preferredPortions: int, preferredStore: String)
        verifyPassword(String inputPassword): bool
        toJson(): Map<String, dynamic>
        fromJson(Map<String, dynamic> json): User
        validateEmail(): bool
    }

    class Recipe {
        int recipeId
        String title
        String description
        String thumbnail
        String image
        int cooktime
        int preptime
        int calories
        int portions
        String cusine
        String category
        String keywords
        List~String~ additionalIngredients
        List~Recipeingredient~ recipeingredients
        List~RecipeMethod~ recipeMethods
        Recipe(recipeId: int, title: String, description: String, thumbnail: String, image: String, cooktime: int, preptime: int, calories: int, portions: int, cusine: String, category: String, keywords: String, additionalIngredients: List~String~, recipeingredients: List~Recipeingredient~, recipeMethods: List~RecipeMethod~)
        fromJson(Map<String, dynamic> json): Recipe
        toJson(): Map<String, dynamic>
    }

    class RecipeMethod {
        int recipeMethodId
        int stepOrder
        String title
        String description
        String image
        RecipeMethod(recipeMethodId: int, stepOrder: int, title: String, description: String, image: String)
        fromJson(Map<String, dynamic> json): RecipeMethod
        toJson(): Map<String, dynamic>
    }

    class RecipeIngredient {
        int recipeIngredientId
        int recipeId
        double amount
        List~Ingredient~ ingredients
        Recipeingredient(recipeIngredientId: int, recipeId: int, amount: double, ingredients: List~Ingredient~)
        fromJson(Map<String, dynamic> json): RecipeMethod
        toJson(): Map<String, dynamic>
    }

    class Ingredient {
        int ingredientId
        String ingredientName
        String units
        Ingredient(ingredientId: int, ingredientName: String, units: String)
        fromJson(Map<String, dynamic> json): RecipeMethod
        toJson(): Map<String, dynamic>
    }

    class MealPlan {
        int mealPlanId
        int userId
        DateTime mealDate
        int portions
        int recipeId
    }

    class MealPlanIngredient {
        int itemId
        int mealplanId
        int ingredientId
        double amount
        String units
        MealPlanIngredients(itemId: int, mealplanId: int, ingredientId: int, amount: double, units: String)
    }

    class Stock {
        int stockId
        int userId
        int ingredientId
        double ingredientAmount
        Stock(stockId: int, userId: int, ingredientId: int, ingredientAmount: double)
    }


     class Moq {
        int moqId
        int storeId
        int ingredientId
        double amount
        String units
        String ingredientURL
        DateTime lastUpdated
        Moq(moqId: int, storeId: int, ingredientId: int, amount: double, units: String, ingredientURL: String,lastUpdated: DateTime)
    }

    class Store {
      int storeId
      String name
      Store(storeId: String, name: String)
    }

    class Smartlist {
        int listId
        int mealplanId
        int userId
        int storeId
        DateTime week
        double amount
        Smartlist(listId: int, mealplanId: int, userId: int, storeId: int, week: DateTime, amount: double)
    }

       class Smartlistitem {
        int listitemId
        int ingredientId
        int mealplanId
        double amount
        bool purchased
        double purchaseAmount
        double leftoverAmount
        double recipeAmount
        Smartlistitem(listitemId: int, ingredientId: int, mealplanId: int, amount: double, purchased: bool, purchaseAmount: double, leftoverAmount: double, recipeAmount: double)
    }

    class WasteLog {
        int wasteId
        int userId
        DateTime week
        DateTime logdate
        double amount
        double composted
        double inedibleParts
        WasteLog(wasteId: int, userId: int, week: DateTime, logdate: DateTime, amount: double, composted: double, inedibleParts: double)
    }

    User "1" --> "*" WasteLog
    User "1" --> "*" Smartlist : links to
    Smartlist "1" --> "*" Smartlistitem
    Smartlistitem "1" --> "1" Ingredient : links to
    Store "1" --> "*" Moq : links to
    Ingredient "1"-->"*" Moq : links to
    User "1" --> "*" Stock : links to
    User "1" --> "*" MealPlan : links to
    Stock "1" --> "1" Ingredient : links to
    MealPlan "1" --> "*" MealPlanIngredient
    MealPlanIngredient "1" --> "1" Ingredient
    MealPlan "1" --> "1" Recipe : links to
    Recipe "1" -- "*" RecipeIngredient
    Recipe "1" -- "*" RecipeMethod
    RecipeIngredient "1" -- "1" Ingredient



```

## Database Design SQL


```mermaid
---
config:
  look: handDrawn
  theme: base
---
erDiagram
    users{
        user_id INT PK "unique id for each user"
        firebaseId INT "UUID from firebase"
        pwhash VARCHAR(200) "hashed password"
        preferred_portions INT "preferred portion size for recipes"
        preferred_store INT "preferred store for purchasing"
    }
    mealplan {
      mealplan_id INT PK "unique id for each day in a meal plan"
      user_id INT FK 
      mealdate DATETIME "date of the meal in the plan"
      portions INT  "portions of this recipe in the meal plan"
      recipe_id INT FK "id of the recipe used on this day"
    }

    mealplan_ingredients {
      item_id INT PK
      mealplan_id INT FK
      ingredient_id INT FK
      amount DECIMAL "amount reqired by the recipe"
      units VARCHAR(10) "units of the ingredient in the meal plan ingredient list"
    }

    ingredients {
        ingredient_id INT PK "unique id for each ingredient" 
        name VARCHAR(50) "description of the ingredient e.g. lamb mince"
        type VARCHAR(10) "produce type, i.e. vegetable, fruit, dry, meat, fish etc"
        units VARCHAR(10) "the units this ingredient is measured in, grams, ml, etc"
    }
    stock {
        stock_id INT PK "unique id for each item of stock"
        user_id INT FK "user who has this stock item"
        ingredient_id INT FK "unique id of this stock item"
        ingredient_amount DECIMAL "amount of this ingredient in stock"
    }
    moq {
        moq_id INT PK "unique id for this minimum order quantity"
        store_id INT "store id for this minimum order quantity"
        ingredient_id INT "ingredient that this minimum order quantity is for"
        amount DECIMAL "minimum order quanitity for this ingredient"
        units VARCHAR(10) "units for theminimum order quantity"
        ingredientURL VARCHAR(100) "the URL for this product at this store"
        last_updated DATETIME "date and time this moq was checked"
    }
    store {
        store_id INT PK "unique id for a store"
        name VARCHAR(100) "store name"
    }
    recipes {
      recipe_id INT PK "unique reference for a recipe"
      title VARCHAR(100)
      description VARCHAR(200)
      thumbnail VARCHAR(200)
      image VARCHAR(200)
      cooktime INT
      preptime INT
      calories INT
      portions INT
      cuisine VARCHAR(10)
      category VARCHAR(10)
      keywords VARCHAR(200)
      additional_ingredients VARCHAR(100) "ingredients like salt and pepper that are required"
    }
    recipe_ingredients {
      recipe_id INT PK
      recipe_ingredient_id INT PK
      ingredient_id INT FK
      amount DECIMAL
      units VARCHAR(10)
    }
    recipe_methods {
      recipe_method_id INT PK
      step_order INT "the order of this step"
      title VARCHAR(100) "optional title of the step in the method"
      description VARCHAR(100) "the details of what should be done in this step"
      image VARCHAR(200) "URL to a picture to help with this step"
    }
    smartlists {
      list_id INT PK "id for this smart list - one per week"
      mealplan_id INT FK "id for the meal plan that this smart list relates to"
      user_id INT FK "user who created this smart list"
      store_id INT FK "the selected store for this smart list"
      week DATETIME "date of the first day in the meal plan"
      amount DECIMAL "weight of fresh produce in grams required by recipes"
    }
    smartlistitems {
      listitem_id INT PK
      ingredient_id INT FK
      mealplan_id INT FK
      amount DECIMAL "amount reqired by the recipe"
      units VARCHAR(10) "units of the ingredient in the smart list"
      purchased BOOLEAN "indicates if item was purchased"
      purchase_amount DECIMAL "amount of ingredient that needs to be purchased"
      leftover_amount DECIMAL "amount of ingredient that will be left over"
      recipe_amount DECIMAL "amount of ingredient that all meal plan recipes require"
    }
    wastelogs {
      waste_id INT PK "unique reference for this waste logging"
      user_id INT FK
      week DATETIME "date of the start of the week"
      logdate DATETIME "date and time the recording was made"
      amount DECIMAL "total waste in grams"
      composted DECIMAL "%age composted"
      inedible_parts DECIMAL "%age inedible parts"
    }

    recipes ||--|{ recipe_methods : contains
    recipes ||--|{ recipe_ingredients : contains
    users ||--|{ stock : allows
    ingredients ||--|{ moq : allows
    stock ||--|| ingredients : allows
    moq ||--|| store : allows
    mealplan ||--|| recipes : allows
    mealplan ||--|{ mealplan_ingredients : allows
    users ||--|{ mealplan : allows
    users ||--|{ smartlists : allows
    smartlists ||--|{ smartlistitems : contains
    users ||--|{ wastelogs : allows
```


