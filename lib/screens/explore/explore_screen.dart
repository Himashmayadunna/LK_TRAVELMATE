import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import 'destination_detail_screen.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class Destination {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final double rating;
  final String budget;
  final String location;
  final String tagline;
  final String duration;
  final String description;
  final List<String> highlights;
  final String bestTime;
  final int reviewCount;
  final bool isFeatured;

  const Destination({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.budget,
    required this.location,
    required this.tagline,
    required this.duration,
    required this.description,
    required this.highlights,
    required this.bestTime,
    required this.reviewCount,
    this.isFeatured = false,
  });
}

// ── Destinations ──────────────────────────────────────────────────────────────

final List<Destination> sriLankaDestinations = [
  Destination(
    id: '1',
    name: 'Sigiriya Rock Fortress',
    imageUrl:
        'https://images.unsplash.com/photo-1588598198321-9735fd52a4bf?auto=format&fit=crop&w=800&q=80',
    category: 'Heritage',
    rating: 4.9,
    budget: '\$\$',
    location: 'Matale District, Central Province',
    tagline: 'Climb a 5th-century royal citadel in the sky',
    duration: '3–4 hrs',
    description:
        'Sigiriya is a 5th-century rock fortress rising ~180 m above the jungle, '
        'built by King Kashyapa (477–495 CE) as his royal capital. '
        'Designated a UNESCO World Heritage Site in 1982, it is famous for its '
        'rock-face frescoes, lion-paw gateway, mirror wall inscriptions, and '
        'panoramic summit palace ruins.',
    highlights: [
      "Lion's Paw Gateway",
      'Rock-Face Frescoes',
      'Mirror Wall Inscriptions',
      'Summit Palace Ruins',
      'Royal Water Gardens',
    ],
    bestTime: 'November – April',
    reviewCount: 14820,
    isFeatured: true,
  ),
  Destination(
    id: '2',
    name: 'Mirissa Beach',
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    category: 'Beach',
    rating: 4.8,
    budget: '\$',
    location: 'Matara, Southern Province',
    tagline: 'Whale watching and surf on a golden crescent bay',
    duration: 'Full day',
    description:
        'Mirissa is a popular southern beach destination known for whale '
        'watching, surfing, and relaxed nightlife. It is one of the main '
        'departure points for blue whale and sperm whale marine tours '
        'between November and April.',
    highlights: [
      'Whale & Dolphin Watching',
      'Secret Beach Cove',
      'Coconut Tree Hill Sunset',
      'Snorkelling the Reef',
      'Beachfront Seafood Shacks',
    ],
    bestTime: 'November – April',
    reviewCount: 11340,
  ),
  Destination(
    id: '3',
    name: 'Temple of the Tooth',
    imageUrl:
        'https://images.unsplash.com/photo-1665752576926-4e89a2bca6f9?auto=format&fit=crop&w=800&q=80',
    category: 'Heritage',
    rating: 4.7,
    budget: '\$',
    location: 'Kandy, Central Province',
    tagline: "Sri Lanka's most sacred Buddhist shrine",
    duration: '2–3 hrs',
    description:
        'The Temple of the Tooth (Sri Dalada Maligawa) in Kandy houses the '
        'sacred tooth relic of Lord Buddha and is one of the most important '
        'religious sites for Buddhists. Daily rituals and the annual Esala '
        'Perahera festival attract pilgrims from around the world.',
    highlights: [
      'Sacred Tooth Relic',
      'Evening Puja Ceremony',
      'Kandy Lake Stroll',
      'Royal Palace Museum',
      'Traditional Kandyan Drums',
    ],
    bestTime: 'December – April',
    reviewCount: 9870,
  ),
  Destination(
    id: '4',
    name: 'Nine Arch Bridge, Ella',
    imageUrl:
        'https://images.unsplash.com/photo-1566576921686-9de898a6f5f5?auto=format&fit=crop&w=800&q=80',
    category: 'Nature',
    rating: 4.8,
    budget: '\$',
    location: 'Demodara, Badulla District',
    tagline: 'Catch a train crossing a no-steel stone arch marvel',
    duration: '2–3 hrs',
    description:
        'The Nine Arch Bridge is a colonial-era railway viaduct completed in 1921, '
        'located between Ella and Demodara stations. Built entirely from stone, '
        'brick, and cement — with no steel — after WWI diverted the allocated metal. '
        'It spans 91 m in length and stands 24 m high, set amid lush tea plantations.',
    highlights: [
      'Train-crossing Photo Spot',
      'Tea Plantation Walks',
      'Ella Rock Summit Hike',
      'Little Adams Peak',
      'Ravana Waterfall',
    ],
    bestTime: 'December – April',
    reviewCount: 10250,
  ),

  // ── SAFARI DESTINATIONS (Real-world, verified) ────────────────────────────

  Destination(
    id: '5',
    name: 'Yala National Park',
    // Sri Lankan leopard in natural habitat — real wildlife photography
    imageUrl:
        'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?auto=format&fit=crop&w=800&q=80',
    category: 'Safari',
    rating: 4.8,
    budget: '\$\$\$',
    location: 'Hambantota & Monaragala, Southern Province',
    tagline: "World's highest wild leopard density — spot the Big Cat",
    duration: 'Half/Full day',
    description:
        'Yala National Park covers 979 km² across two blocks of dry-zone '
        'scrubland, lagoons, and coastline. It holds the world\'s highest '
        'density of wild leopards — roughly one per 1.5 km² — alongside '
        'over 200 bird species, sloth bears, wild buffaloes, mugger crocodiles, '
        'and large elephant herds. Jeep safaris depart at dawn and dusk for '
        'peak wildlife activity. Block I is the most visited and wildlife-rich zone.',
    highlights: [
      'Wild Leopard Sightings (Block I)',
      'Elephant Herds at Menik Ganga',
      'Sloth Bear & Wild Buffalo',
      'Mugger Crocodile Lagoons',
      '215+ Bird Species incl. Black-necked Stork',
    ],
    bestTime: 'February – July',
    reviewCount: 15640,
    isFeatured: true,
  ),

  Destination(
    id: '5b',
    name: 'Wilpattu National Park',
    // Dense jungle waterhole with wildlife — verified Sri Lanka safari imagery
    imageUrl:
        'https://images.unsplash.com/photo-1549366021-9f761d450615?auto=format&fit=crop&w=800&q=80',
    category: 'Safari',
    rating: 4.7,
    budget: '\$\$',
    location: 'Puttalam & Mannar, North Western Province',
    tagline: "Sri Lanka's largest park — ancient lakes, leopards & bears",
    duration: 'Half/Full day',
    description:
        'Wilpattu is Sri Lanka\'s largest national park at 1,317 km², '
        'famous for its natural "willus" — flat, saucer-shaped natural lake basins '
        'that attract wildlife. Less crowded than Yala, it offers an '
        'authentic jungle safari with excellent leopard and sloth bear sightings, '
        'plus over 30 species of mammals and 200+ bird species in pristine forest.',
    highlights: [
      'Natural "Willu" Lake Basins',
      'Leopard & Sloth Bear Sightings',
      'Sri Lankan Elephant Herds',
      'Painted Stork & Pelican Colonies',
      'Uncrowded Wilderness Trails',
    ],
    bestTime: 'February – October',
    reviewCount: 7820,
  ),

  Destination(
    id: '5c',
    name: 'Minneriya National Park',
    // Elephant herd gathering — Minneriya is world-famous for "The Gathering"
    imageUrl:
        'https://images.unsplash.com/photo-1585970480901-90d6bb2a48b5?auto=format&fit=crop&w=800&q=80',
    category: 'Safari',
    rating: 4.6,
    budget: '\$\$',
    location: 'Polonnaruwa, North Central Province',
    tagline: "Witness 300+ elephants at the world's greatest land gathering",
    duration: '3–4 hrs',
    description:
        'Minneriya National Park is home to the annual "Gathering" — one of the '
        'greatest wildlife spectacles on Earth — where up to 300–400 Asian '
        'elephants congregate around the ancient Minneriya Tank reservoir as the '
        'dry season sets in. The park also shelters toque macaques, sambar deer, '
        'leopards, and over 160 bird species.',
    highlights: [
      '"The Gathering" — 300+ Elephants',
      'Minneriya Ancient Tank Views',
      'Toque Macaque Troops',
      'Painted Stork Rookeries',
      'Sambar Deer at Waterside',
    ],
    bestTime: 'July – October',
    reviewCount: 9450,
    isFeatured: true,
  ),

  Destination(
    id: '5d',
    name: 'Udawalawe National Park',
    // Elephant herd in open grassland — Udawalawe's signature landscape
    imageUrl:
        'https://images.unsplash.com/photo-1551316679-9c6ae9dec224?auto=format&fit=crop&w=800&q=80',
    category: 'Safari',
    rating: 4.7,
    budget: '\$\$',
    location: 'Sabaragamuwa & Uva Provinces',
    tagline: 'Guaranteed elephant sightings in open-grassland savanna',
    duration: 'Half day',
    description:
        'Udawalawe National Park is built around the Udawalawe Reservoir and '
        'offers some of the most reliable elephant sightings in all of Asia — '
        'with an estimated population of 600+ resident elephants. Open grasslands '
        'and scrub forest make for easy wildlife spotting, and the adjacent '
        'Elephant Transit Home rehabilitates orphaned calves back into the wild.',
    highlights: [
      '600+ Resident Wild Elephants',
      'Elephant Transit Home',
      'Water Buffalo Herds',
      'Crested Serpent Eagle',
      'Open Savanna Jeep Drives',
    ],
    bestTime: 'Year-round (Dec – Mar peak)',
    reviewCount: 11230,
  ),

  Destination(
    id: '5e',
    name: 'Kumana National Park',
    // Coastal lagoon with birds — Kumana is Sri Lanka's bird safari capital
    imageUrl:
        'https://images.unsplash.com/photo-1444464666168-49d633b86797?auto=format&fit=crop&w=800&q=80',
    category: 'Safari',
    rating: 4.5,
    budget: '\$\$',
    location: 'Ampara, Eastern Province',
    tagline: "Sri Lanka's premier bird safari — 255 species at the lagoon",
    duration: 'Half/Full day',
    description:
        'Kumana National Park (formerly Yala East) protects a 357 km² coastal '
        'wetland complex including the famous Kumana Villu — a 200-acre mangrove '
        'lagoon that hosts the largest colonial bird rookery in Sri Lanka. Over '
        '255 bird species have been recorded, including painted storks, purple '
        'herons, black-necked storks, and lesser adjutants. Leopards and elephants '
        'are also frequently spotted.',
    highlights: [
      'Kumana Villu Bird Rookery',
      '255+ Recorded Bird Species',
      'Painted Stork & Heron Colonies',
      'Leopard & Elephant Sightings',
      'Arugam Bay Surf Nearby',
    ],
    bestTime: 'April – July',
    reviewCount: 4780,
  ),

  // ── REST OF DESTINATIONS ──────────────────────────────────────────────────

  Destination(
    id: '6',
    name: 'Unawatuna Beach',
    imageUrl:
        'https://images.unsplash.com/photo-1590523277543-a94d2e4eb00b?auto=format&fit=crop&w=800&q=80',
    category: 'Beach',
    rating: 4.5,
    budget: '\$',
    location: 'Galle, Southern Province',
    tagline: 'Sheltered turquoise bay beside a UNESCO fort',
    duration: 'Full day',
    description:
        'Unawatuna is a sheltered beach near Galle known for calm waters, '
        'snorkelling, coral reefs, and easy access to Galle Fort. The '
        'horseshoe bay is ideal for swimming, with a lively strip of '
        'beachside cafés and restaurants.',
    highlights: [
      'Coral Reef Snorkelling',
      'Japanese Peace Pagoda',
      'Galle Fort Day Trip',
      'Jungle Beach Hidden Cove',
      'Beachside Restaurants',
    ],
    bestTime: 'November – April',
    reviewCount: 7430,
  ),
  Destination(
    id: '7',
    name: 'Dambulla Cave Temple',
    imageUrl:
        'https://images.unsplash.com/photo-1621777468854-a2e6e77ddbfd?auto=format&fit=crop&w=800&q=80',
    category: 'Heritage',
    rating: 4.7,
    budget: '\$\$',
    location: 'Dambulla, Central Province',
    tagline: '150+ Buddha statues and 2,000-year-old ceiling murals',
    duration: '2–3 hrs',
    description:
        'Dambulla Cave Temple is a complex of five cave shrines filled with '
        'over 150 Buddha statues and ancient ceiling frescoes spanning more than '
        "2,000 years of Buddhist art — one of Sri Lanka's best-preserved "
        'cave temple sites and a UNESCO World Heritage Site since 1991.',
    highlights: [
      '150+ Buddha Statues',
      'Ancient Ceiling Frescoes',
      'Rock Summit Panorama',
      'Golden Temple Museum',
      'Close to Sigiriya',
    ],
    bestTime: 'Year-round',
    reviewCount: 8120,
  ),
  Destination(
    id: '8',
    name: 'Horton Plains',
    imageUrl:
        'https://images.unsplash.com/photo-1549144511-f099e773c147?auto=format&fit=crop&w=800&q=80',
    category: 'Nature',
    rating: 4.6,
    budget: '\$\$',
    location: 'Nuwara Eliya, Central Province',
    tagline: "A cliff that plunges ~1,200 m into the valley below",
    duration: '4–5 hrs',
    description:
        'Horton Plains National Park is a high-altitude plateau at 2,100–2,300 m, '
        'designated a UNESCO World Heritage Site in 2010. The circular trail leads '
        "to World's End — a sheer cliff dropping ~1,200 m — and on to "
        "Baker's Falls. It is rich in endemic sambar deer and cloud forest birds.",
    highlights: [
      "World's End Sheer Cliff",
      "Baker's Falls",
      'Endemic Sambar Deer',
      'Cloud Forest Trails',
      'Sri Lanka Whistling Thrush',
    ],
    bestTime: 'January – March',
    reviewCount: 6780,
  ),
  Destination(
    id: '9',
    name: 'Galle Fort',
    imageUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
    category: 'Heritage',
    rating: 4.8,
    budget: '\$',
    location: 'Galle, Southern Province',
    tagline: 'Walk ocean ramparts of a living UNESCO town',
    duration: '3–4 hrs',
    description:
        'Galle Fort is a UNESCO World Heritage Site built by the Portuguese '
        'and later developed by the Dutch. It features colonial architecture, '
        'cobblestone streets, museums, boutique shops, and scenic '
        'ocean-facing ramparts ideal for a golden-hour stroll.',
    highlights: [
      'Rampart Sunset Walk',
      'Dutch Reformed Church',
      'Historic Lighthouse',
      'Old Dutch Hospital Bazaar',
      'Boutique Art Galleries',
    ],
    bestTime: 'November – April',
    reviewCount: 12100,
  ),
  Destination(
    id: '10',
    name: "Adam's Peak",
    imageUrl:
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
    category: 'Nature',
    rating: 4.7,
    budget: '\$',
    location: 'Ratnapura, Sabaragamuwa Province',
    tagline: 'Pre-dawn pilgrimage up 5,500 steps to a sacred peak sunrise',
    duration: '6–8 hrs',
    description:
        "Adam's Peak (Sri Pada) is a 2,243 m conical mountain revered by "
        'Buddhists, Hindus, Muslims, and Christians. Pilgrims climb ~5,500 steps '
        'by torchlight to reach the summit shrine at dawn, where the peak casts '
        'a perfect triangular shadow across the clouds — the pilgrimage season '
        'runs December to May.',
    highlights: [
      'Sacred Footprint Shrine',
      'Triangular Shadow at Dawn',
      'Night Pilgrimage Lanterns',
      'Chain-aided Summit Climb',
      'Tea Estate Viewpoints',
    ],
    bestTime: 'December – May',
    reviewCount: 9240,
  ),
  Destination(
    id: '11',
    name: 'Arugam Bay',
    imageUrl:
        'https://images.unsplash.com/photo-1502680390469-be75c86b636f?auto=format&fit=crop&w=800&q=80',
    category: 'Beach',
    rating: 4.6,
    budget: '\$',
    location: 'Ampara, Eastern Province',
    tagline: "Sri Lanka's most popular surfing destination",
    duration: 'Multi-day',
    description:
        "Arugam Bay is Sri Lanka's most popular surfing destination, "
        'attracting surfers from around the world during the east coast surf '
        'season. Main Point delivers world-class waves while the surrounding '
        'lagoons harbour elephants, leopards, and rare birds.',
    highlights: [
      'Main Point Surf Break',
      'Pottuvil Lagoon Safari',
      'Kumana Bird Sanctuary',
      'Elephant Rock Viewpoint',
      'Ancient Baobab Tree',
    ],
    bestTime: 'May – October',
    reviewCount: 7860,
  ),
  Destination(
    id: '12',
    name: 'Nuwara Eliya',
    imageUrl:
        'https://images.unsplash.com/photo-1546430498-23308b3a0dac?auto=format&fit=crop&w=800&q=80',
    category: 'Nature',
    rating: 4.5,
    budget: '\$\$',
    location: 'Nuwara Eliya, Central Province',
    tagline: "Sip Ceylon tea at the source in 'Little England'",
    duration: '1–2 days',
    description:
        'Nuwara Eliya is a hill country town known for tea plantations, '
        'colonial architecture, cool climate, and scenic landscapes including '
        'Gregory Lake and botanical gardens. Tour a working tea factory and '
        'take the famous scenic train through the misty hills.',
    highlights: [
      'Pedro Tea Factory Tour',
      'Gregory Lake Boating',
      'Hakgala Botanical Gardens',
      'Victoria Park',
      'Scenic Train to Kandy',
    ],
    bestTime: 'January – April',
    reviewCount: 8430,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Active budget filters (empty = no filter)
  final Set<String> _activeBudgets = {};

  final List<String> _categories = [
    'All',
    'Beach',
    'Heritage',
    'Nature',
    'Safari',
  ];

  // Category icons for a more visual pill design
  final Map<String, IconData> _categoryIcons = {
    'All': Icons.explore_rounded,
    'Beach': Icons.beach_access_rounded,
    'Heritage': Icons.account_balance_rounded,
    'Nature': Icons.forest_rounded,
    'Safari': Icons.camera_alt_rounded,
  };

  List<Destination> get _filtered => sriLankaDestinations.where((d) {
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

  List<Destination> get _featured =>
      sriLankaDestinations.where((d) => d.isFeatured).toList();

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
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '🇱🇰 ',
                                style: const TextStyle(fontSize: 18),
                              ),
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
                          Text(
                            '${sriLankaDestinations.length} handpicked destinations',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onFilterTap: _showFilterSheet,
                ),
              ),

              const SizedBox(height: 16),

              // ── Category chips with icons ─────────────────────────────────
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                                  ? AppTheme.primary.withOpacity(0.28)
                                  : Colors.black.withOpacity(0.05),
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

              const SizedBox(height: 12),

              // ── Results count + active budget pills ──────────────────────
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
                        onTap: () => setState(() => _activeBudgets.clear()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
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

              // ── Grid ─────────────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
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
                                  fontSize: 16, color: AppTheme.textHint),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.textHint),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                                _selectedCategory = 'All';
                                _activeBudgets.clear();
                              }),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Clear all filters'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                                pageBuilder: (_, animation, __) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: DestinationDetailScreen(
                                      destination: dest),
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 280),
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
          ),
        ),
      ),
    );
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
                // Handle
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
                        child: Text(
                          'Clear all',
                          style: TextStyle(color: AppTheme.primary),
                        ),
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
                  children: ['\$', '\$\$', '\$\$\$']
                      .map(
                        (b) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
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
                                      b == '\$'
                                          ? 'Budget'
                                          : b == '\$\$'
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
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
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
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
          // ── Image area ──────────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                // Photo
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => Container(
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
                            Colors.black.withOpacity(0.65),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Featured badge (top-left) + Category badge
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

                // Star rating — top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
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

                // Duration — bottom left over image
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 11, color: Colors.white70),
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

                // Review count — bottom right over image
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

          // ── Info section below image ────────────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination name
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

                  // Tagline
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

                  // Location + budget row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: AppTheme.primary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          destination.location.split(',').first,
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
                          color: AppTheme.primary.withOpacity(0.10),
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