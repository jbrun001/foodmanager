
```
jakemacmini@JMM foodmanager % firebase --version
14.2.0
jakemacmini@JMM foodmanager % firebase login
i  Firebase optionally collects CLI and Emulator Suite usage and error reporting information to help improve our products. Data is collected in accordance with Google's privacy policy (https://policies.google.com/privacy) and is not used to identify you.

? Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? No

Waiting for authentication...

✔  Success! Logged in as jake.brunnen@gmail.com
jakemacmini@JMM foodmanager % firebase use --add
? Which project do you want to add? foodmanager-f117f
? What alias do you want to use for this project? (e.g. staging) trial

Created alias trial for foodmanager-f117f.
Now using alias trial (foodmanager-f117f)
jakemacmini@JMM foodmanager % firebase use trial

Now using alias trial (foodmanager-f117f)
jakemacmini@JMM foodmanager % firebase deploy

=== Deploying to 'foodmanager-f117f'...

i  deploying hosting
i  hosting[foodmanager-f117f]: beginning deploy...
i  hosting[foodmanager-f117f]: found 52 files in build/web
✔  hosting[foodmanager-f117f]: file upload complete
i  hosting[foodmanager-f117f]: finalizing version...
✔  hosting[foodmanager-f117f]: version finalized
i  hosting[foodmanager-f117f]: releasing new version...
✔  hosting[foodmanager-f117f]: release complete

✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/foodmanager-f117f/overview
Hosting URL: https://foodmanager-f117f.web.app

```