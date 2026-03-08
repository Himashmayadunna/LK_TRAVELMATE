
import 'package:flutter/material.dart';

// ─── DATA MODEL ───────────────────────────────────────────────
class Place {
  final int id;
  final String name;
  final String location;
  final String category;
  final String tag;
  final double rating;
  final int reviews;
  final String budget;
  final String budgetLabel;
  final String duration;
  final String photo;
  final String description;

  const Place({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.tag,
    required this.rating,
    required this.reviews,
    required this.budget,
    required this.budgetLabel,
    required this.duration,
    required this.photo,
    required this.description,
  });
}

// ─── PLACE DATA ───────────────────────────────────────────────
final List<Place> places = [
  Place(
    id: 1,
    name: 'Sigiriya Rock Fortress',
    location: 'Matale District',
    category: 'Heritage',
    tag: 'UNESCO Site',
    rating: 4.9,
    reviews: 3241,
    budget: '\$\$',
    budgetLabel: 'Budget: \$\$',
    duration: '3–4 hrs',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Sigiriya_mirror_wall.jpg/640px-Sigiriya_mirror_wall.jpg',
    description: 'Ancient palace atop a 200m volcanic rock with stunning frescoes and panoramic views.',
  ),
  Place(
    id: 2,
    name: 'Mirissa Beach',
    location: 'Southern Province',
    category: 'Beach',
    tag: 'Whale Watching',
    rating: 4.8,
    reviews: 2108,
    budget: '\$',
    budgetLabel: 'Budget: \$',
    duration: 'Full day',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Mirissa_Beach%2C_Sri_Lanka.jpg/640px-Mirissa_Beach%2C_Sri_Lanka.jpg',
    description: 'Golden crescent beach perfect for whale watching, surfing, and stunning sunsets.',
  ),
  Place(
    id: 3,
    name: 'Temple of the Tooth',
    location: 'Kandy',
    category: 'Heritage',
    tag: 'Sacred Site',
    rating: 4.7,
    reviews: 4512,
    budget: '\$',
    budgetLabel: 'Budget: \$',
    duration: '2 hrs',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Sri_Dalada_Maligawa_in_Kandy%2C_Sri_Lanka.jpg/640px-Sri_Dalada_Maligawa_in_Kandy%2C_Sri_Lanka.jpg',
    description: 'Sri Lanka\'s most sacred Buddhist shrine, home to the relic of the Buddha\'s tooth.',
  ),
  Place(
    id: 4,
    name: 'Ella Train Bridge',
    location: 'Badulla District',
    category: 'Nature',
    tag: 'Trekking',
    rating: 4.8,
    reviews: 1876,
    budget: '\$',
    budgetLabel: 'Budget: \$',
    duration: 'Half day',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Nine_Arch_Bridge_Ella.jpg/640px-Nine_Arch_Bridge_Ella.jpg',
    description: 'Iconic nine-arch bridge through misty highland tea estates with breathtaking views.',
  ),
  Place(
    id: 5,
    name: 'Yala National Park',
    location: 'Southern Province',
    category: 'Safari',
    tag: 'Wildlife',
    rating: 4.8,
    reviews: 2987,
    budget: '\$\$\$',
    budgetLabel: 'Budget: \$\$\$',
    duration: 'Half day',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Yala_National_Park_leopard.jpg/640px-Yala_National_Park_leopard.jpg',
    description: 'World\'s highest leopard density. Spot elephants, crocodiles, and exotic birds.',
  ),
  Place(
    id: 6,
    name: 'Galle Fort',
    location: 'Galle',
    category: 'Heritage',
    tag: 'Colonial',
    rating: 4.7,
    reviews: 3102,
    budget: '\$\$',
    budgetLabel: 'Budget: \$\$',
    duration: '2–3 hrs',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Galle_fort_evening.jpg/640px-Galle_fort_evening.jpg',
    description: 'Dutch colonial fort with cobblestone streets, boutique cafes, and ocean bastions.',
  ),
  Place(
    id: 7,
    name: 'Nuwara Eliya',
    location: 'Central Province',
    category: 'Nature',
    tag: 'Tea Country',
    rating: 4.6,
    reviews: 1654,
    budget: '\$\$',
    budgetLabel: 'Budget: \$\$',
    duration: '2 days',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Tea_Plantation%2C_Nuwara_Eliya%2C_Sri_Lanka.jpg/640px-Tea_Plantation%2C_Nuwara_Eliya%2C_Sri_Lanka.jpg',
    description: 'Cool highland town surrounded by rolling tea plantations and misty mountains.',
  ),
  Place(
    id: 8,
    name: 'Arugam Bay',
    location: 'Eastern Province',
    category: 'Beach',
    tag: 'Surfing',
    rating: 4.6,
    reviews: 1423,
    budget: '\$',
    budgetLabel: 'Budget: \$',
    duration: 'Full day',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Arugam_Bay_Sri_Lanka.jpg/640px-Arugam_Bay_Sri_Lanka.jpg',
    description: 'World-class surf point with laid-back vibes, warm lagoons, and stunning sunrises.',
  ),
];

const List<String> categories = ['All', 'Beach', 'Heritage', 'Nature', 'Safari'];

// ─── CATEGORY COLORS ──────────────────────────────────────────
Color categoryColor(String cat) {
  switch (cat) {
    case 'Heritage': return const Color(0xFF0d9e8a);
    case 'Beach':    return const Color(0xFF2196b0);
    case 'Nature':   return const Color(0xFF4caf7d);
    case 'Safari':   return const Color(0xFFe07b39);
    default:         return const Color(0xFF0d9e8a);
  }
}

// ─── EXPLORE SCREEN ───────────────────────────────────────────
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _search = '';
  String _activeCategory = 'All';
  String _sortBy = 'default';
  bool _showFilter = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  List<Place> get _filtered {
    List<Place> result = places.where((p) {
      final matchCat = _activeCategory == 'All' || p.category == _activeCategory;
      final q = _search.toLowerCase().trim();
      final matchSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.tag.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.budgetLabel.toLowerCase().contains(q);
      return matchCat && matchSearch;
    }).toList();

    if (_sortBy == 'rating') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'reviews') {
      result.sort((a, b) => b.reviews.compareTo(a.reviews));
    } else if (_sortBy == 'budget-asc') {
      result.sort((a, b) => a.budget.length.compareTo(b.budget.length));
    } else if (_sortBy == 'budget-desc') {
      result.sort((a, b) => b.budget.length.compareTo(a.budget.length));
    }

    return result;
  }

  void _clearAll() {
    setState(() {
      _search = '';
      _searchController.clear();
      _activeCategory = 'All';
      _sortBy = 'default';
      _showFilter = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4F4),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            _buildHeader(),

            // ── SEARCH + FILTER BUTTON ──
            _buildSearchBar(),

            // ── FILTER SHEET ──
            if (_showFilter) _buildFilterSheet(),

            // ── CATEGORY PILLS ──
            _buildCategoryPills(),

            // ── RESULTS BAR ──
            _buildResultsBar(filtered),

            // ── CARD GRID ──
            Expanded(child: _buildGrid(filtered)),
          ],
        ),
      ),

    );
  }

  // ─── HEADER ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Sri Lanka',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0f172a),
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discover hidden gems and popular spots',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _search.isNotEmpty
                      ? const Color(0xFF0d9e8a)
                      : Colors.transparent,
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _search = val),
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.grey[500],
                          onPressed: () {
                            setState(() => _search = '');
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _showFilter = !_showFilter),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _showFilter
                      ? [const Color(0xFF09867a), const Color(0xFF0d9e8a)]
                      : [const Color(0xFF0d9e8a), const Color(0xFF17c5b4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0d9e8a).withOpacity(0.38),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FILTER SHEET ───────────────────────────────────────────
  Widget _buildFilterSheet() {
    final options = [
      {'val': 'default',     'label': 'Default'},
      {'val': 'rating',      'label': '⭐ Top Rated'},
      {'val': 'reviews',     'label': '💬 Most Reviewed'},
      {'val': 'budget-asc',  'label': '💰 Cheapest'},
      {'val': 'budget-desc', 'label': '💎 Premium'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 10, 22, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort results',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isActive = _sortBy == opt['val'];
              return GestureDetector(
                onTap: () => setState(() => _sortBy = opt['val']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF0d9e8a) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: isActive
                        ? [BoxShadow(color: const Color(0xFF0d9e8a).withOpacity(0.28), blurRadius: 10)]
                        : [],
                  ),
                  child: Text(
                    opt['label']!,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORY PILLS ─────────────────────────────────────────
  Widget _buildCategoryPills() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          controller: _categoryScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 9),
          itemBuilder: (context, i) {
            final cat = categories[i];
            final isActive = _activeCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _activeCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0d9e8a) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isActive ? const Color(0xFF0d9e8a) : const Color(0xFFE5E7EB),
                    width: 1.8,
                  ),
                  boxShadow: isActive
                      ? [BoxShadow(color: const Color(0xFF0d9e8a).withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── RESULTS BAR ────────────────────────────────────────────
  Widget _buildResultsBar(List<Place> filtered) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              children: [
                TextSpan(
                  text: '${filtered.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                ),
                TextSpan(text: ' ${filtered.length == 1 ? 'destination' : 'destinations'}'),
                if (_activeCategory != 'All') TextSpan(text: ' · $_activeCategory'),
                if (_search.trim().isNotEmpty) TextSpan(text: ' for "$_search"'),
              ],
            ),
          ),
          Row(
            children: [
              if (_search.trim().isNotEmpty || _activeCategory != 'All')
                GestureDetector(
                  onTap: _clearAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F5F3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Color(0xFF0d9e8a),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFF0d9e8a), width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.map_outlined, size: 13, color: Color(0xFF0d9e8a)),
                    SizedBox(width: 4),
                    Text(
                      'Map View',
                      style: TextStyle(
                        color: Color(0xFF0d9e8a),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── GRID ───────────────────────────────────────────────────
  Widget _buildGrid(List<Place> filtered) {
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌴', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 14),
            const Text('No places found',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF374151))),
            const SizedBox(height: 6),
            Text('Try a different keyword\nor browse all categories',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: Colors.grey[500], height: 1.6)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _clearAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFF0d9e8a),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [BoxShadow(color: const Color(0xFF0d9e8a).withOpacity(0.35), blurRadius: 16)],
                ),
                child: const Text('Show All Destinations',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _PlaceCard(place: filtered[i]),
    );
  }

}

// ─── PLACE CARD ───────────────────────────────────────────────
class _PlaceCard extends StatefulWidget {
  final Place place;
  const _PlaceCard({required this.place});

  @override
  State<_PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<_PlaceCard> {
  bool _saved = false;
  bool _imgErr = false;

  @override
  Widget build(BuildContext context) {
    final col = categoryColor(widget.place.category);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGE ──
          SizedBox(
            height: 134,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo
                _imgErr
                    ? Container(
                        color: col.withOpacity(0.2),
                        child: Center(
                          child: Text(
                            widget.place.category == 'Beach' ? '🌊'
                              : widget.place.category == 'Heritage' ? '🏛️'
                              : widget.place.category == 'Nature' ? '🌿'
                              : '🐆',
                            style: const TextStyle(fontSize: 38),
                          ),
                        ),
                      )
                    : Image.network(
                        widget.place.photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _imgErr = true);
                          });
                          return const SizedBox();
                        },
                      ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.04), Colors.black.withOpacity(0.32)],
                    ),
                  ),
                ),

                // Category badge (top left)
                Positioned(
                  top: 9, left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(100)),
                    child: Text(widget.place.category,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),

                // Tag badge (top center-right)
                Positioned(
                  top: 9, right: 34,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.38),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(widget.place.tag,
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600)),
                  ),
                ),

                // Heart button (top right)
                Positioned(
                  top: 6, right: 7,
                  child: GestureDetector(
                    onTap: () => setState(() => _saved = !_saved),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 27, height: 27,
                      decoration: BoxDecoration(
                        color: _saved ? const Color(0xFFE74C3C).withOpacity(0.18) : Colors.black.withOpacity(0.32),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _saved ? Icons.favorite : Icons.favorite_border,
                        color: _saved ? const Color(0xFFE74C3C) : Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),

                // Rating badge (bottom right)
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.52),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF5A623), size: 11),
                        const SizedBox(width: 3),
                        Text(widget.place.rating.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── CARD BODY ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    widget.place.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF111827)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          widget.place.location,
                          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Description
                  Expanded(
                    child: Text(
                      widget.place.description,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[600], height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 7),

                  // Star row + reviews
                  Row(
                    children: [
                      _StarRow(rating: widget.place.rating),
                      const SizedBox(width: 4),
                      Text(
                        '(${_formatNumber(widget.place.reviews)})',
                        style: TextStyle(fontSize: 10.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // Divider
                  Divider(height: 1, color: Colors.grey[100]),
                  const SizedBox(height: 7),

                  // Budget + Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.place.budgetLabel,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 11, color: Colors.grey[400]),
                          const SizedBox(width: 3),
                          Text(widget.place.duration,
                              style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500)),
                        ],
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

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ─── STAR ROW ─────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Color(0xFFF5A623), size: 11);
        } else if (i < rating && rating % 1 >= 0.5) {
          return const Icon(Icons.star_half, color: Color(0xFFF5A623), size: 11);
        } else {
          return const Icon(Icons.star_border, color: Color(0xFFD1D5DB), size: 11);
        }
      }),
    );
  }
}