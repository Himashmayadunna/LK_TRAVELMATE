import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';

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
    imageUrl: 'assets/places/sigiriya_rock.jpg',
    category: 'Heritage',
    rating: 4.9,
    budget: '\$\$',
  ),
  Destination(
    id: '2',
    name: 'Mirissa Beach',
    imageUrl: 'assets/places/mirissa_beach.jpg',
    category: 'Beach',
    rating: 4.8,
    budget: '\$',
  ),
  Destination(
    id: '3',
    name: 'Temple of the Tooth',
    imageUrl: 'assets/places/temple_of_tooth.webp',
    category: 'Cultural',
    rating: 4.7,
    budget: '\$',
  ),
  Destination(
    id: '4',
    name: 'Ella Rock Train Bridge',
    imageUrl: 'assets/places/ella_rock.jpg',
    category: 'Nature',
    rating: 4.8,
    budget: '\$',
  ),
  Destination(
    id: '5',
    name: 'Yala National Park',
    imageUrl: 'assets/places/yala_national_park.webp',
    category: 'Safari',
    rating: 4.6,
    budget: '\$\$\$',
  ),
  Destination(
    id: '6',
    name: 'Unawatuna Beach',
    imageUrl: 'assets/places/unawatuna_beach.webp',
    category: 'Beach',
    rating: 4.5,
    budget: '\$',
  ),
  Destination(
    id: '7',
    name: 'Dambulla Cave Temple',
    imageUrl: 'assets/places/dambulla_cave_temple.webp',
    category: 'Heritage',
    rating: 4.7,
    budget: '\$\$',
  ),
  Destination(
    id: '8',
    name: 'Horton Plains',
    imageUrl: 'assets/places/horton_plains.webp',
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

  List<Destination> get _filtered => _sriLankaDestinations.where((d) {
    final matchCat =
        _selectedCategory == 'All' || d.category == _selectedCategory;
    final matchSearch =
        _searchQuery.isEmpty ||
        d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.category.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchCat && matchSearch;
  }).toList();

  Color _badgeColor(String cat) {
    switch (cat) {
      case 'Nature':
        return AppTheme.primaryDark;
      case 'Safari':
        return AppTheme.accent;
      case 'Heritage':
        return AppTheme.primary;
      case 'Beach':
        return AppTheme.primaryLight;
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
                separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                            color: AppTheme.cardShadow.withValues(alpha: 0.08),
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
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No destinations found',
                        style: TextStyle(color: AppTheme.textHint),
                      ),
                    )
                  : GridView.builder(
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
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _DestinationCard(
                        destination: _filtered[i],
                        badgeColor: _badgeColor(_filtered[i].category),
                      ),
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
                      selectedColor: AppTheme.primarySurface,
                      checkmarkColor: AppTheme.primary,
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
    final isAssetImage = destination.imageUrl.startsWith('assets/');

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
                  child: SizedBox.expand(
                    child: isAssetImage
                        ? Image.asset(
                            destination.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Image.network(
                            destination.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
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
                          color: AppTheme.cardShadow.withValues(alpha: 0.12),
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
