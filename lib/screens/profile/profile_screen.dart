import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👤', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Profile', style: AppTheme.headingLarge),
              const SizedBox(height: 8),
              Text(
                'Manage your account',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
