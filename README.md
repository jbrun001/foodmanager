# food_manager

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