# draft script for prototype audio

This is the food manager prototype.

It has been written using flutter in dart.

The purpose of the prototype was for me to

understand flutter and dart (because these are both new to me),

translate concepts that I already know to a new language (for examples routes), 

take critical elements from my design, and prove

to myself that they were possible in flutter and dart.

That's things like the look and feel of the app,

key elements in the design like dragging and dropping recipes,

but also how large the app when it's compiled, and 

how it feels for a user.


If I couldn't achieve these things in the prototype, I would have needed to change the design


I have implemented interfaces for 

login,
recipe search,
recipe select,
recipe view,
and meal planning allocating a recipe to a day

I chose these because they each demonstrate key functions that I need in the application for it to work.


*login*
**jake@123.com**
**Complex&Long2**

*goes to recipe screen*
*click menu to talk about menu*

I used the go router package to create a routes.  
This works in a similar way to routes in node.js

This menu code is in a separate dart file and is imported into every screen so it can be shown as part of the user interface

**recipes search**

This is the recipe search / view / select use case.

First proof is that I could search recipes.

Here I can enter a search term and it will filter the recipes and display them

using the title, any individual ingredient, or any keyword that the recipe has

if I search for ragu i get one result based on the title

if i search for tomato I get one result based on the ingredient list

searching for rice gets any recipe with rice in it


next I wanted to prove that I could send information from one screen to another

when I click view - the recipe view screen displays the recipe that i clicked on


A critical part of the design is that a user can select recipes here,

and they appear on the meal planner screen so they can be allocated to days.

clicking add on recipes adds them to a sticky bottom bar.

and clicking them in sticky bar removes them

**click the first one**

**click it in the bottom to remove it**

I'm going to select all of these recipes to use in the meal planner

**click all in order so they go down the bottom**

Now I need to go to the meal plan screen to allocate these recipes to days

**menu**

**meal planning screen**

A key part of the interface design was to be able to drag and drop recipes

into days. If this was not possible then the user interface would need to

be much more complicated (and possibly confusing for users), so it was 

important to prove that this was possible.

here I can choose the meal plan I want

**select a day in the date picker - like next week**

here I can long press and drag a recipe from the sticky bar to a day of the week

**drag the first icon to the first day**

**drag the second item to the second day**

This proves that I could implement the design.

It was a steep learning curve to understand flutter and to understand 

how the user interfaces were built.  Stateful user interfaces were used for

the recipe search and meal planning screens because I needed to be able to 

update the interface based on user actions, stateless user interfaces were used

for the menu and the recipe view.

I am confident that the key elements of the interface are possible with flutter

and happy that I have been able to build something that matches my design quite closely.

One issue that I have noticed is that loading images from URLs can be quite slow,

so this is something that will need to be reviewed in the development phase.

**back to the menu**

close the demo


