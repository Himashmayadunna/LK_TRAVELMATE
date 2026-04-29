import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/travel_plan_card.dart';
import 'ai_suggestions_screen.dart';

class AIPlanFormScreen extends StatefulWidget {
  const AIPlanFormScreen({super.key});

  @override
  State<AIPlanFormScreen> createState() => _AIPlanFormScreenState();
}

class _AIPlanFormScreenState extends State<AIPlanFormScreen> {
  final TextEditingController _placesController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  String _selectedDuration = '7 Days';
  String _selectedBudget = '\$800';

  final List<_TripInspiration> _inspirations = const [
    _TripInspiration('Beach escape', Icons.beach_access_rounded, AppTheme.accent),
    _TripInspiration('Culture trail', Icons.temple_hindu_rounded, AppTheme.primary),
    _TripInspiration('Food trip', Icons.restaurant_rounded, AppTheme.purple),
    _TripInspiration('Wild adventure', Icons.park_rounded, AppTheme.gold),
  ];

  @override
  void dispose() {
    _placesController.dispose();
    _foodController.dispose();
    super.dispose();
  }

  void _navigateToSuggestions() {
    final places = _placesController.text.trim();
    final food = _foodController.text.trim();

    if (places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter places you want to visit'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    final foodPref = food.isEmpty ? 'Any local food' : food;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AISuggestionsScreen(
          places: places,
          duration: _selectedDuration,
          food: foodPref,
          budget: _selectedBudget,
        ),
      ),
    );
  }

  void _applyInspiration(String value) {
    setState(() {
      _placesController.text = value;
    });
  }

  void _showDurationPicker() {
    final durations = ['3 Days', '5 Days', '7 Days', '10 Days', '14 Days', '21 Days'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Duration', style: AppTheme.headingSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: durations.map((d) {
                final isSelected = _selectedDuration == d;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDuration = d);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      border: isSelected ? null : Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBudgetPicker() {
    final budgets = ['\$300', '\$500', '\$800', '\$1200', '\$2000', '\$3000+'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Budget', style: AppTheme.headingSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: budgets.map((b) {
                final isSelected = _selectedBudget == b;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBudget = b);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      border: isSelected ? null : Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      b,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          labelText: label,
          labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
          hintText: hint,
          hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHeaderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'AI TRIP BUILDER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationChip(_TripInspiration inspiration) {
    return GestureDetector(
      onTap: () => _applyInspiration(inspiration.label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(color: AppTheme.divider),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: inspiration.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(inspiration.icon, size: 16, color: inspiration.color),
            ),
            const SizedBox(width: 10),
            Text(
              inspiration.label,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -22,
            bottom: -26,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBadge(),
              const SizedBox(height: 18),
              Text(
                'Plan your next\nSri Lanka story',
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tell us the places, food, and budget you want. We\'ll shape a trip idea with style.',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildMiniStat(Icons.place_rounded, 'Places'),
                  _buildMiniStat(Icons.restaurant_rounded, 'Food'),
                  _buildMiniStat(Icons.auto_awesome_rounded, 'AI Picks'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _navigateToSuggestions,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.30),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Get AI Suggestions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSurface() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick inspiration',
            style: AppTheme.headingSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a chip to preload a trip style, then fine-tune the details below.',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _inspirations
                  .map((inspiration) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildInspirationChip(inspiration),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          _buildInputField(
            controller: _placesController,
            label: 'Places you want to visit',
            hint: 'e.g. waterfalls, tea estates, beaches',
            icon: Icons.place_rounded,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _foodController,
            label: 'Food you like to eat',
            hint: 'e.g. spicy foods, seafood, local snacks',
            icon: Icons.restaurant_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TravelPlanCard(
                  label: 'Duration',
                  value: _selectedDuration,
                  icon: Icons.calendar_month_rounded,
                  onTap: _showDurationPicker,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TravelPlanCard(
                  label: 'Budget',
                  value: _selectedBudget,
                  icon: Icons.payments_rounded,
                  onTap: _showBudgetPicker,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(),
        ],
      ),
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
            colors: [Color(0xFFF9FBFF), Color(0xFFFAFBFF), Color(0xFFF6F8FF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                right: -60,
                top: 40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: -50,
                top: 220,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accent.withValues(alpha: 0.08),
                  ),
                ),
              ),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildHero(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFormSurface(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripInspiration {
  final String label;
  final IconData icon;
  final Color color;

  const _TripInspiration(this.label, this.icon, this.color);
}
