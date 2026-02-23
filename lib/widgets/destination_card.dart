import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/destination_model.dart';

class DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image Section ────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLarge),
                  ),
                  child: Image.network(
                    destination.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_rounded,
                            color: Colors.white54, size: 48),
                      ),
                    ),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        color: AppTheme.primarySurface,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Text(
                      destination.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                if (destination.rating > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusRound),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppTheme.gold),
                          const SizedBox(width: 3),
                          Text(
                            destination.rating.toString(),
                            style: AppTheme.labelBold.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Gradient overlay at bottom of image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x40000000)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ─── Info Section ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTheme.headingSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destination.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppTheme.primaryLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    style: AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Budget tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _budgetColor(destination.budgetLevel)
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusRound),
                        ),
                        child: Text(
                          _budgetLabel(destination.budgetLevel),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _budgetColor(destination.budgetLevel),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // View Details button
                      GestureDetector(
                        onTap: onViewDetails,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusRound),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Budget Helpers ───────────────────────────────────────────────
  String _budgetLabel(String level) {
    switch (level) {
      case 'low':
        return '💰 Budget';
      case 'mid':
        return '💳 Mid-Range';
      case 'premium':
        return '💎 Premium';
      default:
        return '💳 Mid-Range';
    }
  }

  Color _budgetColor(String level) {
    switch (level) {
      case 'low':
        return AppTheme.success;
      case 'mid':
        return AppTheme.primary;
      case 'premium':
        return AppTheme.gold;
      default:
        return AppTheme.primary;
    }
  }
}
