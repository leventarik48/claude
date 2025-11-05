# MysticFal - Quick Setup Guide

## Quick Start (5 Minutes)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment Variables
Edit the `.env` file and add your API keys:
```
OPENAI_API_KEY=sk-your-openai-api-key-here
REVENUECAT_API_KEY=your-revenuecat-key (optional for testing)
```

### 3. Firebase Setup

#### Option A: Quick Test Mode (Use Test Credentials)
For initial testing, you can use Firebase Test Project credentials. Create a test Firebase project and download:
- `google-services.json` → place in `android/app/`
- `GoogleService-Info.plist` → place in `ios/Runner/`

#### Option B: Production Setup
Follow the detailed Firebase setup in README.md

### 4. Run the App
```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios
```

## Testing Without API Keys

The app includes mock responses, so you can test the UI without configuring all APIs:

1. **Without OpenAI**: The AI service will return mock fortune readings
2. **Without RevenueCat**: Subscription UI will work but purchases won't process
3. **Without AdMob**: Ad system will show loading states

## Minimum Configuration for Testing

**Required:**
- Flutter SDK installed
- Firebase project (free tier is fine)
- `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)

**Optional for full functionality:**
- OpenAI API key (for real AI readings)
- RevenueCat account (for subscriptions)
- AdMob account (for ads)

## Common Issues

### 1. Firebase Not Connecting
```bash
# Verify files are in correct locations
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
```

### 2. Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### 3. iOS Pod Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

## Test Accounts

For testing authentication:
- **Email**: test@mysticfal.com
- **Password**: test123456

Or use Google/Apple Sign-In with your personal accounts.

## Feature Testing Checklist

- [ ] User Registration/Login
- [ ] Dashboard displays correctly
- [ ] Coffee Reading: Upload image (mock AI response if no API key)
- [ ] Horoscope: View daily horoscope
- [ ] Compatibility: Check zodiac compatibility
- [ ] Profile: View and edit user info
- [ ] Subscription: View subscription tiers
- [ ] Navigation: All bottom nav tabs work

## Next Steps

1. Test the app with mock data
2. Configure OpenAI API for real AI readings
3. Set up RevenueCat for production subscriptions
4. Configure AdMob for production ads
5. Customize theme colors and branding
6. Add custom fonts and animations
7. Test on real devices
8. Prepare for App Store/Play Store submission

## Development Tips

### Hot Reload
Press `r` in terminal for hot reload while developing

### Debug Mode
Use Flutter DevTools for debugging:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Check Flutter Doctor
```bash
flutter doctor -v
```

### Emulator Commands
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Support

If you encounter issues:
1. Check `flutter doctor` for environment issues
2. Review README.md for detailed setup
3. Verify all configuration files are in place
4. Check Firebase Console for service status

---

**Ready to Start?**
```bash
flutter pub get && flutter run
```

Happy coding! ✨🔮
