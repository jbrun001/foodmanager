# food_manager

## application prototype goals
-	[X] Set up, understand flutter, create a framework for the application.
-	[X] Prove that an application framework can be written in flutter, and works on multiple devices.
-	[X] Prove that list / search interface style is possible. Recipe Search.
-   [ ] Prove that recipe drag and drop is possible for meal planner current UI design.
-   [X] Understand how styling is applied to flutter components
-   [ ] Understand if/how elements can be re-used in different places without duplication (for example recipe list, or recipe view)
-	[ ] Prove that the app can access JSON from a rest API (can be a public API for technical proof of concept, because Databases project will be deployed on server)
-   [ ] Prove that data can be passed from one screen to another, securely
-	[ ] Prove a test connection to firebase works (by reading and saving some data)


## Flutter Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [online documentation](https://docs.flutter.dev/)

# UML



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
    addtomylist[["add recipe to<br> my recipes"]]
    recipeview[["view<br>recipe"]]
    planner["meal<br>planner"]
    cooked[["remove meal<br>ingredients<br>from stock"]]
    smartlist["shopping<br>list"]
    addingredients[["add<br>ingredients<br>to stock"]]
    leftovers["leftover<br>preview"]
    recipesuggest[["suggest<br>recipe"]]
    ingredientstock["ingredient<br>stock"]
    logwaste["log<br>food waste"]
    analysewaste["analyse<br>waste"]
    logout["logout<br>process"]

    login-->menudrawer
    login-->planner
    menudrawer-->planner
    planner-->cooked
    menudrawer-->recipes
    recipes-->addtomylist
    recipes-->recipeview
    menudrawer-->smartlist
    smartlist-->leftovers
    leftovers-->recipesuggest
    recipesuggest-->addtomylist
    smartlist-->addingredients
    menudrawer-->ingredientstock
    menudrawer-->logwaste
    menudrawer-->analysewaste
    menudrawer-->logout

```
    

# data structures



#