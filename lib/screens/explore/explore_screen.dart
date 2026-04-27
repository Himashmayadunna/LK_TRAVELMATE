import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_places_provider.dart';
import '../auth/signin.dart';
import 'destination_detail_screen.dart';
import '../../models/destination.dart';
import '../../providers/destinations_provider.dart';


// ── Screen ────────────────────────────────────────────────────────────────────

class ExploreScreen extends StatefulWidget {
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  String _searchQuery = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final Set<String> _activeBudgets = {};

  final List<String> _categories = [
    'All',
    'Beach',
    'Heritage',
    'Nature',
    'Safari',
    'Hiking',
    'Temples',
    'Waterfalls',
  ];

  final Map<String, IconData> _categoryIcons = {
    'All': Icons.explore_rounded,
    'Beach': Icons.beach_access_rounded,
    'Heritage': Icons.account_balance_rounded,
    'Nature': Icons.forest_rounded,
    'Safari': Icons.camera_alt_rounded,
    'Hiking': Icons.hiking_rounded,
    'Temples': Icons.temple_buddhist_rounded,
    'Waterfalls': Icons.water_rounded,
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Build combined list: saved AI places first, then built-in destinations
  List<Destination> _combinedDestinations(
  List<SavedPlace> savedPlaces,
  List<Destination> firestoreDests,
) {
  final result = <Destination>[];
  final seen = <String>{};

  for (final place in savedPlaces) {
    if (seen.contains(place.id)) continue;
    seen.add(place.id);
    result.add(Destination(
      id: place.id,
      name: place.name,
      imageUrl: place.imageUrl,
      category: place.category,
      rating: 4.9,
      budget: 'Saved',
      location: place.location,
    ));
  }

  for (final dest in firestoreDests) {
    if (seen.contains(dest.id)) continue;
    seen.add(dest.id);
    result.add(dest);
  }

  return result;
}
  List<Destination> _filtered(List<Destination> source) =>
      source.where((d) {
        final matchCat =
            _selectedCategory == 'All' || d.category == _selectedCategory;
        final matchSearch = _searchQuery.isEmpty ||
            d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.location.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchBudget =
            _activeBudgets.isEmpty || _activeBudgets.contains(d.budget);
        return matchCat && matchSearch && matchBudget;
      }).toList();

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
      case 'Hiking':
        return AppTheme.warning;
      case 'Temples':
        return AppTheme.primaryLight;
      case 'Waterfalls':
        return AppTheme.accent;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<DestinationsProvider>(
                  builder: (context, destProvider, _) {
                   return Consumer<SavedPlacesProvider>(
                     builder: (context, savedProvider, _) {

                      if (destProvider.isLoading && destProvider.destinations.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (destProvider.error != null) {
                        return Center(child: Text('Error: ${destProvider.error}'));
                      }

              final allDests = _combinedDestinations(savedProvider.savedPlaces, destProvider.destinations);
              final filtered = _filtered(allDests);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🇱🇰 ', style: TextStyle(fontSize: 18)),
                            const Text(
                              'Explore Sri Lanka',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Auth-aware subtitle
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            if (authProvider.isLoggedIn) {
                              return Text(
                                '${allDests.length} destinations · saved places synced',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary),
                              );
                            }
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignInScreen()),
                              ),
                              child: Text(
                                'Sign in to sync your saved AI destinations',
                                style: TextStyle(
                                  fontSize: 13,
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

                  // ── Search bar ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onFilterTap: _showFilterSheet,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Category chips ───────────────────────────────────────
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final selected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = cat);
                            _fadeController.reset();
                            _fadeController.forward();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: selected
                                      ? AppTheme.primary.withValues(alpha: 0.28)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: selected ? 10 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _categoryIcons[cat] ?? Icons.place_rounded,
                                  size: 14,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Results count + active budget pills ──────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} place${filtered.length == 1 ? '' : 's'} found',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_activeBudgets.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _activeBudgets.clear()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _activeBudgets.join(' · '),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.close,
                                      size: 12, color: AppTheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Grid ────────────────────────────────────────────────
                  Expanded(
                    child: savedProvider.isLoading &&
                            savedProvider.savedPlaces.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 52, color: AppTheme.textHint),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No destinations found',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: AppTheme.textHint),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Try adjusting your search or filters',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textHint),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () => setState(() {
                                        _searchQuery = '';
                                        _searchController.clear();
                                        _selectedCategory = 'All';
                                        _activeBudgets.clear();
                                      }),
                                      icon: const Icon(Icons.refresh_rounded,
                                          size: 16),
                                      label: const Text('Clear all filters'),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.70,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 14,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (_, i) {
                                  final dest = filtered[i];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, animation, _) =>
                                            FadeTransition(
                                          opacity: animation,
                                          child: DestinationDetailScreen(
                                              destination: dest),
                                        ),
                                        transitionDuration: const Duration(
                                            milliseconds: 280),
                                      ),
                                    ),
                                    child: _DestinationCard(
                                      destination: dest,
                                      badgeColor: _badgeColor(dest.category),
                                    ),
                                  );
                                },
                              ),
                  ),
              ],
            );
          },
        );        // closes Consumer<SavedPlacesProvider> builder
      },
    ),            // closes Consumer<DestinationsProvider>
      ),          // closes FadeTransition
    ),            // closes SafeArea
  );              // closes Scaffold
}

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppTheme.surface,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filter by Budget',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_activeBudgets.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() => _activeBudgets.clear());
                          setSheetState(() {});
                        },
                        child: Text('Clear all',
                            style: TextStyle(color: AppTheme.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Select one or more budget ranges',
                  style:
                      TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [r'$', r'$$', r'$$$']
                      .map(
                        (b) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeBudgets.contains(b)
                                      ? _activeBudgets.remove(b)
                                      : _activeBudgets.add(b);
                                });
                                setSheetState(() {});
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _activeBudgets.contains(b)
                                      ? AppTheme.primary
                                      : AppTheme.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _activeBudgets.contains(b)
                                        ? AppTheme.primary
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      b,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _activeBudgets.contains(b)
                                            ? Colors.white
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      b == r'$'
                                          ? 'Budget'
                                          : b == r'$$'
                                              ? 'Mid-range'
                                              : 'Luxury',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _activeBudgets.contains(b)
                                            ? Colors.white70
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _activeBudgets.isEmpty
                          ? 'Show All Places'
                          : 'Apply Filter${_activeBudgets.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Card widget ───────────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  final Color badgeColor;

  const _DestinationCard(
      {required this.destination, required this.badgeColor});

  String _formatReviews(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ────────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    destination.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                      ),
                      child: const Center(
                        child: Icon(Icons.landscape,
                            color: Colors.grey, size: 36),
                      ),
                    ),
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Featured + category badge (top left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (destination.isFeatured)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '★ TOP PICK',
                            style: TextStyle(
                              color: Color(0xFF7A5800),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          destination.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Star rating (top right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD700), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          destination.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Duration (bottom left)
                if (destination.duration.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 11, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          destination.duration,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Review count (bottom right)
                if (destination.reviewCount > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline,
                            size: 10, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          '${_formatReviews(destination.reviewCount)} reviews',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Info below image ──────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (destination.tagline.isNotEmpty)
                    Text(
                      destination.tagline,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: AppTheme.primary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          destination.location.isNotEmpty
                              ? destination.location.split(',').first
                              : destination.category,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          destination.budget,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}