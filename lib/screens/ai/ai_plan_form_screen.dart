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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.primary, size: 22),
                SizedBox(width: 8),
                Text('Plan Your Trip', style: AppTheme.headingMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us what you want and AI will suggest the perfect places!',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            _buildInputField(
              controller: _placesController,
              label: 'Places you want to visit',
              hint: 'e.g. waterfalls',
              icon: Icons.place_rounded,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _foodController,
              label: 'Food you like to eat',
              hint: 'e.g. spicy foods',
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
            GestureDetector(
              onTap: _navigateToSuggestions,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
