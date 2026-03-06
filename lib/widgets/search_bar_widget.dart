import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String hintText;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.hintText = 'Search destinations, activities...',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.primaryLight, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hintText,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
