import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import 'auth_choice_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const Duration _swapDuration = Duration(milliseconds: 2500);
  static const List<_IntroImageOption> _secondStepImages = [
    _IntroImageOption(
      imagePath: 'assets/start/sigiriya_rock.jpg',
      alignment: Alignment.center,
    ),
    _IntroImageOption(
      imagePath: 'assets/start/mirissa_beach.jpg',
      alignment: Alignment.center,
    ),
    _IntroImageOption(
      imagePath: 'assets/start/unawatuna_beach.webp',
      alignment: Alignment.centerLeft,
    ),
    _IntroImageOption(
      imagePath: 'assets/start/temple_of_tooth.webp',
      alignment: Alignment.center,
    ),
    _IntroImageOption(
      imagePath: 'assets/start/dambulla_cave_temple.webp',
      alignment: Alignment.center,
    ),
    _IntroImageOption(
      imagePath: 'assets/start/yala_national_park.webp',
      alignment: Alignment.center,
    ),
  ];

  int _currentStep = 0;
  Timer? _swapTimer;
  late final _IntroImageOption _selectedSecondStepImage;

  @override
  void initState() {
    super.initState();
    _selectedSecondStepImage =
        _secondStepImages[Random().nextInt(_secondStepImages.length)];
    _startAutoSwap();
  }

  @override
  void dispose() {
    _swapTimer?.cancel();
    super.dispose();
  }

  void _startAutoSwap() {
    _swapTimer = Timer.periodic(_swapDuration, (_) {
      if (!mounted) return;

      if (_currentStep >= 1) {
        _swapTimer?.cancel();
        return;
      }

      setState(() => _currentStep += 1);
    });
  }

  void _openAuthChoice() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F5FF), Color(0xFFF8FBFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 550),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slideAnimation = Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slideAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: _buildCurrentStep(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _DotIndicator(isActive: index == _currentStep),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return const _CollageSplashStep(
          key: ValueKey('intro-step-0'),
          title: 'Find the best of Sri Lanka for every journey',
          description:
              'From ancient temples and rock fortresses to wildlife safaris and coastal escapes, your travel welcome is getting ready.',
        );
      case 1:
        return _IntroSplashStep(
          key: ValueKey(_selectedSecondStepImage.imagePath),
          imagePath: _selectedSecondStepImage.imagePath,
          imageAlignment: _selectedSecondStepImage.alignment,
          badge: 'Discover Sri Lanka',
          title: 'A smarter way to begin every island journey',
          description:
              'Wait a moment while LK TravelMate opens your travel space with beautiful stays, historic wonders, and coastal escapes.',
          actionLabel: 'Get Started',
          onActionTap: _openAuthChoice,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CollageSplashStep extends StatelessWidget {
  const _CollageSplashStep({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Welcome Journey',
                        style: AppTheme.labelBold.copyWith(
                          color: AppTheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Image.asset('assets/logo/Travelmate.png', height: 34),
                  ],
                ),
                const SizedBox(height: 18),
                const Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 4,
                              child: _MosaicImageCard(
                                imagePath: 'assets/start/unawatuna_beach.webp',
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                            SizedBox(height: 14),
                            Expanded(
                              flex: 2,
                              child: _MosaicImageCard(
                                imagePath: 'assets/start/sigiriya_rock.jpg',
                                alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _MosaicImageCard(
                                imagePath:
                                    'assets/start/dambulla_cave_temple.webp',
                                alignment: Alignment.center,
                              ),
                            ),
                            SizedBox(height: 14),
                            Expanded(
                              flex: 4,
                              child: _MosaicImageCard(
                                imagePath: 'assets/start/mirissa_beach.jpg',
                                alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 4,
                              child: _MosaicImageCard(
                                imagePath: 'assets/start/temple_of_tooth.webp',
                                alignment: Alignment.center,
                              ),
                            ),
                            SizedBox(height: 14),
                            Expanded(
                              flex: 3,
                              child: _MosaicImageCard(
                                imagePath:
                                    'assets/start/yala_national_park.webp',
                                alignment: Alignment.center,
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
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: AppTheme.headingLarge.copyWith(
            color: AppTheme.textPrimary,
            fontSize: 29,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 14.5,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            _ProgressLine(isLong: true),
            SizedBox(width: 10),
            _ProgressLine(isLong: false),
            SizedBox(width: 10),
            _ProgressLine(isLong: false),
          ],
        ),
      ],
    );
  }
}

class _IntroSplashStep extends StatelessWidget {
  const _IntroSplashStep({
    super.key,
    required this.imagePath,
    required this.imageAlignment,
    required this.badge,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String imagePath;
  final Alignment imageAlignment;
  final String badge;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    alignment: imageAlignment,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: const [
                            _PulseBar(isLong: true),
                            SizedBox(width: 10),
                            _PulseBar(isLong: false),
                            SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: _PrimaryActionButton(
                            label: actionLabel,
                            onTap: onActionTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroImageOption {
  const _IntroImageOption({required this.imagePath, required this.alignment});

  final String imagePath;
  final Alignment alignment;
}

class _MosaicImageCard extends StatelessWidget {
  const _MosaicImageCard({required this.imagePath, required this.alignment});

  final String imagePath;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        alignment: alignment,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _PulseBar extends StatelessWidget {
  const _PulseBar({required this.isLong});

  final bool isLong;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLong ? 38 : 16,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.isLong});

  final bool isLong;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLong ? 38 : 16,
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: isLong ? 0.9 : 0.3),
        borderRadius: BorderRadius.circular(999),
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
      duration: const Duration(milliseconds: 250),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
