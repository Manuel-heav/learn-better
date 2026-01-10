# Learn Better - AI Study Companion

A powerful AI-powered study companion app built with Flutter that helps students learn, understand, and retain knowledge more effectively.

## ✨ Features

- **AI Chat** - Ask questions and get intelligent explanations
- **Smart Notes** - Generate summaries and key concepts from your notes
- **Voice Recording** - Record explanations and get AI feedback with playback
- **Explain with Examples** - Get complex topics explained with real-world analogies
- **Quiz Mode** - AI-generated quizzes with instant feedback
- **Flashcards** - Spaced repetition learning with flip animations
- **Focus Mode** - Pomodoro timer with ambient sounds
- **Study Planner** - Track your study sessions and progress
- **Progress Tracking** - Monitor streaks, study time, and achievements
- **Customizable Settings** - AI persona, complexity level, themes

## 🔥 Firebase Integration

This app is fully integrated with Firebase for:
- **Authentication** (Email/Password, Google, Apple)
- **Cloud Firestore** (Real-time database)
- **Firebase Storage** (Audio recordings, PDFs)
- **User Profiles** with progress tracking

### Quick Setup

```bash
./firebase_quickstart.sh
```

For detailed setup instructions, see [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Firebase CLI
- Node.js (for Firebase CLI)
- Android Studio / Xcode

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd learn_better
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
```bash
./firebase_quickstart.sh
```

4. Run the app:
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/      # App colors and constants
│   ├── theme/          # Material 3 theme
│   ├── models/         # Data models (User, etc.)
│   ├── services/       # Firebase services
│   ├── providers/      # Riverpod state management
│   └── utils/          # Utilities and helpers
├── features/
│   ├── auth/           # Authentication screens
│   ├── onboarding/     # Splash & onboarding
│   ├── home/           # Dashboard
│   ├── chat/           # AI Chat
│   ├── notes/          # Smart Notes
│   ├── voice_record/   # Voice Recording
│   ├── explain/        # Explain with Examples
│   ├── quiz/           # Quiz Mode
│   ├── flashcards/     # Flashcard System
│   ├── focus/          # Focus Mode (Pomodoro)
│   ├── planner/        # Study Planner
│   └── settings/       # App Settings
└── main.dart           # App entry point
```

## 🎨 Design System

- **Primary Color**: Deep Blue (#2D3FE7)
- **Accent Colors**: Purple, Teal
- **Typography**: Inter (Google Fonts)
- **UI Style**: Material 3, Modern, Clean

## 🔧 Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Authentication**: Firebase Auth + Google Sign-In
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Audio**: audioplayers package

## 📚 Documentation

- [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) - Complete Firebase setup guide
- [`BACKEND_INTEGRATION_SUMMARY.md`](BACKEND_INTEGRATION_SUMMARY.md) - Backend architecture overview

## 🎯 Roadmap

- [ ] OpenAI/Gemini AI integration
- [ ] Speech-to-Text for voice recordings
- [ ] PDF text extraction
- [ ] Push notifications
- [ ] Analytics dashboard
- [ ] Premium subscription (Stripe)
- [ ] Social features (study groups)
- [ ] Offline mode

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Built with ❤️ using Flutter

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
