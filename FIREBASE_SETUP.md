# Firebase Setup Guide for Learn Better

This guide will help you set up Firebase for your Learn Better app with full authentication, database, and storage capabilities.

## 📋 Prerequisites

- Flutter SDK installed
- Node.js and npm installed (for Firebase CLI)
- A Google account

---

## 🔥 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `learn-better-app` (or your choice)
4. Disable Google Analytics (optional for development)
5. Click "Create Project"

---

## 🛠️ Step 2: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

---

## ⚙️ Step 3: Configure Firebase for Flutter

Run this command in your project directory:

```bash
cd /Users/amanuael/Desktop/learn_better
flutterfire configure
```

This will:
- Create Firebase apps for iOS, Android, Web, macOS
- Generate `firebase_options.dart` with your configuration
- Update `lib/core/utils/firebase_options.dart` automatically

**Select these platforms when prompted:**
- ✅ Android
- ✅ iOS  
- ✅ macOS
- ✅ Web

---

## 🔐 Step 4: Enable Authentication Methods

### In Firebase Console:

1. Go to **Authentication** → **Get Started**
2. Click **Sign-in method** tab
3. Enable these providers:

#### Email/Password:
- Click **Email/Password**
- Toggle **Enable**
- Click **Save**

#### Google Sign-In:
- Click **Google**
- Toggle **Enable**
- Enter project support email
- Click **Save**

#### Apple Sign-In (iOS only):
- Click **Apple**
- Toggle **Enable**
- Follow Apple setup instructions
- Click **Save**

---

## 💾 Step 5: Set Up Firestore Database

1. Go to **Firestore Database** → **Create Database**
2. Choose **Start in production mode**
3. Select **Cloud Firestore location**: (choose closest to you)
4. Click **Enable**

### Update Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User document rules
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
      
      // User subcollections (notes, flashcards, etc.)
      match /{subcollection}/{document} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 📦 Step 6: Set Up Firebase Storage

1. Go to **Storage** → **Get Started**
2. Choose **Start in production mode**
3. Select same location as Firestore
4. Click **Done**

### Update Storage Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User recordings
    match /recordings/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User PDFs
    match /pdfs/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📱 Step 7: Configure Android

### Update `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // ... existing config
        minSdkVersion 21  // Firebase requires minimum 21
        multiDexEnabled true
    }
}

dependencies {
    // ... existing dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

### For Google Sign-In on Android:

1. In Firebase Console: **Project Settings** → **General**
2. Scroll to **Your apps** → **Android app**
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`
5. Get SHA-1 fingerprint:

```bash
cd android
./gradlew signingReport
```

6. Copy SHA-1 from output
7. In Firebase Console → **Project Settings** → Add SHA-1

---

## 🍎 Step 8: Configure iOS

### Update `ios/Podfile`:

```ruby
platform :ios, '13.0'  # Firebase requires iOS 13+
```

### For Google Sign-In on iOS:

1. In Firebase Console: **Project Settings** → **General**
2. Scroll to **Your apps** → **iOS app**
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into **Runner** folder
6. In Xcode, select **Runner** → **Info** → **URL Types**
7. Add URL scheme: Your **REVERSED_CLIENT_ID** from the plist file

### For Apple Sign-In:

1. Open Xcode → Select your project
2. Go to **Signing & Capabilities**
3. Click **+ Capability** → Add **Sign in with Apple**

---

## 🌐 Step 9: Configure Web

The FlutterFire CLI should have already configured this, but verify:

1. Check `web/index.html` has Firebase SDK scripts
2. Firebase config should be in `firebase_options.dart`

---

## 🧪 Step 10: Test Installation

```bash
cd /Users/amanuael/Desktop/learn_better
flutter pub get
flutter run
```

### Test Flow:

1. **Sign Up**: Create a new account with email/password
2. **Check Firestore**: Go to Firebase Console → Firestore → You should see a new user document
3. **Sign Out & Sign In**: Test login functionality
4. **Google Sign-In**: Try signing in with Google
5. **Check Authentication**: Firebase Console → Authentication → Users should be listed

---

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] FlutterFire CLI configured
- [ ] Email/Password auth enabled
- [ ] Google Sign-In enabled
- [ ] Apple Sign-In enabled (iOS)
- [ ] Firestore database created with rules
- [ ] Firebase Storage set up with rules
- [ ] Android configured (google-services.json + SHA-1)
- [ ] iOS configured (GoogleService-Info.plist)
- [ ] App builds successfully
- [ ] Sign up creates user in Firestore
- [ ] Sign in works
- [ ] Google Sign-In works

---

## 🐛 Troubleshooting

### "Firebase not initialized" error:
- Make sure you ran `flutterfire configure`
- Check `firebase_options.dart` exists
- Verify Firebase.initializeApp() is called in main.dart

### Google Sign-In not working on Android:
- Check SHA-1 fingerprint is added to Firebase Console
- Verify `google-services.json` is in `android/app/`
- Run `flutter clean` and rebuild

### iOS build errors:
- Run `cd ios && pod install`
- Check minimum iOS version is 13.0+
- Verify `GoogleService-Info.plist` is added to Xcode project

### Firestore permission denied:
- Check security rules allow authenticated users
- Verify user is signed in before accessing Firestore
- Check user UID matches document path

---

## 🎯 What's Already Implemented

### ✅ Services:
- `AuthService` - Email, Google, Apple sign-in
- `FirestoreService` - Database operations
- `StorageService` - File uploads
- `UserModel` - User data structure

### ✅ State Management:
- Riverpod providers for authentication
- Loading states
- Error handling
- Auto user sync

### ✅ UI:
- Login screen with Firebase integration
- Signup screen with Firebase integration
- Loading indicators
- Error messages
- Social login buttons (Google, Apple)

---

## 🚀 Next Steps After Setup

1. **Test all auth methods**
2. **Integrate AI API** (OpenAI/Gemini) for chat features
3. **Add Speech-to-Text** for voice recordings
4. **Implement data persistence** for notes, flashcards, etc.
5. **Add analytics** (Firebase Analytics or Mixpanel)
6. **Set up push notifications** (Firebase Cloud Messaging)

---

## 📝 Environment Variables (Optional)

For additional security, you can use environment variables for API keys:

Create `.env` file:
```env
OPENAI_API_KEY=your_openai_key_here
GEMINI_API_KEY=your_gemini_key_here
```

Add to `.gitignore`:
```
.env
firebase_options.dart
google-services.json
GoogleService-Info.plist
```

---

## 🔒 Security Best Practices

1. **Never commit API keys** to version control
2. **Use Firestore security rules** to protect user data
3. **Validate input** on both client and server
4. **Enable Firebase App Check** for production
5. **Set up rate limiting** to prevent abuse
6. **Use HTTPS only** for API calls
7. **Implement proper error handling**

---

## 📚 Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Google Sign-In Setup](https://pub.dev/packages/google_sign_in)

---

## 💡 Pro Tips

- Use **Firebase Emulator** for local development
- Set up **multiple environments** (dev, staging, prod)
- Enable **Firebase Analytics** to track user behavior
- Use **Firebase Crashlytics** for crash reporting
- Implement **Firebase Remote Config** for feature flags
- Set up **Cloud Functions** for backend logic

---

**Your app is now ready for Firebase integration!** 🎉

After completing these steps, your authentication will be fully functional with real user accounts, cloud database, and file storage!

