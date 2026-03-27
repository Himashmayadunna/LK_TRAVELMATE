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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Container(
            width: 56,
            height: 56,
            color: AppTheme.primarySurface,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.landscape_rounded,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                  )
                : const Icon(
                    Icons.landscape_rounded,
                    color: AppTheme.primary,
                    size: 28,
                  ),
          ),
        ),
        title: Text(
          name,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          category,
          style: AppTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onView,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
