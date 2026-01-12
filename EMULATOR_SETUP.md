# 🚀 Emulator-Only Setup Guide

**Quick setup for testing Learn Better on Android Emulator only**

---

## ✅ What You've Already Done

1. ✅ Installed FlutterFire CLI
2. ✅ Configured Firebase for Android
3. ✅ Generated `firebase_options.dart`

---

## 📋 What You Need To Do Now

### 1️⃣ In Firebase Console (https://console.firebase.google.com)

Open your **learn-better-c19b4** project:

#### A. Enable Authentication
1. Click **"Authentication"** in the left sidebar
2. Click **"Get started"**
3. Click the **"Sign-in method"** tab
4. Enable **"Email/Password"**:
   - Click on "Email/Password"
   - Toggle the first switch ON
   - Click "Save"

**That's it for auth!** Skip Google Sign-in (requires SHA-1 keys)

#### B. Create Firestore Database
1. Click **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. Choose **"Start in test mode"** (allows all reads/writes for 30 days)
4. Choose any location (closest to you)
5. Click **"Enable"**

**Done!** You now have a database.

#### C. Skip Storage
- ❌ Don't set up Storage (requires billing)
- Voice recording feature will work locally without cloud storage

---

### 2️⃣ Install Dependencies

```bash
cd /Users/amanuael/Desktop/learn_better
flutter pub get
```

---

### 3️⃣ Run the App

```bash
flutter run
```

That's it! 🎉

---

## 🧪 What Works in Emulator

✅ **Authentication**
- Email/Password signup and login
- User sessions persist

✅ **Firestore**
- User data saved to cloud
- Progress tracking works

✅ **All Features**
- AI Chat (demo mode)
- Smart Notes
- Quiz Generator
- Flashcards
- Study Planner
- Voice Recording (local only)
- Focus Mode

---

## ❌ What Doesn't Work (And That's OK)

- ❌ Google Sign-in (needs SHA-1 configuration)
- ❌ Apple Sign-in (needs Apple Developer account)
- ❌ Voice recording cloud backup (needs Storage/billing)

For emulator testing, you don't need any of these!

---

## 🐛 Troubleshooting

### Problem: "No Firebase App has been created"
**Solution:** Make sure `firebase_options.dart` exists in `lib/`

### Problem: "Permission denied" in Firestore
**Solution:** Make sure you selected "Start in test mode" when creating the database

### Problem: Build errors
**Solution:** Run `flutter clean && flutter pub get`

---

## 📱 Test Flow

1. Launch app on emulator
2. Skip onboarding
3. Click "Sign Up"
4. Create account with email/password
5. Login successful → You're on the dashboard! 🎉

---

That's it! You now have a fully functional app running on your emulator with real Firebase authentication and database. 🔥

