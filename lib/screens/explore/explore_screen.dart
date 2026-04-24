import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_places_provider.dart';
import '../auth/signin.dart';

// ── Inline Model ──────────────────────────────────────────────────────────────

class Destination {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final double rating;
  final String budget;

  const Destination({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.budget,
  });
}

final List<Destination> _sriLankaDestinations = [
  Destination(
    id: '1',
    name: 'Sigiriya Rock Fortress',
    imageUrl:
        'https://images.unsplash.com/photo-1586613835341-d8e8b4e6c9b4?w=400',
    category: 'Heritage',
    rating: 4.9,
    budget: '\$\$',
  ),
  Destination(
    id: '2',
    name: 'Mirissa Beach',
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
    category: 'Beach',
    rating: 4.8,
    budget: '\$',
  ),
  Destination(
    id: '3',
    name: 'Temple of the Tooth',
    imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=400',
    category: 'Cultural',
    rating: 4.7,
    budget: '\$',
  ),
  Destination(
    id: '4',
    name: 'Ella Rock Train Bridge',
    imageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
    category: 'Nature',
    rating: 4.8,
    budget: '\$',
  ),
  Destination(
    id: '5',
    name: 'Yala National Park',
    imageUrl: 'https://images.unsplash.com/photo-1551918120-9739cb430c6d?w=400',
    category: 'Safari',
    rating: 4.6,
    budget: '\$\$\$',
  ),
  Destination(
    id: '6',
    name: 'Unawatuna Beach',
    imageUrl:
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400',
    category: 'Beach',
    rating: 4.5,
    budget: '\$',
  ),
  Destination(
    id: '7',
    name: 'Dambulla Cave Temple',
    imageUrl: 'https://images.unsplash.com/photo-1573408259-0a7bf48c5918?w=400',
    category: 'Heritage',
    rating: 4.7,
    budget: '\$\$',
  ),
  Destination(
    id: '8',
    name: 'Horton Plains',
    imageUrl:
        'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=400',
    category: 'Nature',
    rating: 4.6,
    budget: '\$\$',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Beach',
    'Heritage',
    'Nature',
    'Safari',
    'Cultural',
  ];

  List<Destination> _filtered(List<Destination> source) => source.where((d) {
    final matchCat =
        _selectedCategory == 'All' || d.category == _selectedCategory;
    final matchSearch =
        _searchQuery.isEmpty ||
        d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.category.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchCat && matchSearch;
  }).toList();

  List<Destination> _combinedDestinations(List<SavedPlace> savedPlaces) {
    final result = <Destination>[];
    final seen = <String>{};

    for (final place in savedPlaces) {
      final key = place.name.toLowerCase().trim();
      if (seen.contains(key)) continue;
      seen.add(key);
      result.add(
        Destination(
          id: place.id,
          name: place.name,
          imageUrl: place.imageUrl,
          category: place.category,
          rating: 4.9,
          budget: 'Saved',
        ),
      );
    }

    for (final destination in _sriLankaDestinations) {
      final key = destination.name.toLowerCase().trim();
      if (seen.contains(key)) continue;
      seen.add(key);
      result.add(destination);
    }

    return result;
  }

  Color _badgeColor(String cat) {
    switch (cat) {
      case 'Nature':
        return AppTheme.success;
      case 'Safari':
        return AppTheme.warning;
      case 'Heritage':
        return AppTheme.primaryLight;
      case 'Beach':
        return AppTheme.accent;
      default:
        return AppTheme.primary;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Sri Lanka',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover hidden gems and popular spots',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isLoggedIn) {
                        return Text(
                          'Your saved AI destinations appear here too.',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primary,
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign in to sync and view your saved AI destinations.',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search bar widget (your existing widget)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                onFilterTap: _showFilterSheet,
              ),
            ),

            const SizedBox(height: 16),

            // Category filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected
                              ? AppTheme.surface
                              : AppTheme.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Destinations grid
            Expanded(
              child: Consumer<SavedPlacesProvider>(
                builder: (context, savedProvider, _) {
                  if (savedProvider.lastError != null &&
                      savedProvider.savedPlaces.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          savedProvider.lastError!,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    );
                  }

                  final all = _combinedDestinations(savedProvider.savedPlaces);
                  final filtered = _filtered(all);

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No destinations found',
                        style: TextStyle(color: AppTheme.textHint),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _DestinationCard(
                      destination: filtered[i],
                      badgeColor: _badgeColor(filtered[i].category),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Budget',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: ['\$', '\$\$', '\$\$\$']
                  .map(
                    (b) => FilterChip(
                      label: Text(b),
                      onSelected: (_) => Navigator.pop(context),
                      selectedColor: const Color(0xFF008B8B).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF008B8B),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Destination Card ──────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  final Color badgeColor;

  const _DestinationCard({required this.destination, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Destination image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    destination.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Category badge (top-left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      destination.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Rating badge (bottom-right)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppTheme.gold, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          destination.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Name and budget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Budget: ${destination.budget}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
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
