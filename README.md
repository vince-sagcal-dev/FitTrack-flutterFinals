# FitTracker — Food Calorie Tracker

FitTracker is a Flutter calorie-tracking app with Firebase Authentication and
per-user Firestore food diaries. Users enter meal calories and macros manually
and can review their daily intake against a personalized calorie goal.

## Features

- Email/password registration and sign-in, password reset, and password change
- Google sign-in on web, Android, iOS, and macOS (email sign-in remains available)
- Age, sex, height, weight, body-fat, and activity-based maintenance/bulk/cut estimates
- Daily calorie goal and live calorie/macronutrient intake tracking
- Manual food entry, food history, edit, and delete
- User profile and calorie-goal settings
- Firebase security rules scoped to the signed-in user

## Firebase setup

This project currently uses the Firebase project configured in
`lib/firebase_options.dart` and `android/app/google-services.json`.

1. In Firebase Console, enable **Authentication → Email/Password**.
2. To enable Google sign-in, also enable **Authentication → Google** and
   configure the Google Sign-In client for each supported platform. In Firebase
   project settings, add the Android app's debug and release SHA-1 fingerprints
   (and SHA-256 fingerprints if available), then download the refreshed
   `google-services.json` into `android/app/`. It must include the Web OAuth
   client entry (`client_type: 3`); Android reads that as its server client ID.
   A canceled error after choosing an account can indicate a missing or
   mismatched SHA fingerprint or Android package name. For iOS, keep
   `GoogleService-Info.plist` in `ios/Runner/`; its reversed client ID is
   configured as a URL scheme in `ios/Runner/Info.plist`. Follow the platform
   setup in the [google_sign_in package
   guide](https://pub.dev/packages/google_sign_in#platform-integration). The
   Windows desktop Firebase Auth plugin does not support Google provider
   sign-in, so Windows continues to use email/password sign-in.
3. Create a **Cloud Firestore** database.
4. Install the Firebase CLI, sign in, and select the intended Firebase project.
   Deploy the included owner-only rules:

   ```sh
   firebase deploy --only firestore:rules
   ```

5. To use another Firebase project, re-run FlutterFire configuration and
   replace the Android `google-services.json` with that project's config.

## Run

```sh
flutter pub get
flutter run
```

The app supports Android and the configured FlutterFire web, iOS, macOS, and
Windows targets. Linux Firebase options are not configured in
`lib/firebase_options.dart`.

Calorie estimates use the Mifflin–St Jeor equation unless body-fat percentage
is provided, in which case a lean-mass estimate is used. Maintenance, bulking,
and cutting targets are estimates, not medical advice. References:
[Mifflin et al. (1990)](https://doi.org/10.1093/ajcn/51.2.241) and the
[NIH/NIDDK Body Weight Planner](https://www.niddk.nih.gov/bwp).
