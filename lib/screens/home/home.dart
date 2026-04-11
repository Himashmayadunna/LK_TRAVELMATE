import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/ai_recommendation_card.dart';
import '../../widgets/travel_plan_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/place_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/quick_action_button.dart';
import '../ai/ai_chat_screen.dart';
import '../ai/ai_suggestions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final TextEditingController _searchController = TextEditingController();

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  // ─── User input controllers for AI suggestions ──────────────────
  final TextEditingController _placesController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  String _selectedDuration = '7 Days';
  String _selectedBudget = '\$800';

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

  // Screen bodies for each nav tab
  void _openAIChat({String? initialPrompt}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIChatScreen(initialPrompt: initialPrompt),
      ),
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
            SliverToBoxAdapter(child: _buildAIRecommendation()),
            SliverToBoxAdapter(child: _buildTravelPlan()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildPopularPlaces()),
            SliverToBoxAdapter(child: _buildTrendingExperiences()),
            SliverToBoxAdapter(child: _buildAIChatCTA()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    const userName = 'Traveler';
    const userInitials = 'T';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, $userName $_greetingEmoji',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text('Explore Sri Lanka', style: AppTheme.headingLarge),
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
                child: Center(
                  child: Text(
                    userInitials,
                    style: const TextStyle(
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
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: SearchBarWidget(
      controller: _searchController,
      onChanged: (value) {
        // handle search if needed, or leave empty
      },
    ),
   );
  }

  // ─── AI RECOMMENDATION HERO ───────────────────────────────────────
  Widget _buildAIRecommendation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AIRecommendationCard(
        title: 'Discover the Pearl of\nthe Indian Ocean',
        subtitle: 'Personalized just for you',
        imageUrl: 'assets/Hero/hero.png',
        onTap: () => _openAIChat(
          initialPrompt: 'Recommend the top must-visit destinations in Sri Lanka for a first-time traveler',
        ),
      ),
    );
  }

  // ─── TRAVEL PLAN (Interactive AI Input) ────────────────────────────
  Widget _buildTravelPlan() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Plan Your Trip',
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us what you want and AI will suggest the perfect places!',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // ─── Places Input ──────────────────────────────────────
          _buildInputField(
            controller: _placesController,
            label: 'Places you want to visit',
            hint: 'e.g. Beaches, Mountains, Historical sites...',
            icon: Icons.place_rounded,
            emoji: '📍',
          ),
          const SizedBox(height: 12),

          // ─── Food Input ────────────────────────────────────────
          _buildInputField(
            controller: _foodController,
            label: 'Food you like to eat',
            hint: 'e.g. Seafood, Spicy curry, Street food...',
            icon: Icons.restaurant_rounded,
            emoji: '🍛',
          ),
          const SizedBox(height: 14),

          // ─── Duration & Budget Row ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showDurationPicker,
                  child: TravelPlanCard(
                    label: 'Duration',
                    value: _selectedDuration,
                    emoji: '📅',
                    onTap: _showDurationPicker,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _showBudgetPicker,
                  child: TravelPlanCard(
                    label: 'Budget',
                    value: _selectedBudget,
                    emoji: '💰',
                    onTap: _showBudgetPicker,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Get AI Suggestions Button ─────────────────────────
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
                  Text('✨', style: TextStyle(fontSize: 20)),
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
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── REUSABLE INPUT FIELD ─────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String emoji,
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
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          labelText: label,
          labelStyle:
              AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
          hintText: hint,
          hintStyle: AppTheme.bodyMedium
              .copyWith(color: AppTheme.textHint, fontSize: 12),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── DURATION PICKER ──────────────────────────────────────────────
  void _showDurationPicker() {
    final durations = [
      '3 Days', '5 Days', '7 Days', '10 Days', '14 Days', '21 Days'
    ];

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
            const Text('📅 Select Duration', style: AppTheme.headingSmall),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : AppTheme.primarySurface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusRound),
                      border: isSelected
                          ? null
                          : Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimary,
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

  // ─── BUDGET PICKER ────────────────────────────────────────────────
  void _showBudgetPicker() {
    final budgets = [
      '\$300',
      '\$500',
      '\$800',
      '\$1200',
      '\$2000',
      '\$3000+',
    ];

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
            const Text('💰 Select Budget', style: AppTheme.headingSmall),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : AppTheme.primarySurface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusRound),
                      border: isSelected
                          ? null
                          : Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      b,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimary,
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

  // ─── NAVIGATE TO AI SUGGESTIONS ───────────────────────────────────
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
                onTap: () => _openAIChat(
                  initialPrompt: 'Create a 7-day Sri Lanka travel itinerary for a first-time visitor with a mid-range budget',
                ),
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
      child: GestureDetector(
        onTap: () => _openAIChat(),
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
        onPressed: () => _openAIChat(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
      ),
    );
  }
}
