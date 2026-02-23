import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/profile_stat_card.dart';
import '../../widgets/saved_destination_tile.dart';
import '../../widgets/section_header.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sample stats
  final int _savedPlaces = 3;
  final int _travelPlans = 2;
  final int _visited = 8;

  // Sample saved destinations
  final List<Map<String, String>> _savedDestinations = [
    {
      'name': 'Sigiriya Rock Fortress',
      'category': 'Heritage',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg/1280px-Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg',
    },
    {
      'name': 'Mirissa Beach',
      'category': 'Beach',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg/1280px-Coconut_Tree_Hill%2C_Mirissa.jpg',
    },
    {
      'name': 'Ella Nine Arch Bridge',
      'category': 'Adventure',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Ella_Rock_from_Little_Adam%27s_Peak.jpg/1280px-Ella_Rock_from_Little_Adam%27s_Peak.jpg',
    },
  ];

  void _onDeleteDestination(int index) {
    setState(() {
      _savedDestinations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: ProfileHeader(
              name: authProvider.displayName,
              email: authProvider.email,
              initials: authProvider.initials,
              badge: 'Explorer',
              tripCount: _visited,
              onSettingsTap: () {
                // Navigate to settings
              },
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(child: _buildStatsSection()),

          // Saved Destinations Section
          SliverToBoxAdapter(child: _buildSavedDestinations()),

          // Logout Button
          SliverToBoxAdapter(child: _buildLogoutButton()),

          // Bottom spacing for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─── STATS SECTION ──────────────────────────────────────────────
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          ProfileStatCard(
            label: 'Saved Places',
            value: '$_savedPlaces',
            icon: Icons.explore_outlined,
            iconColor: const Color(0xFFE65100),
            iconBgColor: const Color(0xFFFBE9E7),
          ),
          const SizedBox(width: 12),
          ProfileStatCard(
            label: 'Travel Plans',
            value: '$_travelPlans',
            icon: Icons.map_outlined,
            iconColor: AppTheme.primary,
            iconBgColor: AppTheme.primarySurface,
          ),
          const SizedBox(width: 12),
          ProfileStatCard(
            label: 'Visited',
            value: '$_visited',
            icon: Icons.check_box_rounded,
            iconColor: AppTheme.success,
            iconBgColor: const Color(0xFFE8F5E9),
          ),
        ],
      ),
    );
  }

  // ─── SAVED DESTINATIONS ─────────────────────────────────────────
  Widget _buildSavedDestinations() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          SectionHeader(
            title: 'Saved Destinations',
            actionText: 'Add More',
            onAction: () {
              // Navigate to explore/add
            },
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _savedDestinations.length,
            itemBuilder: (context, index) {
              final dest = _savedDestinations[index];
              return SavedDestinationTile(
                name: dest['name']!,
                category: dest['category']!,
                imageUrl: dest['image']!,
                onView: () {
                  // Navigate to destination detail
                },
                onDelete: () => _onDeleteDestination(index),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── LOGOUT BUTTON ──────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color: AppTheme.error.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
              const SizedBox(width: 10),
              Text(
                'Logout',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
            SizedBox(width: 10),
            Text('Logout', style: AppTheme.headingSmall),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Sign out from Firebase
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (!context.mounted) return;
              // Navigate to welcome screen and clear the stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const WelcomeScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
