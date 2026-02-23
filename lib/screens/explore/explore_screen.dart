import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/section_header.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'emoji': '🌍'},
    {'name': 'Beach', 'emoji': '🏖️'},
    {'name': 'Surfing', 'emoji': '🏄'},
    {'name': 'Historical', 'emoji': '🏛️'},
    {'name': 'Hiking', 'emoji': '🥾'},
    {'name': 'Wildlife', 'emoji': '🐘'},
    {'name': 'Cultural', 'emoji': '🛕'},
    {'name': 'Adventure', 'emoji': '🧗'},
  ];

  static const List<Map<String, dynamic>> _budgetOptions = [
    {
      'label': 'Low Budget',
      'value': 'low',
      'emoji': '💰',
      'color': AppTheme.success,
      'description': 'Affordable adventures\nunder \$50/day',
    },
    {
      'label': 'Mid-Range',
      'value': 'mid',
      'emoji': '💳',
      'color': AppTheme.primary,
      'description': 'Comfortable travel\n\$50-150/day',
    },
    {
      'label': 'Premium',
      'value': 'premium',
      'emoji': '💎',
      'color': AppTheme.gold,
      'description': 'Luxury experiences\n\$150+/day',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Fetch destinations on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationProvider>().fetchDestinations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);
    final category = _categories[index]['name'] as String;
    context.read<DestinationProvider>().setCategory(category);
  }

  void _onSearchChanged(String query) {
    context.read<DestinationProvider>().setSearchQuery(query);
  }

  void _onBudgetTap(String budgetLevel) {
    // Filter by budget — set category to All and filter
    setState(() => _selectedCategoryIndex = 0);
    final provider = context.read<DestinationProvider>();
    provider.setCategory('All');
    // For now, we can show a snackbar or navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing ${_budgetLabelFromValue(budgetLevel)} destinations'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  String _budgetLabelFromValue(String value) {
    switch (value) {
      case 'low':
        return 'Low Budget';
      case 'mid':
        return 'Mid-Range';
      case 'premium':
        return 'Premium';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategoryFilter()),
            SliverToBoxAdapter(child: _buildFeaturedDestinations()),
            SliverToBoxAdapter(child: _buildBudgetSection()),
            SliverToBoxAdapter(child: _buildAllDestinations()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Places ✨',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              const Text('Explore', style: AppTheme.headingLarge),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow,
            ),
            child: const Center(
              child: Icon(Icons.filter_list_rounded,
                  color: AppTheme.textPrimary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppTheme.primaryLight, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search destinations, activities...',
                  hintStyle:
                      AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: const Icon(Icons.close_rounded,
                    color: AppTheme.textHint, size: 20),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── CATEGORY FILTER ROW ──────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => _onCategorySelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : AppTheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                  boxShadow: isSelected ? AppTheme.softShadow : null,
                  border: isSelected
                      ? null
                      : Border.all(color: AppTheme.divider, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat['emoji'] as String,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      cat['name'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── FEATURED DESTINATIONS ────────────────────────────────────────
  Widget _buildFeaturedDestinations() {
    return Consumer<DestinationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        final featured = provider.featuredDestinations;
        if (featured.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            children: [
              SectionHeader(
                title: 'Featured Destinations',
                icon: Icons.auto_awesome_rounded,
                actionText: 'See All',
                onAction: () {},
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: featured.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 240,
                      child: _buildFeaturedCard(featured[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(dynamic destination) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLarge),
                  ),
                  child: Image.network(
                    destination.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_rounded,
                            color: Colors.white54, size: 40),
                      ),
                    ),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 150,
                        color: AppTheme.primarySurface,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                // Category chip
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Text(
                      destination.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Rating
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: AppTheme.gold),
                        const SizedBox(width: 2),
                        Text(
                          destination.rating.toString(),
                          style:
                              AppTheme.labelBold.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTheme.labelBold.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppTheme.primaryLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: AppTheme.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    destination.description,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── EXPLORE BY BUDGET ────────────────────────────────────────────
  Widget _buildBudgetSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          const SectionHeader(
            title: 'Explore by Budget',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            children: _budgetOptions.map((budget) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: budget != _budgetOptions.last ? 10 : 0,
                  ),
                  child: _buildBudgetCard(budget),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget) {
    return GestureDetector(
      onTap: () => _onBudgetTap(budget['value'] as String),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color: (budget['color'] as Color).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (budget['color'] as Color).withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Text(
                  budget['emoji'] as String,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              budget['label'] as String,
              style: AppTheme.labelBold.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              budget['description'] as String,
              style: AppTheme.caption.copyWith(fontSize: 9, height: 1.3),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ─── ALL DESTINATIONS (filtered) ──────────────────────────────────
  Widget _buildAllDestinations() {
    return Consumer<DestinationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox.shrink(); // Already shown in featured
        }

        final destinations = provider.destinations;

        if (destinations.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(
              children: [
                const SectionHeader(
                  title: 'Destinations',
                  icon: Icons.place_rounded,
                ),
                const SizedBox(height: 40),
                Icon(Icons.travel_explore_rounded,
                    size: 64, color: AppTheme.textHint.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  'No destinations found',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try a different category or search term',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(
            children: [
              SectionHeader(
                title: 'Destinations',
                icon: Icons.place_rounded,
                actionText: '${destinations.length} places',
              ),
              const SizedBox(height: 14),
              ...destinations.map(
                (dest) => DestinationCard(
                  destination: dest,
                  onViewDetails: () {
                    // Navigate to destination detail
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
