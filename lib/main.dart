import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ai_suggestion_provider.dart';
import 'providers/saved_places_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home/home.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/ai/ai_assistant_shell.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AISuggestionProvider()),
        ChangeNotifierProvider(create: (_) => SavedPlacesProvider()),
      ],
      child: MaterialApp(
        title: 'LK TravelMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const WelcomeScreen(),
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
  static const Color _navBarColor = Color(0xFF5E71B3);
  static const Color _navItemColor = Colors.white;
  static const Color _mapSelectedCircleColor = Colors.white;
  static const Color _mapIconColor = Color(0xFF465A95);

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
          color: _navBarColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_outlined,
                  Icons.home_rounded,
                  'Home',
                  0,
                ),
                _buildNavItem(
                  Icons.explore_outlined,
                  Icons.explore,
                  'Explore',
                  1,
                ),
                _buildCenterMapButton(),
                _buildNavItem(
                  Icons.auto_awesome_outlined,
                  Icons.auto_awesome,
                  'Translator',
                  3,
                ),
                _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: isSelected ? 0.95 : 0.24,
                  ),
                ),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? _navBarColor : _navItemColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _navItemColor.withValues(alpha: isSelected ? 1 : 0.82),
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
            offset: const Offset(0, -12),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? _mapSelectedCircleColor : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _navBarColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.map_rounded,
                color: _mapIconColor,
                size: 32,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Text(
              'Map',
              style: TextStyle(
                color: _navItemColor,
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
