# iOS Setup Guide for Padel Bud

## Overview
Your Flutter app is now configured to work on iOS. All necessary permissions and Firebase configuration have been added.

## What Was Done

### 1. Updated Info.plist (ios/Runner/Info.plist)
Added required iOS permissions for:
- **Location**: NSLocationWhenInUseUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription
- **Camera**: NSCameraUsageDescription
- **Photo Library**: NSPhotoLibraryUsageDescription, NSPhotoLibraryAddOnlyUsageDescription

These permissions are required by the following dependencies:
- `geolocator` - for location services
- `image_picker` - for camera and photo library access
- `google_maps_flutter` - for maps functionality

### 2. Firebase Configuration
Firebase is already configured for iOS with:
- API Key: AIzaSyBmTeuq-ibNZ8BBCeCurmJSU7jSx7ak1hA
- App ID: 1:92444002158:ios:c59d9b4c1471b85bff637f
- Bundle ID: com.buddies.padelBud
- iOS Client ID configured for Google Sign-In

### 3. App Configuration
The app is already set up with:
- AppDelegate.swift with proper Flutter integration
- Assets configured in pubspec.yaml
- All dependencies support iOS (Flutter Riverpod, Firebase, image_picker, geolocator, etc.)

## Building for iOS

### Prerequisites
- Xcode 14.0 or later
- iOS deployment target: 11.0 or later
- CocoaPods package manager

### Build Steps

1. **Clean build cache** (recommended first time):
   ```bash
   flutter clean
   ```

2. **Get Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Build for iOS**:
   ```bash
   flutter build ios
   ```

4. **Or run directly on simulator**:
   ```bash
   flutter run -d <device_id>
   ```
   To list available devices:
   ```bash
   flutter devices
   ```

### Building and Publishing to App Store

1. **Create an App Store Connect listing** at developer.apple.com
2. **Configure signing in Xcode**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner target
   - Go to Signing & Capabilities
   - Select your team and manage certificates

3. **Archive for submission**:
   ```bash
   flutter build ios --release
   ```

4. **Upload via Xcode or Transporter**

## Troubleshooting

### Pod Installation Issues
If you encounter CocoaPods errors:
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

### Location Services Not Working
- Ensure NSLocationWhenInUseUsageDescription is in Info.plist (already added)
- User must grant permission in app settings
- Location services must be enabled on the device

### Camera/Photo Library Issues
- Check NSCameraUsageDescription is present (already added)
- Check NSPhotoLibraryUsageDescription is present (already added)
- Ensure permissions are requested at runtime in your Dart code

### Firebase Authentication Issues
- Verify the Bundle ID matches your Firebase project: com.buddies.padelBud
- Check that Google Sign-In iOS client ID is correct in Firebase console
- Add signing certificates to your Firebase project

### Maps Not Loading
- Ensure Google Maps API key is configured for iOS
- Add the key to Info.plist if needed (may require additional setup in Firebase console)

## Testing on Device

To test on a physical iPhone/iPad:

1. Connect device via USB
2. Trust the computer on the device
3. Run:
   ```bash
   flutter run -d <device_name>
   ```

## Platform-Specific Code (if needed in future)

Currently all code is platform-agnostic, but if you need platform-specific code:

```dart
import 'dart:io' show Platform;

if (Platform.isIOS) {
  // iOS-specific code
} else if (Platform.isAndroid) {
  // Android-specific code
}
```

## Dependencies Status for iOS

All current dependencies have iOS support:
- ✅ flutter, flutter_localizations
- ✅ geolocator (includes iOS location services)
- ✅ cupertino_icons
- ✅ cloud_firestore
- ✅ firebase_auth
- ✅ flutter_riverpod
- ✅ uuid
- ✅ google_sign_in (iOS configured)
- ✅ intl
- ✅ sign_in_button
- ✅ image_picker (iOS configured)
- ✅ google_maps_flutter (iOS configured)
- ✅ http
- ✅ latlong2
- ✅ in_app_purchase (iOS configured)
- ✅ firebase_storage

## Next Steps

1. **Test on iOS Simulator**: Run the app and test all features
2. **Test on Physical Device**: Build and run on an actual iPhone/iPad
3. **User Permissions Flow**: Test permission requests for location, camera, and photos
4. **Firebase Integration**: Verify authentication and database operations work on iOS
5. **Maps**: Test Google Maps functionality on iOS

## References

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [iOS Permissions in Flutter](https://docs.flutter.dev/development/platform-integration/permissions)
