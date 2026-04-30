import 'dart:io';
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
  final DateTime? memberSince;

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
    this.memberSince,
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.radiusXLarge),
              bottomRight: Radius.circular(AppTheme.radiusXLarge),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
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
                                ? ClipOval(child: _buildPhotoWidget(photoUrl!))
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
                Text(
                  name.isEmpty ? 'Traveler' : name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? 'traveler@example.com' : email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.white, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '$tripCount trips',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        memberSince != null
                            ? 'Member since ${memberSince!.year}'
                            : 'Member since ${DateTime.now().year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoWidget(String url) {
    try {
      if (url.startsWith('file://')) {
        final path = Uri.parse(url).toFilePath();
        return Image.file(File(path), fit: BoxFit.cover);
      }
      // If it's a valid local path
      if (File(url).existsSync()) {
        return Image.file(File(url), fit: BoxFit.cover);
      }
    } catch (_) {
      // fallthrough to network
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildInitials(),
    );
  }
}
