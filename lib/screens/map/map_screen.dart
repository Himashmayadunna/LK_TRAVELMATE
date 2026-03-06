import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Map', style: AppTheme.headingLarge),
              const SizedBox(height: 8),
              Text(
                'Explore Sri Lanka on the map',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
