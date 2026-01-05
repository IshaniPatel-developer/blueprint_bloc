# Clean Architecture Flutter App - Setup Guide

## Overview
This is a production-ready Flutter application built with clean architecture principles, featuring:
- Firebase Authentication (email/password)
- Offline-first post creation with auto-sync
- Clean architecture (domain → data → presentation)
- State management with BLoC
- Routing with GoRouter and auth guard
- Local storage with Hive
- API integration with Dio

## Prerequisites
- Flutter SDK (3.9.0 or higher)
- Firebase CLI
- Dart SDK
- Android Studio / Xcode (for mobile development)

## Firebase Setup

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing one)
3. Enable **Email/Password** authentication:
   - Go to Authentication → Sign-in method
   - Enable Email/Password provider

### 2. Install Firebase CLI
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 3. Configure Firebase for Flutter
```bash
# In project root directory
flutterfire configure
```

This will:
- Create a Firebase project (if needed)
- Generate `firebase_options.dart`
- Add platform-specific config files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

## Project Structure

```
lib/
├── core/                      # Core utilities and infrastructure
│   ├── error/                 # Error handling (failures, exceptions)
│   ├── network/               # Network utilities
│   ├── router/                # GoRouter configuration
│   ├── services/              # Background services (sync)
│   └── usecases/              # Base usecase class
├── features/
│   ├── auth/                  # Authentication feature
│   │   ├── domain/            # Business logic layer
│   │   │   ├── entities/      # User entity
│   │   │   ├── repositories/  # Repository interface
│   │   │   └── usecases/      # Login, Signup, Logout, GetCurrentUser
│   │   ├── data/              # Data layer
│   │   │   ├── models/        # Data models with JSON serialization
│   │   │   ├── datasources/   # Firebase datasource
│   │   │   └── repositories/  # Repository implementation
│   │   └── presentation/      # UI layer
│   │       ├── bloc/          # BLoC state management
│   │       └── pages/         # Login, Signup pages
│   └── post/                  # Post feature
│       ├── domain/            # Business logic layer
│       │   ├── entities/      # Post entity with SyncStatus
│       │   ├── repositories/  # Repository interface
│       │   └── usecases/      # CreatePost, SyncPosts, GetLocalPosts
│       ├── data/              # Data layer
│       │   ├── models/        # PostModel with Hive adapter
│       │   ├── datasources/   # Remote (Dio) and Local (Hive)
│       │   └── repositories/  # Offline-first implementation
│       └── presentation/      # UI layer
│           ├── bloc/          # PostBloc
│           └── pages/         # Dashboard
├── injection_container.dart   # Dependency injection (GetIt)
└── main.dart                  # App entry point
```

## Running the App

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Adapters
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
```bash
# On connected device or emulator
flutter run

# For specific device
flutter run -d <device-id>
```

## Features Explained

### Authentication Flow
1. **App starts** → Check if user is logged in
2. **Not authenticated** → Redirect to login page
3. **Login/Signup** → Firebase Authentication
4. **Authenticated** → Navigate to dashboard
5. **Logout** → Sign out from Firebase, redirect to login

### Offline-First Post Creation
1. **User creates post** → Check network connectivity
2. **Online**:
   - Post to API (https://jsonplaceholder.typicode.com/posts)
   - Save to local storage with `synced` status
3. **Offline**:
   - Save to local storage with `pending` status
   - Show message: "Post saved offline"
4. **Internet restored** → Auto-sync service triggers
5. **Sync pending posts** → Upload to API, update status

### Auto-Sync Service
- Listens to connectivity changes using `connectivity_plus`
- When internet is restored:
  - Fetches all posts with `pending` status
  - Uploads each to the API
  - Updates local storage with `synced` status

### State Management
- **AuthBloc**: Manages authentication state
  - States: Initial, Loading, Authenticated, Unauthenticated, Error
  - Events: Login, Signup, Logout, CheckAuth

- **PostBloc**: Manages post state
  - States: Initial, Loading, Created, Loaded, Syncing, Synced, Error
  - Events: CreatePost, SyncPosts, LoadPosts

## Testing the App

### Test Authentication
1. **Sign up** with email/password
2. Verify user is created in Firebase Console
3. **Logout** and login again
4. Verify persistent authentication

### Test Offline-First
1. **Enable airplane mode** (or disable WiFi/data)
2. **Create a post** → Should show "saved offline"
3. **Check local storage** → Post should have `pending` status
4. **Re-enable internet** → Auto-sync should trigger
5. **Verify sync** → Post should show `synced` status

### Check API
- Posts are sent to: `https://jsonplaceholder.typicode.com/posts`
- This is a fake API, so posts won't persist on server
- But you can see the request/response in debug console

## Common Issues

### Firebase not initialized
**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**: Run `flutterfire configure` and restart app

### Build errors after adding dependencies
**Solution**: 
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Hive adapter not found
**Error**: `Cannot find type adapter for <PostModel>`

**Solution**: Make sure you've run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## API Reference

### JSONPlaceholder API
- **Endpoint**: `POST https://jsonplaceholder.typicode.com/posts`
- **Request Body**:
  ```json
  {
    "title": "Post title",
    "body": "Post content",
    "userId": "user123"
  }
  ```
- **Response**:
  ```json
  {
    "id": 101,
    "title": "Post title",
    "body": "Post content",
    "userId": "user123"
  }
  ```

## Next Steps

1. **Add tests**: Unit, widget, and integration tests
2. **Improve UI**: Better design, animations
3. **Add features**: Edit/delete posts, user profile
4. **Deploy**: Build release APK/IPA for production
5. **Analytics**: Add Firebase Analytics for tracking
6. **Crashlytics**: Add Firebase Crashlytics for error reporting

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
