import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'signin.dart';
import 'signup.dart';

enum AuthPopupMode { signIn, signUp }

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

      if (_currentStep >= 2) {
        _swapTimer?.cancel();
        return;
      }

      setState(() => _currentStep += 1);
    });
  }

  void _openSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _openSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
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
                    3,
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
        );
      default:
        return _AuthChoiceStep(
          key: const ValueKey('intro-step-3'),
          onSignIn: _openSignIn,
          onSignUp: _openSignUp,
        );
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
  });

  final String imagePath;
  final Alignment imageAlignment;
  final String badge;
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
                            _PulseBar(isLong: false),
                          ],
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

class _AuthChoiceStep extends StatelessWidget {
  const _AuthChoiceStep({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset('assets/logo/Travelmate.png'),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to LK TravelMate',
          textAlign: TextAlign.center,
          style: AppTheme.headingLarge.copyWith(
            fontSize: 30,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Choose how you want to continue and start planning your Sri Lanka adventure.',
          textAlign: TextAlign.center,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const Spacer(),
        _PrimaryActionButton(label: 'Sign In', onTap: onSignIn),
        const SizedBox(height: 14),
        _SecondaryActionButton(label: 'Sign Up', onTap: onSignUp),
        const SizedBox(height: 18),
      ],
    );
  }
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

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
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
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: const BorderSide(color: AppTheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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

class _GuestActionButton extends StatelessWidget {
  const _GuestActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primary,
          backgroundColor: AppTheme.primarySurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.explore_outlined, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class AuthPopup extends StatefulWidget {
  const AuthPopup({required this.initialMode, super.key});

  final AuthPopupMode initialMode;

  @override
  State<AuthPopup> createState() => _AuthPopupState();
}

class _AuthPopupState extends State<AuthPopup> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;
  late AuthPopupMode _mode;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mode == AuthPopupMode.signUp && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept terms and privacy policy.'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_mode == AuthPopupMode.signIn) {
        await context.read<AuthProvider>().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await context.read<AuthProvider>().signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchMode(AuthPopupMode newMode) {
    setState(() => _mode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.65,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: Stack(
                children: [
                  // Animated background particles
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ParticlePainter(
                            animation: _animationController,
                            mode: _mode,
                          ),
                        );
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag handle with animation
                        Center(
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppTheme.divider,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Header section with animations
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _mode == AuthPopupMode.signIn
                                            ? 'Welcome back, traveler!'
                                            : 'Join the adventure!',
                                        style: AppTheme.headingMedium.copyWith(
                                          fontSize: 24,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _mode == AuthPopupMode.signIn
                                            ? 'Continue your Sri Lanka journey with personalized recommendations.'
                                            : 'Create your account to unlock exclusive travel features.',
                                        style: AppTheme.bodyLarge.copyWith(
                                          color: AppTheme.textSecondary,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Animated emoji
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    key: ValueKey(_mode),
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: _mode == AuthPopupMode.signIn
                                          ? AppTheme.primaryGradient
                                          : AppTheme.accentGradient,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_mode == AuthPopupMode.signIn
                                              ? AppTheme.primary
                                              : AppTheme.accent).withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _mode == AuthPopupMode.signIn ? '🌴' : '✨',
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Creative hero card
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: _mode == AuthPopupMode.signIn
                                          ? [
                                              AppTheme.primary.withValues(alpha: 0.1),
                                              AppTheme.primaryLight.withValues(alpha: 0.05),
                                            ]
                                          : [
                                              AppTheme.accent.withValues(alpha: 0.1),
                                              AppTheme.gold.withValues(alpha: 0.05),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: (_mode == AuthPopupMode.signIn
                                          ? AppTheme.primary
                                          : AppTheme.accent).withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Icon(
                                          _mode == AuthPopupMode.signIn
                                              ? Icons.login_rounded
                                              : Icons.rocket_launch_rounded,
                                          color: _mode == AuthPopupMode.signIn
                                              ? AppTheme.primary
                                              : AppTheme.accent,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _mode == AuthPopupMode.signIn
                                                  ? 'Quick access to your trips'
                                                  : 'Start your travel story',
                                              style: AppTheme.headingSmall.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _mode == AuthPopupMode.signIn
                                                  ? 'Pick up where you left off with saved destinations and AI recommendations.'
                                                  : 'Get personalized travel insights and save unlimited destinations.',
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.textSecondary,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Form section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_mode == AuthPopupMode.signUp) ...[
                                    _buildAnimatedField(
                                      label: 'Full name',
                                      controller: _nameController,
                                      hint: 'Your full name',
                                      icon: Icons.person_outline,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  _buildAnimatedField(
                                    label: 'Email address',
                                    controller: _emailController,
                                    hint: 'you@example.com',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnimatedField(
                                    label: 'Password',
                                    controller: _passwordController,
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppTheme.textHint,
                                        size: 22,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (val.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_mode == AuthPopupMode.signUp) ...[
                                    const SizedBox(height: 20),
                                    _buildAnimatedField(
                                      label: 'Confirm password',
                                      controller: _confirmPasswordController,
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      obscure: _obscureConfirmPassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppTheme.textHint,
                                          size: 22,
                                        ),
                                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      ),
                                      validator: (val) {
                                        if (_mode == AuthPopupMode.signUp) {
                                          if (val == null || val.isEmpty) {
                                            return 'Confirm your password';
                                          }
                                          if (val != _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: _acceptedTerms
                                                  ? AppTheme.primary
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: _acceptedTerms
                                                    ? AppTheme.primary
                                                    : AppTheme.divider,
                                                width: 2,
                                              ),
                                            ),
                                            child: _acceptedTerms
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'I agree to the terms and privacy policy.',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 28),
                                  _buildAnimatedButton(
                                    label: _mode == AuthPopupMode.signIn ? 'Sign In' : 'Create account',
                                    onTap: _submit,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnimatedDivider(
                                    text: _mode == AuthPopupMode.signIn ? 'or continue with' : 'or sign up with',
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildAnimatedSocialButton(
                                          label: 'Google',
                                          icon: Icons.g_mobiledata,
                                          tint: const Color(0xFFDB4437),
                                          onTap: () {},
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildAnimatedSocialButton(
                                          label: 'Facebook',
                                          icon: Icons.facebook,
                                          tint: const Color(0xFF1877F2),
                                          onTap: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => _switchMode(
                                      _mode == AuthPopupMode.signIn ? AuthPopupMode.signUp : AuthPopupMode.signIn,
                                    ),
                                    child: Text(
                                      _mode == AuthPopupMode.signIn
                                          ? 'Need an account? Sign Up'
                                          : 'Already have an account? Sign In',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelBold.copyWith(
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(20 * (1 - _fadeAnimation.value), 0),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
                    prefixIcon: Icon(icon, color: AppTheme.textHint, size: 22),
                    suffixIcon: suffixIcon,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      borderSide: BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      borderSide: BorderSide(color: AppTheme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({required String label, required VoidCallback onTap}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: _isLoading ? null : onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppTheme.primaryGradient,
                  color: _isLoading ? AppTheme.primary.withValues(alpha: 0.7) : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDivider({required String text}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Row(
            children: [
              Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(text, style: AppTheme.caption),
              ),
              Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSocialButton({
    required String label,
    required IconData icon,
    required Color tint,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cardShadow.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: tint, size: 22),
                    const SizedBox(width: 8),
                    Text(label, style: AppTheme.labelBold.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final AuthPopupMode mode;

  _ParticlePainter({required this.animation, required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw animated particles
    for (int i = 0; i < 8; i++) {
      final progress = (animation.value + i * 0.125) % 1.0;
      final x = size.width * 0.1 + (size.width * 0.8) * progress;
      final y = size.height * 0.2 + math.sin(progress * math.pi * 2) * 40;

      paint.color = (mode == AuthPopupMode.signIn ? AppTheme.primary : AppTheme.accent)
          .withValues(alpha: (1 - progress) * 0.1);

      canvas.drawCircle(Offset(x, y), 3 + progress * 2, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
