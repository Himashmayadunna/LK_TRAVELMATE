import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/ai_recommendation_card.dart';
import '../../widgets/travel_plan_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/place_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/quick_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

  // Greeting based on time of day
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    return '🌙';
  }

  // Sample Data
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Beaches', 'emoji': '🏖️', 'count': 45},
    {'name': 'Hiking', 'emoji': '🥾', 'count': 32},
    {'name': 'Temples', 'emoji': '🛕', 'count': 28},
    {'name': 'Wildlife', 'emoji': '🐘', 'count': 18},
    {'name': 'Waterfalls', 'emoji': '💧', 'count': 24},
    {'name': 'Heritage', 'emoji': '🏛️', 'count': 15},
  ];

  final List<Map<String, dynamic>> _popularPlaces = [
    {
      'name': 'Sigiriya Rock',
      'location': 'Matale District',
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg/1280px-Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg',
      'rating': 4.8,
      'distance': '165 km',
      'favorite': false,
    },
    {
      'name': 'Mirissa Beach',
      'location': 'Southern Province',
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg/1280px-Coconut_Tree_Hill%2C_Mirissa.jpg',
      'rating': 4.6,
      'distance': '150 km',
      'favorite': true,
    },
    {
      'name': 'Temple of Tooth',
      'location': 'Kandy',
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Sri_Dalada_Maligawa.jpg/1280px-Sri_Dalada_Maligawa.jpg',
      'rating': 4.7,
      'distance': '115 km',
      'favorite': false,
    },
    {
      'name': 'Ella Rock',
      'location': 'Badulla District',
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Ella_Rock_from_Little_Adam%27s_Peak.jpg/1280px-Ella_Rock_from_Little_Adam%27s_Peak.jpg',
      'rating': 4.5,
      'distance': '195 km',
      'favorite': false,
    },
  ];

  final List<Map<String, dynamic>> _trendingExperiences = [
    {
      'title': 'Train Ride to Ella',
      'desc': 'Scenic railway journey through tea plantations',
      'emoji': '🚂',
      'duration': '7 hrs',
    },
    {
      'title': 'Whale Watching',
      'desc': 'Blue whale sighting in Mirissa',
      'emoji': '🐋',
      'duration': '4 hrs',
    },
    {
      'title': 'Safari Adventure',
      'desc': 'Yala National Park jeep safari',
      'emoji': '🦁',
      'duration': '5 hrs',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),
            // Search Bar
            SliverToBoxAdapter(child: _buildSearchBar()),
            // AI Recommendation Hero Card
            SliverToBoxAdapter(child: _buildAIRecommendation()),
            // Travel Plan Section
            SliverToBoxAdapter(child: _buildTravelPlan()),
            // Quick Actions
            SliverToBoxAdapter(child: _buildQuickActions()),
            // Categories
            SliverToBoxAdapter(child: _buildCategories()),
            // Popular Places
            SliverToBoxAdapter(child: _buildPopularPlaces()),
            // Trending Experiences
            SliverToBoxAdapter(child: _buildTrendingExperiences()),
            // AI Chat CTA
            SliverToBoxAdapter(child: _buildAIChatCTA()),
            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                '$_greeting $_greetingEmoji',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              const Text('Explore Sri Lanka', style: AppTheme.headingLarge),
            ],
          ),
          Row(
            children: [
              // Notification bell
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow,
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.notifications_outlined, color: AppTheme.textPrimary, size: 22),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

  // ─── SEARCH BAR ───────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SearchBarWidget(),
    );
  }

  // ─── AI RECOMMENDATION HERO ───────────────────────────────────────
  Widget _buildAIRecommendation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AIRecommendationCard(
        title: 'Discover the Pearl of\nthe Indian Ocean',
        subtitle: 'Personalized just for you',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg/1280px-Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg',
      ),
    );
  }

  // ─── TRAVEL PLAN ──────────────────────────────────────────────────
  Widget _buildTravelPlan() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          SectionHeader(
            title: 'Your Travel Plan',
            actionText: 'Edit',
            onAction: () {},
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TravelPlanCard(label: 'Interest', value: 'Beach', emoji: '🏖️'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TravelPlanCard(label: 'Budget', value: '\$800', emoji: '💰'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TravelPlanCard(label: 'Duration', value: '7 Days', emoji: '📅'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions', icon: Icons.bolt_rounded),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QuickActionButton(
                icon: Icons.auto_awesome,
                label: 'AI Plan',
                onTap: () {},
              ),
              QuickActionButton(
                icon: Icons.map_rounded,
                label: 'Map',
                onTap: () {},
              ),
              QuickActionButton(
                icon: Icons.hotel_rounded,
                label: 'Hotels',
                onTap: () {},
              ),
              QuickActionButton(
                icon: Icons.restaurant_rounded,
                label: 'Food',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CATEGORIES ───────────────────────────────────────────────────
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Categories',
              actionText: 'See All',
              onAction: () {},
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return CategoryChip(
                  name: cat['name'],
                  emoji: cat['emoji'],
                  placeCount: cat['count'],
                  isSelected: _selectedCategoryIndex == index,
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── POPULAR PLACES ───────────────────────────────────────────────
  Widget _buildPopularPlaces() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Popular Places',
              actionText: 'See All',
              onAction: () {},
              icon: Icons.local_fire_department_rounded,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _popularPlaces.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final place = _popularPlaces[index];
                return PlaceCard(
                  name: place['name'],
                  location: place['location'],
                  imageUrl: place['image'],
                  rating: place['rating'],
                  distance: place['distance'],
                  isFavorite: place['favorite'],
                  onFavorite: () {
                    setState(() {
                      _popularPlaces[index]['favorite'] =
                          !_popularPlaces[index]['favorite'];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── TRENDING EXPERIENCES ─────────────────────────────────────────
  Widget _buildTrendingExperiences() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          const SectionHeader(
            title: 'Trending Experiences',
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 14),
          ..._trendingExperiences.map((exp) => _buildExperienceTile(exp)),
        ],
      ),
    );
  }

  Widget _buildExperienceTile(Map<String, dynamic> exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Center(
              child: Text(exp['emoji'], style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp['title'], style: AppTheme.labelBold),
                const SizedBox(height: 2),
                Text(exp['desc'], style: AppTheme.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, size: 13, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  exp['duration'],
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI CHAT CTA ──────────────────────────────────────────────────
  Widget _buildAIChatCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ask AI Travel Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get personalized recommendations instantly',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ───────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.explore_rounded, 'Explore', 1),
              const SizedBox(width: 56), // Space for FAB
              _navItem(Icons.favorite_rounded, 'Saved', 2),
              _navItem(Icons.person_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.textHint,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // Open AI Chat
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
      ),
    );
  }
}
