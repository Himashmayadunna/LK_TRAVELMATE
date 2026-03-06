import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_service.dart';
import '../../main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Password strength
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = AppTheme.textHint;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _passwordController.addListener(_evaluatePasswordStrength);
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evaluatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;

    if (password.length >= 6) strength += 0.2;
    if (password.length >= 10) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;

    String label;
    Color color;

    if (strength <= 0.25) {
      label = 'Weak';
      color = AppTheme.error;
    } else if (strength <= 0.5) {
      label = 'Fair';
      color = AppTheme.warning;
    } else if (strength <= 0.75) {
      label = 'Good';
      color = AppTheme.accent;
    } else {
      label = 'Strong';
      color = AppTheme.success;
    }

    setState(() {
      _passwordStrength = strength.clamp(0, 1);
      _passwordStrengthLabel = password.isEmpty ? '' : label;
      _passwordStrengthColor = color;
    });
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showSnackBar('Please agree to Terms & Privacy Policy', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user with Firebase Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Update display name
      await credential.user?.updateDisplayName(_nameController.text.trim());

      // Send email verification
      await credential.user?.sendEmailVerification();

      if (!mounted) return;

      _showSuccessDialog();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak. Use a stronger one.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign up is not enabled.';
          break;
        default:
          message = e.message ?? 'Sign up failed. Please try again.';
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.signInWithGoogle();
      if (result == null) {
        // User cancelled
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Google sign in failed. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppTheme.success,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Account Created! 🎉',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A verification email has been sent to\n${_emailController.text.trim()}',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Start Exploring',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── GRADIENT HEADER ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join LK TravelMate and start exploring\nSri Lanka like never before ✨',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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
  }

  // ─── SIGN UP FORM ─────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Full Name ──
            _buildInputLabel('Full Name'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Name is required';
                if (val.trim().length < 2) return 'Name is too short';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // ── Email ──
            _buildInputLabel('Email Address'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _emailController,
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w\.-]+@[\w-]+\.[\w-]{2,4}$')
                    .hasMatch(val.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // ── Password ──
            _buildInputLabel('Password'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _passwordController,
              hint: 'Min. 6 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textHint,
                  size: 20,
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Password is required';
                if (val.length < 6) {
                  return 'Must be at least 6 characters';
                }
                return null;
              },
            ),
            // Password strength indicator
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildPasswordStrengthBar(),
            ],
            const SizedBox(height: 18),

            // ── Confirm Password ──
            _buildInputLabel('Confirm Password'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Re-enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textHint,
                  size: 20,
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please confirm your password';
                }
                if (val != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Terms checkbox ──
            _buildTermsCheckbox(),
            const SizedBox(height: 24),

            // ── Sign Up Button ──
            _buildSignUpButton(),
            const SizedBox(height: 20),

            // ── Divider ──
            _buildOrDivider(),
            const SizedBox(height: 20),

            // ── Social Sign Up ──
            _buildSocialButton(
              label: 'Sign up with Google',
              iconPath: 'G',
              onTap: () => _handleGoogleSignIn(),
            ),
            const SizedBox(height: 24),

            // ── Already have an account ──
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: AppTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── INPUT LABEL ──────────────────────────────────────────────
  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: AppTheme.labelBold.copyWith(
        fontSize: 13,
        color: AppTheme.textPrimary,
      ),
    );
  }

  // ─── TEXT FIELD ───────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppTheme.textHint.withValues(alpha: 0.7),
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(prefixIcon, color: AppTheme.primaryAccent, size: 20),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  // ─── PASSWORD STRENGTH ────────────────────────────────────────
  Widget _buildPasswordStrengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: AppTheme.divider,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _passwordStrengthLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _passwordStrengthColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── TERMS CHECKBOX ───────────────────────────────────────────
  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agreeToTerms ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreeToTerms ? AppTheme.primary : AppTheme.textHint,
                width: 1.5,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check_rounded,
                    size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: AppTheme.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SIGN UP BUTTON ──────────────────────────────────────────
  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppTheme.primaryGradient,
          color: _isLoading ? AppTheme.primaryAccent : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── OR DIVIDER ───────────────────────────────────────────────
  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textHint,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
      ],
    );
  }

  // ─── SOCIAL BUTTON ────────────────────────────────────────────
  Widget _buildSocialButton({
    required String label,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.divider, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo in colors
            Text(
              iconPath,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
