import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import 'ai_chat_screen.dart';
import 'hotel_suggestions_screen.dart';

class PlaceDetailsFormScreen extends StatefulWidget {
  const PlaceDetailsFormScreen({super.key});

  @override
  State<PlaceDetailsFormScreen> createState() => _PlaceDetailsFormScreenState();
}

class _PlaceDetailsFormScreenState extends State<PlaceDetailsFormScreen> {
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _detailOptions = const [
    'Overview',
    'Best time to visit',
    'Entry fee',
    'How to reach',
    'Nearby food',
    'Safety tips',
  ];

  final Set<String> _selectedDetails = {
    'Overview',
    'Best time to visit',
    'Entry fee',
    'How to reach',
  };

  @override
  void dispose() {
    _placeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final place = _placeController.text.trim();
    final notes = _notesController.text.trim();

    if (place.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a place name'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    final details = _selectedDetails.join(', ');
    final notesText = notes.isEmpty ? 'No extra notes' : notes;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIChatScreen(
          initialPrompt:
              'Give me detailed travel information for $place. Include: $details. Extra notes from the user: $notesText. Keep the answer practical, short, and easy to scan.',
        ),
      ),
    );
  }

  void _findHotels() {
    final place = _placeController.text.trim();
    final notes = _notesController.text.trim();

    if (place.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a place name'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    final details = _selectedDetails.join(', ');
    final notesText = notes.isEmpty ? 'No extra notes' : notes;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelSuggestionsScreen(
          place: place,
          details: details,
          notes: notesText,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          labelText: label,
          labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
          hintText: hint,
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textHint,
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
        ),
        title: const Text(
          'Place Details',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.place_rounded, color: Colors.white, size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter the place you want to know',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose what details you want and get a focused answer.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _placeController,
              label: 'Place name',
              hint: 'e.g. Sigiriya, Galle, Ella',
              icon: Icons.travel_explore_rounded,
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _notesController,
              label: 'Extra notes',
              hint: 'e.g. family trip, budget travel, one-day visit',
              icon: Icons.edit_note_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            const Text(
              'What details do you want?',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _detailOptions.map((detail) {
                final isSelected = _selectedDetails.contains(detail);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDetails.remove(detail);
                      } else {
                        _selectedDetails.add(detail);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      border: isSelected
                          ? null
                          : Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      detail,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: _submit,
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
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Suggest the detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _findHotels,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hotel_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Find hotels',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
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
