import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SavedDestinationTile extends StatelessWidget {
  final String name;
  final String category;
  final String imageUrl;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const SavedDestinationTile({
    super.key,
    required this.name,
    required this.category,
    required this.imageUrl,
    this.onView,
    this.onDelete,
  });

  Color get _categoryColor {
    switch (category.toLowerCase()) {
      case 'heritage':
        return const Color(0xFF00897B);
      case 'beach':
        return const Color(0xFF1E88E5);
      case 'adventure':
        return const Color(0xFFE65100);
      case 'nature':
        return const Color(0xFF2E7D32);
      case 'wildlife':
        return const Color(0xFF6D4C41);
      default:
        return AppTheme.primary;
    }
  }

  Color get _categoryBgColor {
    switch (category.toLowerCase()) {
      case 'heritage':
        return const Color(0xFFE0F2F1);
      case 'beach':
        return const Color(0xFFE3F2FD);
      case 'adventure':
        return const Color(0xFFFBE9E7);
      case 'nature':
        return const Color(0xFFE8F5E9);
      case 'wildlife':
        return const Color(0xFFEFEBE9);
      default:
        return AppTheme.primarySurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                width: 80,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Center(
                  child: Icon(Icons.image_rounded, color: Colors.white54, size: 28),
                ),
              ),
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 80,
                  height: 72,
                  color: AppTheme.primarySurface,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.headingSmall.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryBgColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                icon: Icons.visibility_outlined,
                color: AppTheme.primary,
                bgColor: AppTheme.primarySurface,
                onTap: onView,
              ),
              const SizedBox(width: 8),
              _ActionIconButton(
                icon: Icons.delete_outline_rounded,
                color: AppTheme.error,
                bgColor: const Color(0xFFFFEBEE),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
