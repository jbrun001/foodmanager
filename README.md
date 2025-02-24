# food manager
## current short term plan from project roadmap
```mermaid
gantt
    dateFormat  YYYY-MM-DD
    
    [MVP smartlist. re-calculate smart list on store change.] : done, 2025-02-22, 2025-02-22
    [MVP ingredient data. create appropriate test data for ingredients] : done, 2025-02-19, 2025-02-19
    [MVP. ingredient search. not saving amount changes to the database] : done, 2025-02-17, 2025-02-17
    [MVP. smartlists. create better recipe test data] : active, 2025-02-19, 2025-03-01
    [MVP waste logging screen] : done, 2025-02-22, 2025-02-24
    [MVP. left over preview screen. simple search. implementation] : done, 2025-02-23, 2025-02-23
    [MVP waste log screen. statistics] : done, 2025-02-25, 2025-02-24
    [MVP waste analysis screen] : done, 2025-02-22, 2025-02-23
    [MVP. Preview. basic search] : done, 2025-02-23, 2025-02-24
    [MVP user profile screen] : done, 2025-02-21, 2025-02-21
    [MVP. User Profile - additional details - password reset if username/password] : done, 2025-02-21, 2025-02-24
    [R1. create \Stores collection] : done, 2025-02-22, 2025-02-24
    [MVP. user authentication. oauth2 and firebase] : done, 2025-02-22, 2025-02-24
    [MVP. Authentication - sign in with google] : done, 2025-02-22, 2025-02-24
    [MVP. authentication. google. app signing] : done, 2025-02-21, 2025-02-22
    [MVP. Authentication - logout] : done, 2025-02-22, 2025-02-24
    [MVP. convert all screens to use firebaseid ] : done, 2025-02-20, 2025-02-24
    [MVP. smartlist. add functionality to take account of minimum order quanties] : done, 2025-02-18, 2025-02-19
    [MVP. smartlist. add functionality to take account of items already in stock items] : done, 2025-02-18, 2025-02-19
    [MVP. ingredient search. add ingredient to stock.] : active, 2025-02-26, 2025-02-26
    [R2. feedback enhancement. initial screen. dashboard.] : active, 2025-03-05, 2025-03-05
    [MVP. database performance testing] : active, 2025-02-27, 2025-02-28
    [MVP. authentication. Sign up] : done, 2025-02-20, 2025-02-24
    [MVP. login email/password firebase auth] : done, 2025-02-20, 2025-02-24
    [MVP. User profile. baseline screen] : done, 2025-02-20, 2025-02-24
    [MVP Waste Log. Initial screen] : done, 2025-02-22, 2025-02-24
    [MVP. Preview. Calc leftovers] : done, 2025-02-23, 2025-02-24
    [MVP. Preview. Initial screen] : done, 2025-02-23, 2025-02-24
    [MVP. firebase. security restrict access] : done, 2025-02-23, 2025-02-24
    [MVP. Waste analytics. graph component.] : done, 2025-02-23, 2025-02-24
    [MVP. Waste analytics. create screen] : done, 2025-02-24, 2025-02-24
    [MVP.ALL Initial testing] : active, 2025-02-25, 2025-02-28
    [Performance Testing] : active, 2025-02-26, 2025-02-26
    [Security Testing] : active, 2025-02-27, 2025-02-27
    [Usability Testing] : active, 2025-02-27, 2025-02-27
    [NFR.PE.01 - response under load] : active, 2025-02-27, 2025-02-27
    [NFR.PE.02 - API response times] : active, 2025-02-27, 2025-02-27
    [NFR.US.01 -  accessibility] : active, 2025-02-27, 2025-02-27
    [NFR.US.02 - action time] : active, 2025-02-27, 2025-02-27
    [NFR.SE.01 - password encryption] : active, 2025-02-28, 2025-02-28
    [NFR.SE.02 encryption in flight] : active, 2025-02-28, 2025-02-28
    [NFR.SE.03 - role based access controls] : active, 2025-02-28, 2025-02-28
```


## application prototype goals
-	[X] Set up, understand flutter, create a framework for the application.
-	[X] Prove that an application framework can be written in flutter, and works on multiple devices.
-	[X] Prove that list / search interface style is possible. Recipe Search UI.
- [X] Understand how styling is applied to flutter components
- [X] Prove that recipe drag and drop is possible for meal planner current UI design.
- [X] Prove that data can be passed from one screen to another, securely (poc recipe to recipe view)
-	[ ] Prove a test connection to firebase works (by reading and saving some data)
-	[ ] Prove that the app can access JSON from a rest API (can be a public API for technical proof of concept, because Databases project will be deployed on server)


## Flutter Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [online documentation](https://docs.flutter.dev/)
- [flutter design material.dart tutorial - medium](https://medium.com/@flutter.rashpinder/flutters-the-material-app-widget-a-developer-s-guided-series-part-1-cded465e6e8e)
- [flutter design material.dart tutorial - geeksforgeeks](https://www.geeksforgeeks.org/flutter-material-design/)
- [flutter design material.dart guide and code labs - material.io](https://m2.material.io/develop/flutter)
- [research into flutter and firebase](https://codewithandrea.com/videos/starter-architecture-flutter-firebase/)
- [JSON to dart converter](https://quicktype.io/dart)
- [Dart to Plant/Mermaid](https://pub.dev/packages/dcdg)

## Android APK build process

For actual apk on device to see size etc. prototype is 49Mb.

`flutter build apk`

apk will be in `build/output/flutter-apk/`

development:
copy to drive and download from there.

## Design & Method Diagrams
[UI flow, Class Diagrams, Data ERDs](documentation/designandmethods/class-erd-userflow.md)

### Use Case - User
![User Use Cases](./documentation/media/UseCase0-User.png)
### Use Case - Admin
![Admin Use Cases](./documentation/media/UseCase0-Admin.png)
