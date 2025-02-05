# firebase install

## resources
> https://firebase.google.com/docs/flutter/setup
> https://firebase.flutter.dev/docs/overview/

## walk through

---

install firebase tools. do this in a command prompt (run as admin) and run the login in this same window as editors sometimes restrict running scripts. Anti-virus checkers may block this also, so add exceptions for 

`c:\users\user\.cache\firebase\tools\lib\node_modules` 

if needed and running on windows.

>```npm -g install firebase-tools```

>```firebase login```

Visit this URL on this device to log in: https://...
>```a url is shown on screen. copy this url. paste it into a browser, and then log into firebase on the web page with your google account.```

Woohoo! you have connected to firebase

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

| Platform | Firebase | App Id |
| ---- | --- | --- |
| Android | | |
| iOS | | |

Learn more about using this file and next steps from the documentation:

---

Add the flutter firebase modules

> flutter pub add firebase_core

Re run flutterfire configure every time you make a change to the firebase (like adding a service or a platform)

> flutterfire configure

---

Create the database in firebase

> Log into firebase

> select foodmanager project

> Click Cloud Firestore (to create the database)

> Create database in the correct region

> For this project: europe-west2 (London)
