import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

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
	bool _obscureConfirmPassword = true;
	bool _acceptedTerms = false;
	bool _isLoading = false;

	late AnimationController _animController;
	late Animation<double> _fadeAnim;
	late Animation<Offset> _slideAnim;

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

	Future<void> _handleSignUp() async {
		if (!_formKey.currentState!.validate()) return;
		if (!_acceptedTerms) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: const Text('Please accept terms and privacy policy'),
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
			await context.read<AuthProvider>().signUp(
				name: _nameController.text.trim(),
				email: _emailController.text.trim(),
				password: _passwordController.text, // Add this to match AuthProvider params
			);

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
				),
			);
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppTheme.background,
			body: CustomScrollView(
				physics: const BouncingScrollPhysics(),
				slivers: [
					SliverToBoxAdapter(child: _buildHeader()),
					SliverToBoxAdapter(
						child: FadeTransition(
							opacity: _fadeAnim,
							child: SlideTransition(position: _slideAnim, child: _buildForm()),
						),
					),
				],
			),
		);
	}

	Widget _buildHeader() {
		return Container(
			width: double.infinity,
			decoration: const BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [
						AppTheme.primaryDark,
						AppTheme.primary,
						AppTheme.primaryLight,
					],
				),
				borderRadius: BorderRadius.only(
					bottomLeft: Radius.circular(32),
					bottomRight: Radius.circular(32),
				),
			),
			child: SafeArea(
				bottom: false,
				child: Padding(
					padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							GestureDetector(
								onTap: () => Navigator.pop(context),
								child: Container(
									width: 40,
									height: 40,
									decoration: BoxDecoration(
										color: Colors.white.withValues(alpha: 0.18),
										borderRadius: BorderRadius.circular(10),
									),
									child: const Icon(
										Icons.arrow_back_ios_new_rounded,
										color: Colors.white,
										size: 18,
									),
								),
							),
							const SizedBox(height: 18),
							Container(
								width: 56,
								height: 56,
								decoration: BoxDecoration(
									color: Colors.white.withValues(alpha: 0.2),
									borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
								),
								child: const Center(
									child: Text('✨', style: TextStyle(fontSize: 30)),
								),
							),
							const SizedBox(height: 18),
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
								'Join LK TravelMate and plan your dream journey',
								style: TextStyle(
									color: Colors.white.withValues(alpha: 0.85),
									fontSize: 14,
									fontWeight: FontWeight.w400,
								),
							),
						],
					),
				),
			),
		);
	}

	Widget _buildForm() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
			child: Form(
				key: _formKey,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						_buildLabel('Full Name'),
						const SizedBox(height: 8),
						_buildTextField(
							controller: _nameController,
							hint: 'Kanishka Perera',
							icon: Icons.person_outline_rounded,
							validator: (val) {
								if (val == null || val.trim().isEmpty) {
									return 'Please enter your full name';
								}
								if (val.trim().length < 3) {
									return 'Name must be at least 3 characters';
								}
								return null;
							},
						),
						const SizedBox(height: 18),
						_buildLabel('Email Address'),
						const SizedBox(height: 8),
						_buildTextField(
							controller: _emailController,
							hint: 'you@example.com',
							icon: Icons.email_outlined,
							keyboardType: TextInputType.emailAddress,
							validator: (val) {
								if (val == null || val.trim().isEmpty) {
									return 'Please enter your email';
								}
								if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
										.hasMatch(val.trim())) {
									return 'Enter a valid email';
								}
								return null;
							},
						),
						const SizedBox(height: 18),
						const SizedBox(height: 18),
						_buildLabel('Password'),
						const SizedBox(height: 8),
						_buildTextField(
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
									size: 20,
								),
								onPressed: () =>
										setState(() => _obscurePassword = !_obscurePassword),
							),
							validator: (val) {
								if (val == null || val.isEmpty) {
									return 'Please enter a password';
								}
								if (val.length < 6) {
									return 'Password must be at least 6 characters';
								}
								return null;
							},
						),
						const SizedBox(height: 18),
						_buildLabel('Confirm Password'),
						const SizedBox(height: 8),
						_buildTextField(
							controller: _confirmPasswordController,
							hint: '••••••••',
							icon: Icons.lock_reset_outlined,
							obscure: _obscureConfirmPassword,
							suffixIcon: IconButton(
								icon: Icon(
									_obscureConfirmPassword
											? Icons.visibility_off_outlined
											: Icons.visibility_outlined,
									color: AppTheme.textHint,
									size: 20,
								),
								onPressed: () => setState(
									() => _obscureConfirmPassword = !_obscureConfirmPassword,
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
						const SizedBox(height: 14),
						GestureDetector(
							onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
							child: Row(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									AnimatedContainer(
										duration: const Duration(milliseconds: 180),
										width: 20,
										height: 20,
										decoration: BoxDecoration(
											color: _acceptedTerms
													? AppTheme.primary
													: Colors.transparent,
											borderRadius: BorderRadius.circular(5),
											border: Border.all(
												color: _acceptedTerms
														? AppTheme.primary
														: AppTheme.textHint,
												width: 1.5,
											),
										),
										child: _acceptedTerms
												? const Icon(Icons.check, color: Colors.white, size: 14)
												: null,
									),
									const SizedBox(width: 10),
									Expanded(
										child: Text(
											'I agree to the Terms of Service and Privacy Policy',
											style: AppTheme.bodyMedium.copyWith(
												fontSize: 13,
												color: AppTheme.textSecondary,
											),
										),
									),
								],
							),
						),
						const SizedBox(height: 24),
						_buildPrimaryButton(label: 'Create Account', onTap: _handleSignUp),
						const SizedBox(height: 16),
						_buildDivider('or sign up with'),
						const SizedBox(height: 16),
						Row(
							children: [
								Expanded(
									child: _buildSocialButton(
										label: 'Google',
										emoji: '🔵',
										onTap: () {},
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: _buildSocialButton(
										label: 'Facebook',
										emoji: '🟦',
										onTap: () {},
									),
								),
							],
						),
						const SizedBox(height: 24),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Text(
									'Already have an account? ',
									style: AppTheme.bodyMedium.copyWith(fontSize: 13),
								),
								GestureDetector(
									onTap: () => Navigator.pop(context),
									child: Text(
										'Sign In',
										style: AppTheme.bodyMedium.copyWith(
											color: AppTheme.primary,
											fontWeight: FontWeight.w700,
											fontSize: 13,
										),
									),
								),
							],
						),
						const SizedBox(height: 16),
					],
				),
			),
		);
	}

	Widget _buildLabel(String text) {
		return Text(
			text,
			style: AppTheme.labelBold.copyWith(
				fontSize: 13,
				color: AppTheme.textPrimary,
			),
		);
	}

	Widget _buildTextField({
		required TextEditingController controller,
		required String hint,
		required IconData icon,
		bool obscure = false,
		Widget? suffixIcon,
		TextInputType keyboardType = TextInputType.text,
		String? Function(String?)? validator,
	}) {
		return TextFormField(
			controller: controller,
			obscureText: obscure,
			keyboardType: keyboardType,
			validator: validator,
			style: AppTheme.bodyLarge.copyWith(
				color: AppTheme.textPrimary,
				fontSize: 14,
				fontWeight: FontWeight.w500,
			),
			decoration: InputDecoration(
				hintText: hint,
				hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
				prefixIcon: Icon(icon, color: AppTheme.textHint, size: 20),
				suffixIcon: suffixIcon,
				filled: true,
				fillColor: AppTheme.surface,
				contentPadding: const EdgeInsets.symmetric(
					horizontal: 16,
					vertical: 16,
				),
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
					borderSide: const BorderSide(color: AppTheme.error),
				),
				focusedErrorBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
					borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
				),
			),
		);
	}

	Widget _buildPrimaryButton({
		required String label,
		required VoidCallback onTap,
	}) {
		return GestureDetector(
			onTap: _isLoading ? null : onTap,
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 200),
				height: 54,
				decoration: BoxDecoration(
					gradient: _isLoading ? null : AppTheme.primaryGradient,
					color: _isLoading ? AppTheme.primary.withValues(alpha: 0.6) : null,
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
										letterSpacing: 0.3,
									),
								),
				),
			),
		);
	}

	Widget _buildDivider(String text) {
		return Row(
			children: [
				Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16),
					child: Text(text, style: AppTheme.caption),
				),
				Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
			],
		);
	}

	Widget _buildSocialButton({
		required String label,
		required String emoji,
		required VoidCallback onTap,
	}) {
		return GestureDetector(
			onTap: onTap,
			child: Container(
				height: 50,
				decoration: BoxDecoration(
					color: AppTheme.surface,
					borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
					border: Border.all(color: AppTheme.divider),
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
						Text(emoji, style: const TextStyle(fontSize: 18)),
						const SizedBox(width: 8),
						Text(label, style: AppTheme.labelBold.copyWith(fontSize: 13)),
					],
				),
			),
		);
	}
}
