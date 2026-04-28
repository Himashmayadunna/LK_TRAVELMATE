import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import 'welcome_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _openWelcome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F4FF), Color(0xFFF7FAFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    const _HeroGallery(),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find the best of Sri Lanka for every journey',
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              height: 1.08,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'From ancient temples and rock fortresses to wildlife safaris and coastal escapes, start your trip with places worth remembering.',
                            style: AppTheme.bodyLarge.copyWith(
                              fontSize: 15.5,
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: const [
                              _DotIndicator(isActive: false),
                              SizedBox(width: 8),
                              _DotIndicator(isActive: true),
                              SizedBox(width: 8),
                              _DotIndicator(isActive: false),
                            ],
                          ),
                          const SizedBox(height: 30),
                          _PrimaryButton(
                            label: 'Get Started',
                            onTap: () => _openWelcome(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Image.asset('assets/logo/Travelmate.png', height: 34),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 460,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _GalleryCard(
                          imagePath: 'assets/start/temple_of_tooth.webp',
                          alignment: Alignment.center,
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        flex: 2,
                        child: _GalleryCard(
                          imagePath: 'assets/start/sigiriya_rock.jpg',
                          alignment: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _GalleryCard(
                          imagePath: 'assets/start/dambulla_cave_temple.webp',
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        flex: 3,
                        child: _GalleryCard(
                          imagePath: 'assets/start/unawatuna_beach.webp',
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _GalleryCard(
                          imagePath: 'assets/start/yala_national_park.webp',
                          alignment: Alignment.center,
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        flex: 2,
                        child: _GalleryCard(
                          imagePath: 'assets/start/mirissa_beach.jpg',
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.imagePath, required this.alignment});

  final String imagePath;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            alignment: alignment,
            filterQuality: FilterQuality.high,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
