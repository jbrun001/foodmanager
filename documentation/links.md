Links documentation

App: https://foodmanager-f117f.web.app/

Admin: https://foodmanager-admin-350470427377.europe-west2.run.app/

Firebase Data: https://console.firebase.google.com/project/foodmanager-f117f/firestore/databases/-default-/data/~2FUsers

Firebase Security: https://console.firebase.google.com/project/foodmanager-f117f/firestore/databases/-default-/rules

Firebase Functions: https://github.com/jbrun001/foodmanager/blob/main/lib/services/firebase_service.dart


Google oauth callbacks https://console.cloud.google.com/auth/clients/350470427377-vrs14ph85tncmknjvgmb6vofloemla5u.apps.googleusercontent.com?inv=1&invt=Abyh5A&project=foodmanager-f117f

App: 
- main & routes: https://github.com/jbrun001/foodmanager/blob/main/lib/main.dart

- Preview: loadCombinedStock, loadRecipes https://github.com/jbrun001/foodmanager/blob/main/lib/screens/previewleftovers_screen.dart  

- Smartlist loadSmartlist: https://github.com/jbrun001/foodmanager/blob/main/lib/services/smartlist_service.dart

- Drag and Drop DragTarget  https://github.com/jbrun001/foodmanager/blob/main/lib/screens/planner_screen.dart

- scaleIngredients :  https://github.com/jbrun001/foodmanager/blob/main/lib/screens/planner_screen.dart

- recipedetail widget: https://github.com/jbrun001/foodmanager/blob/main/lib/widgets/recipedetail.dart

- waste analysis: https://github.com/jbrun001/foodmanager/blob/main/lib/screens/wasteloganalysis_screen.dart
    - getWeeklyData, BarChartGroupData, buildPieChartSections
    - widget:  wastesummarycard https://github.com/jbrun001/foodmanager/blob/main/lib/widgets/wastesummary_card.dart

Login:
    - loginWithEmail, loginWithGoogle https://github.com/jbrun001/foodmanager/blob/main/lib/screens/login_screen.dart
    - Firebase_service signinwithEmail, signinwithgoogle https://github.com/jbrun001/foodmanager/blob/main/lib/services/firebase_service.dart 

Admin:

- index.js https://github.com/jbrun001/foodmanager_admin/blob/main/index.js

- scrapePackSizes https://github.com/jbrun001/foodmanager_admin/blob/main/helpers/scrapePackSize.js

- dockerfile https://github.com/jbrun001/foodmanager_admin/blob/main/dockerfile



Experiment

- food waste final jyptr notebook: https://github.com/jbrun001/foodmanager/blob/main/experiment/Food_Waste_Analysis_Final.ipynb

- baseline data from google forms: https://github.com/jbrun001/foodmanager/blob/main/experiment/Weekly%20Food%20Waste%20Input%20Form%20(Responses)%20-%20Form%20Responses.csv

- trial data downloaded from admin app: https://github.com/jbrun001/foodmanager/blob/main/experiment/weeklySummary.csv


Deployment

- flutter build web, firebase deploy https://github.com/jbrun001/foodmanager/blob/main/documentation/deployweb.md

- docker build / docker run & google cloud build: https://github.com/jbrun001/foodmanager_admin/blob/main/README.md
