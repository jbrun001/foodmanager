es-Mac-mini foodmanager % npm install -g firebase-tools

npm error code EACCES
npm error syscall mkdir
npm error path /usr/local/lib/node_modules/firebase-tools
npm error errno -13
npm error Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/firebase-tools'
npm error     at async mkdir (node:internal/fs/promises:858:10)
npm error     at async /usr/local/lib/node_modules/npm/node_modules/@npmcli/arborist/lib/arborist/reify.js:624:20
npm error     at async Promise.allSettled (index 0)
npm error     at async [reifyPackages] (/usr/local/lib/node_modules/npm/node_modules/@npmcli/arborist/lib/arborist/reify.js:325:11)
npm error     at async Arborist.reify (/usr/local/lib/node_modules/npm/node_modules/@npmcli/arborist/lib/arborist/reify.js:142:5)
npm error     at async Install.exec (/usr/local/lib/node_modules/npm/lib/commands/install.js:150:5)
npm error     at async Npm.exec (/usr/local/lib/node_modules/npm/lib/npm.js:207:9)
npm error     at async module.exports (/usr/local/lib/node_modules/npm/lib/cli/entry.js:74:5) {
npm error   errno: -13,
npm error   code: 'EACCES',
npm error   syscall: 'mkdir',
npm error   path: '/usr/local/lib/node_modules/firebase-tools'
npm error }
npm error
npm error The operation was rejected by your operating system.
npm error It is likely you do not have the permissions to access this file as the current user
npm error
npm error If you believe this might be a permissions issue, please double-check the
npm error permissions of the file and its containing directories, or try running
npm error the command again as root/Administrator.
npm error A complete log of this run can be found in: /Users/jakemacmini/.npm/_logs/2025-04-18T16_16_46_113Z-debug-0.log
jakemacmini@Jakes-Mac-mini foodmanager % sudo npm install -g firebase-tools

Password:

added 630 packages in 4s

70 packages are looking for funding
  run `npm fund` for details
jakemacmini@Jakes-Mac-mini foodmanager % firebase -version     
error: unknown option '-version'
jakemacmini@Jakes-Mac-mini foodmanager % firebase --version
14.2.0
jakemacmini@Jakes-Mac-mini foodmanager % firebase login
i  Firebase optionally collects CLI and Emulator Suite usage and error reporting information to help improve our products. Data is collected in accordance with Google's privacy policy (https://policies.google.com/privacy) and is not used to identify you.

? Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? No

Visit this URL on this device to log in:
https://accounts.google.com/o/oauth2/auth?client_id=563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com&scope=email%20openid%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloudplatformprojects.readonly%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffirebase%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform&response_type=code&state=552141729&redirect_uri=http%3A%2F%2Flocalhost%3A9005

Waiting for authentication...

✔  Success! Logged in as jake.brunnen@gmail.com
jakemacmini@Jakes-Mac-mini foodmanager % firebase use --add
? Which project do you want to add? foodmanager-f117f
? What alias do you want to use for this project? (e.g. staging) trial

Created alias trial for foodmanager-f117f.
Now using alias trial (foodmanager-f117f)
jakemacmini@Jakes-Mac-mini foodmanager % firebase use trial

Now using alias trial (foodmanager-f117f)
jakemacmini@Jakes-Mac-mini foodmanager % firebase deploy

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

https://foodmanager-f117f.web.app/assets/images/recipes/1json.png