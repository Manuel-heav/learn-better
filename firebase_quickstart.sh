#!/bin/bash

# Learn Better - Firebase Quick Start Script
# This script helps you set up Firebase quickly

echo "🔥 Learn Better - Firebase Setup Script"
echo "========================================"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI not found"
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
else
    echo "✅ Firebase CLI is installed"
fi

echo ""

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null
then
    echo "❌ FlutterFire CLI not found"
    echo "📦 Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
else
    echo "✅ FlutterFire CLI is installed"
fi

echo ""
echo "🔐 Logging into Firebase..."
firebase login

echo ""
echo "⚙️  Configuring Firebase for Flutter..."
echo "Select your Firebase project when prompted"
echo "Enable: Android, iOS, macOS, Web"
echo ""
read -p "Press Enter to continue..."

flutterfire configure

echo ""
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📚 Next Steps:"
echo "1. Go to Firebase Console: https://console.firebase.google.com"
echo "2. Enable Authentication methods (Email, Google, Apple)"
echo "3. Create Firestore Database"
echo "4. Set up Firebase Storage"
echo "5. Update security rules (see FIREBASE_SETUP.md)"
echo ""
echo "Run 'flutter run' to test your app!"
echo ""



