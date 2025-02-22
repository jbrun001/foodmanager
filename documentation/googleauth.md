# notes

created keystore foodmanager.jks
```
cd android
keytool -genkeypair -v -keystore app/foodmanager.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias mykey
``

got keys using
```
keytool -list -v -keystore app/foodmanager.jks
```

put keys in 
> https://console.firebase.google.com/project/foodmanager-f117f/settings/general/android:com.jbrun001.food_manager

scroll down, put against food_manager (android)

downloaded google_services.json

placed in /android/app/google_services.json