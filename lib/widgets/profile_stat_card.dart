import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color iconBgColor;
  final String? iconAssetPath;
  final VoidCallback? onTap;

  const ProfileStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    required this.iconBgColor,
    this.iconAssetPath,
    this.onTap,
  }) : assert(iconAssetPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 148,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: iconAssetPath != null
                    ? Image.asset(iconAssetPath!, fit: BoxFit.contain)
                    : Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 28,
                child: Center(
                  child: Text(
                    label,
                    style: AppTheme.caption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
