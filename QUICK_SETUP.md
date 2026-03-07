# Google Maps API - Quick Setup Checklist

## ✅ What I've Already Done

Your map screen has been completely redesigned and includes:
- ✅ Full-screen Google Map of Sri Lanka
- ✅ Search bar to find locations
- ✅ "Top Places" section showing 8 travel destinations
- ✅ Auto-zoom when clicking a location (close view)
- ✅ Smooth animations and transitions
- ✅ Proper navigation bar integration (below the screen)
- ✅ Android permissions configured (Internet, Location)
- ✅ iOS permissions configured (Location)

## 🔑 Your Next Step: Add Google Maps API Keys

### Option 1: Use an Existing API Key (Quickest)
If you already have Google Maps API keys from Google Cloud Console:

**For Android:**
1. Open: `android/app/src/main/AndroidManifest.xml`
2. Find the line: `android:value="YOUR_ANDROID_API_KEY_HERE"`
3. Replace `YOUR_ANDROID_API_KEY_HERE` with your actual Android API key

**For iOS:**
1. Open: `ios/Runner/Info.plist`
2. Find the line: `<string>YOUR_IOS_API_KEY_HERE</string>`
3. Replace `YOUR_IOS_API_KEY_HERE` with your actual iOS API key

### Option 2: Create New API Keys
Follow the detailed guide in `GOOGLE_MAPS_SETUP.md` to:
1. Create a Google Cloud project
2. Generate API keys for Android & iOS
3. Add them to your project files

## 🚀 Running the App

After adding API keys, run:

**For Android:**
```powershell
flutter clean
flutter pub get
flutter run
```

**For iOS:**
```bash
flutter clean
flutter pub get
flutter run
```

## ❓ Troubleshooting

### Map Shows Blank/Gray Screen
- ✅ Verify API key is correctly added
- ✅ Check that internet permission is enabled
- ✅ Try: `flutter clean` then `flutter pub get` then `flutter run`
- ✅ Restart the app after adding API keys

### "Maps API error" message
- Verify API key has Maps SDK enabled in Google Cloud Console
- Check SHA-1 fingerprint matches (Android)
- Check Bundle ID matches (iOS)

### Search Not Working
- Type the exact location name (e.g., "Sigiriya Rock", "Mirissa", "Ella")
- Location names are case-insensitive

## 📍 Available Locations to Search
1. Sigiriya Rock
2. Temple of the Tooth
3. Mirissa Beach
4. Ella Rock
5. Galle Fort
6. Adam's Peak
7. Nuwara Eliya
8. Colombo City

## 📱 Features in Your Map Screen

- **Search Bar**: Type any location name to search
- **Top Places Cards**: Click any card to zoom into that location
- **Markers**: All 8 locations show as blue pins on the map
- **Current Location Button**: Top-right icon to return to Sri Lanka overview
- **Navigation Bar**: Kept at the bottom as required

## 🎯 Map Layout (Top to Bottom)
1. Header with "Map" title and buttons
2. Search bar
3. Google Map (main interactive area)
4. Top Places section (scrollable cards)
5. Navigation bar below (on main app screen)

All set! Just add your API keys and you're good to go! 🗺️
