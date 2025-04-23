
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

# prereq

- Flutter SDK (`flutter doctor` clean)
- Dart SDK
- Xcode (iOS)
- Android Studio (Android SDK + Emulator)
- Chrome (Web)
- Firebase CLI: `brew install firebase-cli`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

