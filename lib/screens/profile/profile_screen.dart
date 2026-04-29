import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_places_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/profile_stat_card.dart';
import '../../widgets/saved_destination_tile.dart';
import '../../widgets/section_header.dart';
import '../auth/welcome_screen.dart';
import '../explore/destination_detail_screen.dart';
import '../../models/destination.dart';
import '../../providers/destinations_provider.dart';


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

  Future<void> _pickAndUploadImage(AuthProvider authProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null && context.mounted) {
      try {
        await authProvider.uploadProfilePhoto(File(image.path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile photo')),
          );
        }
      }
    }
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
              photoUrl: authProvider.photoUrl,
              isUploadingPhoto: authProvider.isUploadingPhoto,
              onEditPhoto: () => _pickAndUploadImage(authProvider),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _openSavedPlaces,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ProfileStatCard(
                  label: 'Saved Places',
                  value: '$savedCount',
                  icon: Icons.favorite_rounded,
                  iconColor: AppTheme.accent,
                  iconBgColor: AppTheme.accent.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _openTravelPlans,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ProfileStatCard(
                  label: 'Travel Plans',
                  value: '$_travelPlans',
                  icon: Icons.map_outlined,
                  iconColor: AppTheme.primary,
                  iconBgColor: AppTheme.primarySurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _openVisitedPlaces,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ProfileStatCard(
                  label: 'Visited',
                  value: '$_visited',
                  icon: Icons.check_circle_rounded,
                  iconColor: AppTheme.success,
                  iconBgColor: AppTheme.success.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(SavedPlacesProvider savedProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profile',
                  highlighted: true,
                  onTap: _editProfile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.share_rounded,
                  label: 'Share Profile',
                  onTap: _shareProfile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.download_rounded,
                  label: 'Download Data',
                  onTap: _downloadData,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            gradient: highlighted ? AppTheme.primaryGradient : null,
            color: highlighted ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : AppTheme.softShadow,
            border: !highlighted
                ? Border.all(color: AppTheme.divider, width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: highlighted
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: highlighted ? Colors.white : AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTheme.caption.copyWith(
                  color: highlighted ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Profile feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openSavedPlaces() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Saved Places...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openTravelPlans() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Travel Plans...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openVisitedPlaces() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Visited Places...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share Profile feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download Data feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSavedDestinations() {
    return Consumer<SavedPlacesProvider>(
      builder: (context, savedProvider, _) {
        final savedPlaces = savedProvider.savedPlaces;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Column(
            children: [
              SectionHeader(
                title: 'Saved Destinations',
                actionText: savedPlaces.isEmpty
                    ? 'Explore'
                    : '${savedPlaces.length} saved',
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
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textHint,
                        ),
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
                        final destProvider = context
                            .read<DestinationsProvider>();
                        final fullDest = destProvider.destinations.firstWhere(
                          (d) => d.id == dest.id,
                          orElse: () => Destination(
                            id: dest.id,
                            name: dest.name,
                            imageUrl: dest.imageUrl,
                            category: dest.category,
                            rating: 0.0,
                            budget: '',
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DestinationDetailScreen(destination: fullDest),
                          ),
                        );
                      },
                      onDelete: () async {
                        await savedProvider.removeSavedPlace(dest.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${dest.name} removed from saved'),
                            backgroundColor: AppTheme.textSecondary,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
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
