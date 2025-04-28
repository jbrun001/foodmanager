# Food Manager
A household meal planning & shopping app to help reduce food waste. 
https://github.com/jbrun001/foodmanager/project-highlights.md

Requirements
- Flutter SDK
- Android Studio
- Xcode
- Firebase

## Flutter SDK

> https://docs.flutter.dev/get-started/install

## Firebase

### resources
> https://firebase.google.com/docs/flutter/setup
> 
> https://firebase.flutter.dev/docs/overview/

### walk through

---

install firebase tools. do this in a command prompt (run as admin) and run the login in this same window as editors sometimes restrict running scripts. Anti-virus checkers may block this also, so add exceptions for 

`c:\users\user\.cache\firebase\tools\lib\node_modules` 

if needed and running on windows.

>```npm -g install firebase-tools```

>```firebase login```

Visit this URL on this device to log in: https://...
>```a url is shown on screen. copy this url. paste it into a browser, and then log into firebase on the web page with your google account.```

---

Install flutter fire. A tool to help configure flutter projects for firebase
>`npm -g install flutterfire`

Make sure the command line interface is installed

>```dart pub global activate flutterfire_cli```

Package flutterfire_cli is currently active at version 1.0.1.

Downloading packages... 

The package flutterfire_cli is already activated at newest available version.

To recompile executables, first run `dart pub global deactivate flutterfire_cli`.

Installed executable flutterfire.

Activated flutterfire_cli 1.0.1.

---

Now configure flutter for each type of application we are going to build.

>```flutterfire configure```

i Found 1 Firebase projects.

✔ Select a Firebase project to configure your Flutter application with · foodmanager-f117f (foodmanager)      

✔ Which platforms should your configuration support (use arrow keys & space to select)? · android, ios, macos, web, windows

i Firebase android app com.jbrun001.food_manager is not registered on Firebase project foodmanager-f117f.     

i Registered a new Firebase android app on Firebase project foodmanager-f117f.

i Firebase ios app com.example.foodManager is not registered on Firebase project foodmanager-f117f.

i Registered a new Firebase ios app on Firebase project foodmanager-f117f.

i Firebase macos app com.example.foodManager registered.

i Firebase web app food_manager (web) is not registered on Firebase project foodmanager-f117f.

i Registered a new Firebase web app on Firebase project foodmanager-f117f.

i Firebase windows app food_manager (windows) is not registered on Firebase project foodmanager-f117f.        

i Registered a new Firebase windows app on Firebase project foodmanager-f117f.

i Registered a new Firebase windows app on Firebase project foodmanager-f117f.

Firebase configuration file lib\firebase_options.dart generated successfully with the following Firebase apps:

| Step                              | iOS                                                       | Android                                                       | Web                                               |
|-----------------------------------|------------------------------------------------------------|----------------------------------------------------------------|---------------------------------------------------|
| Register App in Firebase Console, project overview project settings<br>Add App| `com.jbrun001.foodmanager`                  | `com.jbrun001.foodmanager`                  | No ID needed                                    |
| Download Config File shown on screen when added app            | `GoogleService-Info.plist`                              | `google-services.json`                                     | Not required                                    |
| Place Config in Project          | `ios/Runner/GoogleService-Info.plist`  | `android/app/google-services.json`                            | N/A                                               |
| Add Firebase SDK via CLI         | `% flutterfire configure --platforms=ios`                   | `flutterfire configure --platforms=android`                   | `% flutterfire configure --platforms=web`           |
| Generated Config File            | `lib/firebase_options.dart` (shared)                      | Same                                                          | Same                                              |
| Add dependencies to ./pubspec.yaml         | `  firebase_core: ^3.10.1`<br>`firebase_auth: ^5.5.0`<br>`cloud_firestore: ^5.5.1`<br>`firebase_storage: ^12.4.1` | Same                                                | Same                                              |
| Platform SDK Setup               | `% open ios/Runner.xcworkspace`<br>`% sudo gem install cocoapods`<br>`% cd ios`<br>`% pod install`<br>`% cd ..`<br>`open ios/podfile`<br>` add dependency`<br>`platform :ios, '13.0'`<br>`drag GoogleService-Info.plist into Xcode`<br> `Update /ios/Runner/Info.plist`<br>`Add`<br> `<key>NSAppTransportSecurity</key>`<br>`<dict>`<br>`<key>NSAllowsArbitraryLoads</key>`<br>` <true/>`<br>`</dict>`                  | `edit /android/build.gradle add:`<br>`buildscript {`<br><tab>`dependencies {`<br><tab><tab>`classpath 'com.google.gms:google-services:4.3.15'`<br><tab>`}`<br>`}`                                              |  Automatic via `flutterfire`                    |
| Run Platform-Specific Command    | `flutter run -d ios`                                       | `flutter run -d android`                                      | `flutter run -d chrome`                           |


---

Add the flutter firebase modules

> `flutter pub add firebase_core`

Re run flutterfire configure every time you make a change to the firebase (like adding a service or a platform)

> `flutterfire configure`

---

Create the database in firebase

> Log into firebase

> select foodmanager project

> Click Cloud Firestore (to create the database)

> Create database in the correct region

> For this project: europe-west2 (London)
