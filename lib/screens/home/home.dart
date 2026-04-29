import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/trending_places_section.dart';
import '../../providers/destinations_provider.dart';
import '../ai/ai_chat_screen.dart';
import '../ai/ai_plan_form_screen.dart';
import '../ai/place_details_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  // ─── User input controllers for AI suggestions ──────────────────
  final TextEditingController _placesController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _placesController.dispose();
    _foodController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Greeting based on time of day
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_sunny_outlined;
    return Icons.nightlight_round;
  }

  // Screen bodies for each nav tab
  void _openAIChat({String? initialPrompt}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIChatScreen(initialPrompt: initialPrompt),
      ),
    );
  }

  void _openAISuggestionsQuickAction() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AIPlanFormScreen()));
  }

  void _openPlaceDetailsQuickAction() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PlaceDetailsFormScreen()));
  }

  void _openRelatedHotelsQuickAction() {
    final placeTopic = _placesController.text.trim().isEmpty
        ? 'Sri Lanka'
        : _placesController.text.trim();

    _openAIChat(
      initialPrompt:
          'Find hotels in Sri Lanka related to these places/interests: $placeTopic. Give 5 options in this format: Hotel/Area - who it is best for - approx budget.',
    );
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
            SliverToBoxAdapter(child: _buildFeaturedHero()),
            SliverToBoxAdapter(child: _buildQuickActionsModern()),
            SliverToBoxAdapter(child: _buildQuickAccessModern()),
            SliverToBoxAdapter(child: _buildTrendingPlaces()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ─── MODERN HEADER ────────────────────────────────────────────────
  Widget _buildHeader() {
    const userName = 'Traveler';
    const userInitials = 'T';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '$_greeting, $userName',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _greetingIcon,
                      size: 16,
                      color: AppTheme.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Explore Sri Lanka',
                  style: AppTheme.headingLarge,
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Notification bell
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.textPrimary,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MODERN SEARCH BAR ────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: SearchBarWidget(
        controller: _searchController,
        onChanged: (value) {},
      ),
    );
  }

  // ─── MODERN FEATURED HERO ─────────────────────────────────────────
  Widget _buildFeaturedHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: GestureDetector(
        onTap: _openAISuggestionsQuickAction,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              boxShadow: AppTheme.mediumShadow,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(
                  'assets/Hero/hero.png',
                  fit: BoxFit.cover,
                ),
                // Overlay gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Badge and content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusRound),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AI RECOMMENDED',
                              style: AppTheme.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Discover the Pearl of\nthe Indian Ocean',
                                  style: AppTheme.headingMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 26,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Personalized just for you',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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
    );
  }

  // ─── TRENDING PLACES SECTION ──────────────────────────────────────
  Widget _buildTrendingPlaces() {
    return Consumer<DestinationsProvider>(
      builder: (context, destProvider, _) {
        final trendingPlaces = destProvider.trendingDestinations;
        return TrendingPlacesSection(
          trendingPlaces: trendingPlaces,
          onViewAll: () {
            // Navigate to explore page with trending filter
            // This can be enhanced later to show only trending places
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${trendingPlaces.length} trending places'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  // ─── MODERN QUICK ACTIONS ─────────────────────────────────────────
  Widget _buildQuickActionsModern() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildModernActionCard(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Suggestions',
                  highlighted: true,
                  onTap: _openAISuggestionsQuickAction,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernActionCard(
                  icon: Icons.info_outline_rounded,
                  label: 'Place Details',
                  onTap: _openPlaceDetailsQuickAction,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernActionCard(
                  icon: Icons.hotel_rounded,
                  label: 'Hotels',
                  onTap: _openRelatedHotelsQuickAction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        decoration: BoxDecoration(
          gradient: highlighted ? AppTheme.primaryGradient : null,
          color: highlighted ? null : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppTheme.softShadow,
          border: !highlighted
              ? Border.all(color: AppTheme.divider, width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: highlighted
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: highlighted ? Colors.white : AppTheme.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.caption.copyWith(
                color: highlighted ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MODERN QUICK ACCESS ──────────────────────────────────────────
  Widget _buildQuickAccessModern() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Access',
              style: AppTheme.headingSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore everywhere with just one tap',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAccessItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  color: AppTheme.primary,
                ),
                _buildQuickAccessItem(
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                  color: AppTheme.accent,
                ),
                _buildQuickAccessItem(
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                  color: AppTheme.purple,
                ),
                _buildQuickAccessItem(
                  icon: Icons.map_rounded,
                  label: 'Map',
                  color: AppTheme.gold,
                ),
                _buildQuickAccessItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  color: AppTheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
