import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final String? photoUrl;
  final bool isUploadingPhoto;
  final VoidCallback? onEditPhoto;
  final String badge;
  final int tripCount;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.initials,
    this.photoUrl,
    this.isUploadingPhoto = false,
    this.onEditPhoto,
    this.badge = 'Explorer',
    this.tripCount = 0,
  });

  Widget _buildInitials() {
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXLarge),
          bottomRight: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        children: [
          // Top row title
          const Center(
            child: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Avatar
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: isUploadingPhoto
                      ? const CircularProgressIndicator(color: AppTheme.primary)
                      : photoUrl != null && photoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                photoUrl!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildInitials();
                                },
                              ),
                            )
                          : _buildInitials(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isUploadingPhoto ? null : onEditPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name.isEmpty ? 'Traveler' : name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            email.isEmpty ? 'traveler@example.com' : email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.gold,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
