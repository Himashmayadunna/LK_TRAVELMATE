# Google Maps API Setup Guide

## Prerequisites
- Google Cloud Console account
- Active billing enabled on your Google Cloud project

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Geocoding API** (optional, for future features)

## Step 2: Create API Keys

### For Android:

1. In Google Cloud Console, go to **Credentials**
2. Click **Create Credentials** → **API Key**
3. Select "Android app"
4. Get your **SHA-1 fingerprint**:
   ```powershell
   cd android
   ./gradlew signingReport
   ```
   Or use keytool:
   ```powershell
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Add the fingerprint and your app package name (`com.example.lk_travelmate`) to the credential
6. Copy the generated API key

### For iOS:

1. In Google Cloud Console, go to **Credentials**
2. Click **Create Credentials** → **API Key**
3. Select "iOS app"
4. Add your iOS bundle identifier (find in Xcode: `Runner` → `General` → `Bundle Identifier`)
5. Copy the generated API key

## Step 3: Add API Keys to Your Project

### Android Configuration:

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AQ.Ab8RN6IQpxs9N-Y91-wI5NDAsZdTpKgUMdSOSs053Uq6r0rEsg"/>
```

Replace `YAQ.Ab8RN6IQpxs9N-Y91-wI5NDAsZdTpKgUMdSOSs053Uq6r0rEsg` with your Android API key.

### iOS Configuration:

Update `ios/Runner/Info.plist`:

```xml
<key>GoogleMapsAPIKey</key>
<string>AQ.Ab8RN6IQpxs9N-Y91-wI5NDAsZdTpKgUMdSOSs053Uq6r0rEsg</string>
```

Replace `AQ.Ab8RN6IQpxs9N-Y91-wI5NDAsZdTpKgUMdSOSs053Uq6r0rEsg` with your iOS API key.

## Step 4: Test the App

### Run on Android:
```powershell
flutter run -v
```

### Run on iOS:
```bash
flutter run -v
```

## Features Implemented

✅ **Full-Screen Google Map** - Sri Lanka centered view
✅ **Search Bar** - Find travel locations by name
✅ **Close-Up View** - Automatically zooms in (15.5x zoom) on search
✅ **Location Markers** - 8 popular travel destinations
✅ **Location Details** - Bottom sheet with information and coordinates
✅ **Current Location Button** - Reset to Sri Lanka overview
✅ **Smooth Animations** - Camera transitions between locations

## Travel Locations Available

1. Sigiriya Rock Fortress
2. Temple of the Tooth
3. Mirissa Beach
4. Ella Rock
5. Galle Fort
6. Adam's Peak
7. Nuwara Eliya
8. Colombo City

## Troubleshooting

### Map Not Displaying:
- Verify API keys are correctly added
- Check that Google Maps APIs are enabled in Console
- Ensure internet permission is granted
- Try running: `flutter clean` then `flutter pub get`

### API Key Errors:
- Check SHA-1 fingerprint matches (Android)
- Verify bundle identifier matches (iOS)
- Ensure API key has no restrictions

### Search Not Working:
- Check that location names match exactly (case-insensitive)
- Verify travel location data is loaded

## Next Steps

To extend the map, you can:
- Add more travel locations to the `travelLocations` list
- Integrate real-time location services
- Add filtering by category
- Implement place suggestions

## Support

For issues with Google Maps API, visit:
- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Maps Flutter Documentation](https://pub.dev/packages/google_maps_flutter)
