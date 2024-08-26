# faker-jobs-app

## Project Setup

To clone the repo for the first time and open it in VSCode, run this:

```
git clone https://github.com/alona-gre/faker-jobs-app
cd faker-jobs-app
code .
```

### Firebase Setup

Since the project uses Firebase, some additional files will be needed:

```
lib/firebase_options.dart
ios/Runner/GoogleService-Info.plist
ios/firebase_app_id_file.json
macos/Runner/GoogleService-Info.plist
macos/firebase_app_id_file.json
android/app/google-services.json
```

These files have been added to `.gitignore`, so you need to run this command to generate them with the flutterfire CLI:

```
cd faker-jobs-app
flutterfire configure
```