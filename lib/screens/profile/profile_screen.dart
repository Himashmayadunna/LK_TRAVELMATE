import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_places_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/profile_stat_card.dart';
import '../../widgets/saved_destination_tile.dart';
import '../../widgets/section_header.dart';
import '../auth/welcome_screen.dart';
import '../explore/destination_detail_screen.dart';
import '../explore/explore_screen.dart' show sriLankaDestinations;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _travelPlans = 2;
  final int _visited = 8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedPlacesProvider>().fetchSavedPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final savedProvider = Provider.of<SavedPlacesProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(
              name: authProvider.displayName,
              email: authProvider.email,
              initials: authProvider.initials,
              badge: 'Explorer',
              tripCount: _visited,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildStatsSection(savedProvider.savedCount),
          ),
          SliverToBoxAdapter(child: _buildSavedDestinations()),
          SliverToBoxAdapter(child: _buildLogoutButton()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatsSection(int savedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          ProfileStatCard(
            label: 'Saved Places',
            value: '$savedCount',
            icon: Icons.favorite_rounded,
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

  Widget _buildSavedDestinations() {
    return Consumer<SavedPlacesProvider>(
      builder: (context, savedProvider, _) {
        final savedPlaces = savedProvider.savedPlaces;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(
            children: [
              SectionHeader(
                title: 'Saved Destinations',
                actionText: savedPlaces.isEmpty ? 'Explore' : '${savedPlaces.length} saved',
                onAction: () {},
              ),
              const SizedBox(height: 16),
              if (savedProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (savedPlaces.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: AppTheme.textHint.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No saved places yet',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textHint),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explore destinations and tap heart to save them here',
                        style: AppTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: savedPlaces.length,
                  itemBuilder: (context, index) {
                    final dest = savedPlaces[index];
                    return SavedDestinationTile(
                      name: dest.name,
                      category: dest.category,
                      imageUrl: dest.imageUrl,
                      onView: () {
                        final fullDest = sriLankaDestinations
                            .where((d) => d.id == dest.id)
                            .firstOrNull;
                        if (fullDest != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DestinationDetailScreen(destination: fullDest),
                            ),
                          );
                        }
                      },
                      onDelete: () {
                        savedProvider.removeSavedPlace(dest.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${dest.name} removed from saved'),
                            backgroundColor: AppTheme.textSecondary,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

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
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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
