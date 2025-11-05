# MysticFal - Fortune Telling App

A comprehensive Flutter mobile application for fortune telling services, featuring Turkish coffee reading (kahve falı), astrology, daily horoscopes, and relationship compatibility analysis. Built with Firebase backend and AI-powered interpretations.

## Features

### Core Functionality
- **Turkish Coffee Reading (Kahve Falı)**: Upload coffee cup photos for AI-powered mystical interpretations
- **Daily Horoscopes**: Personalized horoscope readings for all 12 zodiac signs
- **Relationship Compatibility**: Analyze zodiac sign compatibility with detailed insights
- **Birth Chart Analysis**: Comprehensive astrological birth chart readings
- **User Profiles**: Manage personal information, birth details, and preferences

### Tiered Subscription System
- **Free Tier**:
  - 1 free reading per day (unlocked via rewarded video ads)
  - Basic AI interpretations (GPT-3.5-turbo)
  - Standard features

- **Gold Tier** ($9.99/month):
  - Unlimited readings without ads
  - Advanced AI interpretations (GPT-4)
  - Detailed, personalized content
  - Reading history export
  - Priority support

- **Premium Tier** ($19.99/month):
  - Everything in Gold
  - Ultra-personalized AI (GPT-4.5 or latest)
  - Text-to-speech voice readings
  - Multiple voice accents
  - Custom AI prompts
  - Early access to new features
  - VIP support

### Technical Features
- **Firebase Integration**: Authentication, Firestore database, Cloud Storage
- **Multiple Auth Methods**: Email/password, Google Sign-In, Apple Sign-In
- **AI Integration**: OpenAI GPT models with tier-based selection
- **Monetization**: RevenueCat for subscriptions, Google Mobile Ads for rewarded videos
- **Offline Support**: Hive local storage for caching
- **Responsive UI**: Dark theme with mystical design, animations, and gradients

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / Xcode for mobile development
- Firebase CLI
- Git

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd mysticfal
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### a. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "MysticFal"
3. Enable the following services:
   - **Authentication**: Email/Password, Google, Apple
   - **Cloud Firestore**: Create database in production mode
   - **Cloud Storage**: Enable storage bucket
   - **Firebase Messaging**: For push notifications

#### b. Configure Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. Update `android/build.gradle` and `android/app/build.gradle` with Firebase dependencies (if not already done)

#### c. Configure iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` in Xcode
3. Update `ios/Podfile` with Firebase pods (if not already done)
4. Run `cd ios && pod install`

### 4. OpenAI API Setup
1. Get an API key from [OpenAI Platform](https://platform.openai.com/)
2. Update `.env` file:
   ```
   OPENAI_API_KEY=your_actual_api_key_here
   ```

### 5. RevenueCat Setup (Subscriptions)
1. Create an account at [RevenueCat](https://www.revenuecat.com/)
2. Create a new app and configure products:
   - `gold_monthly` - Gold Monthly Subscription
   - `gold_yearly` - Gold Yearly Subscription
   - `premium_monthly` - Premium Monthly Subscription
   - `premium_yearly` - Premium Yearly Subscription
3. Update `lib/services/subscription_service.dart` with your API key:
   ```dart
   static const String _apiKey = 'your_revenuecat_api_key';
   ```

### 6. Google AdMob Setup
1. Create an account at [Google AdMob](https://admob.google.com/)
2. Create an app and generate ad unit IDs
3. Update `lib/services/ads_service.dart` with your ad unit IDs (replace test IDs)
4. For Android: Add AdMob App ID to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
   ```
5. For iOS: Add AdMob App ID to `ios/Runner/Info.plist`:
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
   ```

### 7. Apple Sign-In Setup (iOS only)
1. In Xcode, enable "Sign in with Apple" capability
2. Configure in Firebase Console under Authentication > Sign-in method

### 8. Firebase Firestore Rules
Set up security rules in Firestore:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /coffeeReadings/{readingId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
    }
    match /horoscopes/{horoscopeId} {
      allow read: if request.auth != null;
      allow write: if false; // Only backend should write
    }
    match /compatibilities/{compatibilityId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### 9. Firebase Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /coffee_readings/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Running the App

### Development Mode
```bash
# Run on Android
flutter run

# Run on iOS
flutter run

# Run with specific device
flutter run -d <device_id>
```

### Build for Production

#### Android (APK)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android (App Bundle for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (for App Store)
```bash
flutter build ios --release
# Then open Xcode and archive for distribution
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── coffee_reading_model.dart
│   ├── horoscope_model.dart
│   └── compatibility_model.dart
├── providers/                # State management
│   └── user_provider.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   ├── ai_service.dart
│   ├── ads_service.dart
│   └── subscription_service.dart
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── home/                # Dashboard and navigation
│   ├── features/            # Feature screens
│   ├── profile/             # Profile management
│   └── subscription/        # Subscription management
├── utils/                    # Utilities and constants
│   └── constants.dart
└── widgets/                  # Reusable widgets
```

## Configuration Files

- `.env`: Environment variables (API keys)
- `pubspec.yaml`: Dependencies and assets
- `android/app/build.gradle`: Android configuration
- `ios/Runner/Info.plist`: iOS configuration

## Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## Known Issues & Limitations

1. **OpenAI API**: Requires valid API key and sufficient credits
2. **Image Analysis**: Currently uses text descriptions; full vision API integration requires GPT-4 Vision
3. **RevenueCat**: Needs production configuration for actual subscriptions
4. **AdMob**: Test IDs included; replace with production IDs
5. **Fonts**: Custom mystical fonts referenced but not included; use Google Fonts as alternative

## Deployment Checklist

### Before Publishing
- [ ] Replace all test API keys with production keys
- [ ] Configure proper Firebase security rules
- [ ] Set up proper AdMob ad units
- [ ] Configure RevenueCat products
- [ ] Test in-app purchases in sandbox
- [ ] Add privacy policy and terms of service
- [ ] Test on multiple devices (Android & iOS)
- [ ] Optimize images and assets
- [ ] Enable ProGuard (Android) / obfuscation (iOS)
- [ ] Set up proper error tracking (Firebase Crashlytics)
- [ ] Configure app signing (Android keystore, iOS certificates)

### App Store Requirements
- **iOS**: App Store Connect account, proper provisioning profiles
- **Android**: Google Play Console account, signed APK/AAB

## Troubleshooting

### Firebase Connection Issues
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is correctly placed
- Ensure package name matches Firebase configuration
- Run `flutter clean` and rebuild

### OpenAI API Errors
- Check API key validity and credits
- Verify network connectivity
- Check rate limits

### Build Errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

## Support & Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [AdMob Documentation](https://developers.google.com/admob)

## License

This project is proprietary software. All rights reserved.

## Contributors

Built with Flutter and powered by AI for mystical insights.

---

**Note**: This is a production-ready template. Ensure all API keys, credentials, and sensitive information are properly secured and never committed to version control. Update `.gitignore` to exclude `.env`, `google-services.json`, and `GoogleService-Info.plist`.
