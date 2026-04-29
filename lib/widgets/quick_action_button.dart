import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlighted;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: highlighted ? 68 : 60,
            height: highlighted ? 68 : 60,
            decoration: BoxDecoration(
              gradient: highlighted
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.accent],
                    )
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(
                highlighted ? AppTheme.radiusLarge : AppTheme.radiusMedium,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: highlighted ? 0.60 : 0.38,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(
                    alpha: highlighted ? 0.34 : 0.24,
                  ),
                  blurRadius: highlighted ? 16 : 12,
                  offset: Offset(0, highlighted ? 6 : 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: highlighted ? 28 : 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
              fontSize: highlighted ? 12 : 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
