import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class TravelPlanCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final VoidCallback? onTap;

  const TravelPlanCard({
    super.key,
    required this.label,
    required this.value,
    required this.emoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.primarySoft, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTheme.labelBold.copyWith(
                color: AppTheme.primaryDark,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
