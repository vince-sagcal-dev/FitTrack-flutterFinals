<<<<<<< HEAD
# FitTracker — Food Calorie Tracker

FitTracker is a Flutter calorie-tracking app with Firebase Authentication,
per-user Firestore food diaries, Firebase Storage food photos, and Gemini food
photo analysis through Firebase AI Logic. AI nutrition values are estimates;
users can review and edit them before saving.

## Features

- Email/password registration and sign-in, password reset, and password change
- Daily calorie goal and live calorie/macronutrient totals
- Manual food entry, photo-based AI estimate, food history, edit, and delete
- User profile and calorie-goal settings
- Firebase security rules scoped to the signed-in user

## Firebase setup

This project currently uses the Firebase project configured in
`lib/firebase_options.dart` and `android/app/google-services.json`.

1. In Firebase Console, enable **Authentication → Email/Password**.
2. Create a **Cloud Firestore** database and a **Storage** bucket.
3. Configure the AI provider in Firebase Console for project `fittrack-454a8`:
   open **AI services → AI Logic**, click **Get started**, and select
   **Gemini Developer API**. This creates the provider configuration required
   by `FirebaseAI.googleAI()` in `lib/services/ai_food_service.dart`; enable
   the Firebase AI Logic API if prompted. Wait a few minutes after setup before
   retrying photo analysis. The app requests `gemini-3.8-flash`; review model
   availability and billing settings for your project.
4. For Windows debug runs, register an App Check debug token in Firebase
   Console under **Security → App Check → Apps → Manage debug tokens** for the
   Web app ID used by `DefaultFirebaseOptions.windows`
   (`1:957974136764:web:24a4ee8c0d7752809d8db9`). Generate a UUID with
   `[guid]::NewGuid().ToString()`, register it there, and pass that exact token
   when launching:

   ```powershell
   flutter run -d windows --dart-define=APP_CHECK_DEBUG_TOKEN=YOUR_REGISTERED_TOKEN
   ```

   In the Apps table, use **Manage debug tokens** on the
   `food_calorie_tracker (windows)` row. The row can still say **Not registered**:
   that status is for production attestation providers. Do not click **Register**
   for this debug-only setup. Close any running app before launching the command
   so it starts with the token.

   Windows supports only the App Check debug provider in this setup. Use this
   only for local development; never ship the debug token or debug provider.
5. Install the Firebase CLI, sign in, and select the intended Firebase project.
   Deploy the included owner-only rules:

   ```sh
   firebase deploy --only firestore:rules,storage
   ```

6. To use another Firebase project, re-run FlutterFire configuration and
   replace the Android `google-services.json` with that project's config.

## Run

```sh
flutter pub get
flutter run
```

The app supports Android and the configured FlutterFire web, iOS, macOS, and
Windows targets. Linux Firebase options are not configured in
`lib/firebase_options.dart`.

On Windows, connect a camera and allow desktop apps to access it in Windows
**Settings → Privacy & security → Camera**. The gallery picker remains
available when no camera is connected. Fully stop any existing Windows app
process before `flutter run -d windows` so native camera plugin changes are
rebuilt and registered.
=======
# FitTrack-flutterFinals
>>>>>>> b164cc7f6aef9ed7848ae8a8ed2d884cdff419a1
