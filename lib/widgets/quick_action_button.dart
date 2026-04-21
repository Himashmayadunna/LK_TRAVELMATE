import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class QuickActionButton extends StatelessWidget {
  final IconData? icon;
  final String? iconAssetPath;
  final String label;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    this.icon,
    this.iconAssetPath,
    required this.label,
    this.onTap,
  }) : assert(icon != null || iconAssetPath != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.divider),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cardShadow.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: iconAssetPath != null
                  ? Image.asset(iconAssetPath!, fit: BoxFit.contain)
                  : Icon(icon, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
