import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ai_suggestion_provider.dart';
import 'providers/hotel_suggestion_provider.dart';
import 'providers/saved_places_provider.dart';
import 'screens/auth/start_screen.dart';
import 'screens/home/home.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/ai/ai_assistant_shell.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/app_theme.dart';
import 'providers/destinations_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;
  String? firebaseInitError;

  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    final rawError = e.toString();
    if (rawError.contains('Failed to load FirebaseOptions from resource')) {
      firebaseInitError =
          'Firebase config was not found. Add android/app/google-services.json '
          'and run flutterfire configure to generate lib/firebase_options.dart.';
    } else {
      firebaseInitError =
          'Firebase initialization failed. Please verify Firebase setup.';
    }
    debugPrint('Firebase init error: $rawError');
  }

  runApp(MyApp(firebaseReady: firebaseReady, firebaseInitError: firebaseInitError));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.firebaseReady,
    this.firebaseInitError,
  });

  final bool firebaseReady;
  final String? firebaseInitError;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return MaterialApp(
        title: 'LK TravelMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: _FirebaseSetupScreen(error: firebaseInitError),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AISuggestionProvider()),
        ChangeNotifierProvider(create: (_) => HotelSuggestionProvider()),
        ChangeNotifierProvider(create: (_) => DestinationsProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SavedPlacesProvider>(
          create: (_) => SavedPlacesProvider(),
          update: (_, auth, savedPlaces) {
            final provider = savedPlaces ?? SavedPlacesProvider();
            provider.configureForUser(auth.currentUser);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'LK TravelMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isAuthReady) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            }

            return const StartScreen();
          },
        ),
      ),
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 72, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Firebase setup is missing',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add Firebase configuration files for Android/iOS and restart the app.',
                textAlign: TextAlign.center,
              ),
              if (error != null && error!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const MapScreen(),
    AIAssistantShell(onBack: () => setState(() => _currentIndex = 0)),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildModernNavItem(
                  Icons.home_outlined,
                  Icons.home_rounded,
                  'Home',
                  0,
                  AppTheme.primary,
                ),
                _buildModernNavItem(
                  Icons.search_outlined,
                  Icons.search_rounded,
                  'Explore',
                  1,
                  AppTheme.accent,
                ),
                _buildCenterMapButton(),
                _buildModernNavItem(
                  Icons.chat_bubble_outline,
                  Icons.chat_bubble_rounded,
                  'Chat',
                  3,
                  AppTheme.purple,
                ),
                _buildModernNavItem(
                  Icons.person_outline,
                  Icons.person_rounded,
                  'Profile',
                  4,
                  AppTheme.primaryLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    Color activeColor,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeColor : AppTheme.textHint,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppTheme.textHint,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterMapButton() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -14),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.map_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Text(
              'Map',
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textHint,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
