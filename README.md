# food_manager

## application prototype goals
-	[X] Set up, understand flutter, create a framework for the application.
-	[X] Prove that an application framework can be written in flutter, and works on multiple devices.
-	[X] Prove that list / search interface style is possible. Recipe Search UI.
- [X] Understand how styling is applied to flutter components
- [X] Prove that recipe drag and drop is possible for meal planner current UI design.
- [ ] Understand if/how elements can be re-used in different places without duplication (for example recipe list, or recipe view)
-	[ ] Prove that the app can access JSON from a rest API (can be a public API for technical proof of concept, because Databases project will be deployed on server)
- [X] Prove that data can be passed from one screen to another, securely
-	[ ] Prove a test connection to firebase works (by reading and saving some data)


## Flutter Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [online documentation](https://docs.flutter.dev/)

## Android APK build process

`flutter build apk`
apk will be in `build/output/flutter-apk/`
`apb install build/app/flutter-apk/app-release.apk`

# Requirements

## Use Case 


# UI flow
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
    

# data structures

```mermaid
---
config:
  look: handDrawn
  theme: base
---
erDiagram
    users{
        user_id INT PK "unique id for each user"
        email VARCHAR(60) "email address also used for login name"
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
        last_updated DATETiME "date and time this moq was checked"
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

#
