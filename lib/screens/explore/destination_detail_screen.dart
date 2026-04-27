import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../models/destination.dart';
import 'package:provider/provider.dart';
import '../../providers/saved_places_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';

// ── External link model ───────────────────────────────────────────────────────

class _ExternalLink {
  final String label;
  final String subtitle;
  final String url;
  final IconData icon;
  final Color color;

  const _ExternalLink({
    required this.label,
    required this.subtitle,
    required this.url,
    required this.icon,
    required this.color,
  });
}

// ── Per-destination curated external links ────────────────────────────────────

const Map<String, List<_ExternalLink>> _destinationLinks = {
  '1': [
    // Sigiriya
    _ExternalLink(
      label: 'UNESCO World Heritage',
      subtitle: 'Official heritage listing & history',
      url: 'https://whc.unesco.org/en/list/202/',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — Sigiriya',
      subtitle: 'Official visitor guide & tips',
      url: 'https://www.srilanka.travel/sigiriya',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Central Cultural Fund',
      subtitle: 'Entry tickets & opening hours',
      url: 'https://ccf.gov.lk/',
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFF6A1B9A),
    ),
  ],
  '2': [
    // Mirissa
    _ExternalLink(
      label: 'Sri Lanka Tourism — Mirissa',
      subtitle: 'Whale watching guide & best season',
      url: 'https://www.srilanka.travel/mirissa',
      icon: Icons.sailing_rounded,
      color: Color(0xFF0277BD),
    ),
    _ExternalLink(
      label: 'Beach & Marine Guide',
      subtitle: 'Snorkelling spots & surf info',
      url: 'https://www.srilanka.travel/beaches',
      icon: Icons.beach_access_rounded,
      color: Color(0xFF00838F),
    ),
  ],
  '3': [
    // Temple of the Tooth
    _ExternalLink(
      label: 'Sri Dalada Maligawa Official',
      subtitle: 'Temple website & puja timings',
      url: 'https://www.sridaladamaligawa.lk/',
      icon: Icons.temple_buddhist_rounded,
      color: Color(0xFFE65100),
    ),
    _ExternalLink(
      label: 'UNESCO — Sacred City of Kandy',
      subtitle: 'World Heritage listing',
      url: 'https://whc.unesco.org/en/list/450/',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    ),
  ],
  '4': [
    // Nine Arch Bridge
    _ExternalLink(
      label: 'Sri Lanka Railways',
      subtitle: 'Ella train schedules & online booking',
      url: 'http://www.railway.gov.lk/',
      icon: Icons.train_rounded,
      color: Color(0xFF4527A0),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — Ella',
      subtitle: 'Ella travel guide & activities',
      url: 'https://www.srilanka.travel/ella',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
  ],
  '5': [
    // Yala
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Official park info, permits & fees',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — Yala',
      subtitle: 'Safari guide & operator listings',
      url: 'https://www.srilanka.travel/yala',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFFE65100),
    ),
    _ExternalLink(
      label: 'Leopard Trails Luxury Camps',
      subtitle: 'Award-winning tented wildlife camps',
      url: 'https://www.leopardtrails.com/',
      icon: Icons.cabin_rounded,
      color: Color(0xFF4E342E),
    ),
  ],
  '5b': [
    // Wilpattu
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Wilpattu official park info',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — Wilpattu',
      subtitle: 'Safari visitor guide',
      url: 'https://www.srilanka.travel/wilpattu',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFFE65100),
    ),
  ],
  '5c': [
    // Minneriya — The Gathering
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: '"The Gathering" details & jeep permits',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — Minneriya',
      subtitle: 'Elephant gathering travel guide',
      url: 'https://www.srilanka.travel/minneriya',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFFE65100),
    ),
  ],
  '5d': [
    // Udawalawe
    _ExternalLink(
      label: 'Elephant Transit Home',
      subtitle: 'Orphaned elephant rehabilitation sanctuary',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.volunteer_activism_rounded,
      color: Color(0xFF6A1B9A),
    ),
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Udawalawe park info & permits',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
    ),
  ],
  '5e': [
    // Kumana
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Kumana bird sanctuary & permits',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — East Coast',
      subtitle: 'Eastern province travel guide',
      url: 'https://www.srilanka.travel/',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFFE65100),
    ),
  ],
  '6': [
    // Unawatuna
    _ExternalLink(
      label: 'Sri Lanka Tourism — Beaches',
      subtitle: 'Southern beach & snorkelling guide',
      url: 'https://www.srilanka.travel/beaches',
      icon: Icons.beach_access_rounded,
      color: Color(0xFF0277BD),
    ),
  ],
  '7': [
    // Dambulla
    _ExternalLink(
      label: 'UNESCO World Heritage — Dambulla',
      subtitle: 'Cave temple official listing',
      url: 'https://whc.unesco.org/en/list/561/',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    ),
    _ExternalLink(
      label: 'Central Cultural Fund',
      subtitle: 'Tickets & opening hours',
      url: 'https://ccf.gov.lk/',
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFF6A1B9A),
    ),
  ],
  '8': [
    // Horton Plains
    _ExternalLink(
      label: "UNESCO — Central Highlands",
      subtitle: "World's End heritage listing",
      url: 'https://whc.unesco.org/en/list/1203/',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    ),
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Trail info, permit & entry fees',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
    ),
  ],
  '9': [
    // Galle Fort
    _ExternalLink(
      label: 'UNESCO — Galle Fort',
      subtitle: 'Official World Heritage listing',
      url: 'https://whc.unesco.org/en/list/451/',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    ),
    _ExternalLink(
      label: 'Galle Fort Official',
      subtitle: 'Events, map & heritage walk info',
      url: 'https://www.gallefort.com/',
      icon: Icons.fort_rounded,
      color: Color(0xFF4E342E),
    ),
  ],
  '10': [
    // Adam's Peak
    _ExternalLink(
      label: "Sri Lanka Tourism — Adam's Peak",
      subtitle: 'Pilgrimage season, routes & tips',
      url: 'https://www.srilanka.travel/adams-peak',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
  ],
  '11': [
    // Arugam Bay
    _ExternalLink(
      label: 'Sri Lanka Tourism — Arugam Bay',
      subtitle: 'Surf season, breaks & local tips',
      url: 'https://www.srilanka.travel/arugam-bay',
      icon: Icons.surfing_rounded,
      color: Color(0xFF0277BD),
    ),
  ],
  '12': [
    // Nuwara Eliya
    _ExternalLink(
      label: 'Sri Lanka Tourism — Nuwara Eliya',
      subtitle: 'Tea country & hill station guide',
      url: 'https://www.srilanka.travel/nuwara-eliya',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Railways',
      subtitle: 'Scenic Kandy–Nuwara Eliya train',
      url: 'http://www.railway.gov.lk/',
      icon: Icons.train_rounded,
      color: Color(0xFF4527A0),
    ),
  ],

  // ── Hiking ──────────────────────────────────────────────────────────────────

  'h1': [
    // Little Adam's Peak
    _ExternalLink(
      label: 'Sri Lanka Tourism — Ella',
      subtitle: 'Ella hiking guide & activities',
      url: 'https://www.srilanka.travel/ella',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Trail permits & park regulations',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF1B5E20),
    ),
  ],

  'h2': [
    // Ella Rock
    _ExternalLink(
      label: 'Sri Lanka Tourism — Ella',
      subtitle: 'Ella Rock trail guide & tips',
      url: 'https://www.srilanka.travel/ella',
      icon: Icons.hiking_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Railways',
      subtitle: 'Ella train schedules — combine with Nine Arch',
      url: 'http://www.railway.gov.lk/',
      icon: Icons.train_rounded,
      color: Color(0xFF4527A0),
    ),
  ],

  'h3': [
    // Knuckles Mountain Range
    _ExternalLink(
      label: 'UNESCO — Central Highlands',
      subtitle: 'Knuckles World Heritage listing',
      url: 'https://whc.unesco.org/en/list/1203/',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    ),
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Knuckles trail permits & regulations',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — Hill Country',
      subtitle: 'Central highlands travel guide',
      url: 'https://www.srilanka.travel/',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF00695C),
    ),
  ],

  'h4': [
    // Pidurutalagala
    _ExternalLink(
      label: 'Sri Lanka Tourism — Nuwara Eliya',
      subtitle: 'Hill country hiking & travel guide',
      url: 'https://www.srilanka.travel/nuwara-eliya',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Nuwara Eliya Police',
      subtitle: 'Summit access permit enquiries',
      url: 'https://www.police.lk/',
      icon: Icons.local_police_rounded,
      color: Color(0xFF1565C0),
    ),
  ],

  // ── Temples ──────────────────────────────────────────────────────────────────

  't1': [
    // Kelaniya Raja Maha Vihara
    _ExternalLink(
      label: 'Kelaniya Temple Official',
      subtitle: 'Official temple website & puja times',
      url: 'https://kelaniyatemple.lk/',
      icon: Icons.temple_buddhist_rounded,
      color: Color(0xFFE65100),
    ),
    _ExternalLink(
      label: 'Sri Lanka Tourism — Colombo',
      subtitle: 'Colombo region travel guide',
      url: 'https://www.srilanka.travel/colombo',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
  ],

  't2': [
    // Embekke Devale
    _ExternalLink(
      label: 'Sri Lanka Tourism — Kandy',
      subtitle: 'Kandy day trips & temple guide',
      url: 'https://www.srilanka.travel/kandy',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Central Cultural Fund',
      subtitle: 'Heritage site entry & opening hours',
      url: 'https://ccf.gov.lk/',
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFF6A1B9A),
    ),
  ],

  't3': [
    // Kataragama Maha Devale
    _ExternalLink(
      label: 'Sri Lanka Tourism — Kataragama',
      subtitle: 'Pilgrimage guide & festival calendar',
      url: 'https://www.srilanka.travel/kataragama',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Dept. of Wildlife Conservation',
      subtitle: 'Yala National Park nearby — plan a safari',
      url: 'https://www.dwc.gov.lk/',
      icon: Icons.park_rounded,
      color: Color(0xFFE65100),
    ),
  ],

  't4': [
    // Thuparamaya Stupa
    _ExternalLink(
      label: 'UNESCO — Sacred City of Anuradhapura',
      subtitle: 'World Heritage listing & site map',
      url: 'https://whc.unesco.org/en/list/200/',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    ),
    _ExternalLink(
      label: 'Central Cultural Fund',
      subtitle: 'Anuradhapura tickets & opening hours',
      url: 'https://ccf.gov.lk/',
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFF6A1B9A),
    ),
  ],

  // ── Waterfalls ───────────────────────────────────────────────────────────────

  'w1': [
    // Bambarakanda Falls
    _ExternalLink(
      label: 'Sri Lanka Tourism — Waterfalls',
      subtitle: 'Waterfall travel guide & visitor tips',
      url: 'https://www.srilanka.travel/',
      icon: Icons.water_rounded,
      color: Color(0xFF0277BD),
    ),
  ],

  'w2': [
    // Diyaluma Falls
    _ExternalLink(
      label: 'Sri Lanka Tourism — Ella Region',
      subtitle: 'Ella & surrounds travel guide',
      url: 'https://www.srilanka.travel/ella',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
  ],

  'w3': [
    // Rawana Falls
    _ExternalLink(
      label: 'Sri Lanka Tourism — Ella',
      subtitle: 'Ella attractions & visitor guide',
      url: 'https://www.srilanka.travel/ella',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
    _ExternalLink(
      label: 'Sri Lanka Railways',
      subtitle: 'Ella train — combine with falls visit',
      url: 'http://www.railway.gov.lk/',
      icon: Icons.train_rounded,
      color: Color(0xFF4527A0),
    ),
  ],

  'w4': [
    // Aberdeen Falls
    _ExternalLink(
      label: 'Sri Lanka Tourism — Hill Country',
      subtitle: 'Hatton & Nuwara Eliya travel guide',
      url: 'https://www.srilanka.travel/nuwara-eliya',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF2E7D32),
    ),
  ],
};

// ── Screen ────────────────────────────────────────────────────────────────────

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Color _categoryColor(String cat) {
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

  String _formatReviews(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k reviews';
    }
    return '$count reviews';
  }

  Future<void> _launchUrl(String rawUrl, String label) async {
    final uri = Uri.parse(rawUrl);
    final able = await canLaunchUrl(uri);
    if (!able) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open "$label". Check your connection.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dest = widget.destination;
    final savedProvider = context.watch<SavedPlacesProvider>();
    final isSaved = savedProvider.isPlaceSaved(dest.id);
    final catColor = _categoryColor(dest.category);

    final links =
        _destinationLinks[dest.id] ??
        const [
          _ExternalLink(
            label: 'Sri Lanka Tourism Board',
            subtitle: 'Official national tourism portal',
            url: 'https://www.srilanka.travel/',
            icon: Icons.public_rounded,
            color: Color(0xFF00695C),
          ),
        ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            // ── Hero SliverAppBar ───────────────────────────────────────
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: AppTheme.primary,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isLoggedIn) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Row(
                            children: [
                              Icon(
                                Icons.bookmark_rounded,
                                color: AppTheme.primary,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Sign In to Save',
                                style: AppTheme.headingSmall,
                              ),
                            ],
                          ),
                          content: const Text(
                            'Create a free account to save your favourite destinations and access them anytime from your profile.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Maybe Later'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    final provider = context.read<SavedPlacesProvider>();
                    final alreadySaved = provider.isPlaceSaved(dest.id);
                    if (alreadySaved) {
                      provider.removeSavedPlace(dest.id);
                    } else {
                      provider.addSavedPlace(
                        name: dest.name,
                        category: dest.category,
                        imageUrl: dest.imageUrl,
                        location: dest.location,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              alreadySaved
                                  ? Icons.bookmark_remove_outlined
                                  : Icons.bookmark_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              alreadySaved
                                  ? 'Removed from saved places.'
                                  : '${dest.name} saved!',
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: isSaved ? const Color(0xFFFFD700) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  dest.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
                titlePadding: const EdgeInsets.fromLTRB(16, 0, 60, 14),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      dest.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(color: Colors.grey.shade300),
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey.shade300),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0x99000000),
                          ],
                          stops: const [0.45, 1.0],
                        ),
                      ),
                    ),
                    if (dest.isFeatured)
                      Positioned(
                        top: 56,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Color(0xFF7A5800),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'TOP PICK',
                                style: TextStyle(
                                  color: Color(0xFF7A5800),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Body ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest.tagline,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(label: dest.category, color: catColor),
                        _Badge(
                          label: 'Budget: ${dest.budget}',
                          color: AppTheme.primary,
                        ),
                        _Badge(
                          label:
                              '★ ${dest.rating.toStringAsFixed(1)}  ·  ${_formatReviews(dest.reviewCount)}',
                          color: const Color(0xFFFFD700),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: () => _launchUrl(
                        'https://maps.google.com/?q=${Uri.encodeComponent('${dest.name}, Sri Lanka')}',
                        'Google Maps',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 15,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                dest.location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 13,
                              color: AppTheme.primary.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      dest.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.access_time_rounded,
                            label: 'Duration',
                            value: dest.duration,
                            color: catColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.wb_sunny_outlined,
                            label: 'Best Time',
                            value: dest.bestTime,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _SectionHeader(title: 'Highlights', color: catColor),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.cardShadow,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: dest.highlights
                            .asMap()
                            .entries
                            .map(
                              (e) => Column(
                                children: [
                                  ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 2,
                                    ),
                                    leading: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: catColor,
                                      ),
                                    ),
                                    title: Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (e.key < dest.highlights.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 66,
                                      endIndent: 16,
                                      color: Colors.grey.shade100,
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _SectionHeader(
                      title: 'Explore Further',
                      subtitle: 'Trusted official resources & links',
                      color: catColor,
                    ),
                    const SizedBox(height: 14),

                    ...links.asMap().entries.map((entry) {
                      final i = entry.key;
                      final link = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i < links.length - 1 ? 10 : 0,
                        ),
                        child: _LinkCard(
                          link: link,
                          onTap: () => _launchUrl(link.url, link.label),
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    _LinkCard(
                      link: const _ExternalLink(
                        label: 'Sri Lanka Tourism — Official Portal',
                        subtitle: 'srilanka.travel  ·  Plan your complete trip',
                        url: 'https://www.srilanka.travel/',
                        icon: Icons.public_rounded,
                        color: Color(0xFF00695C),
                      ),
                      onTap: () => _launchUrl(
                        'https://www.srilanka.travel/',
                        'Sri Lanka Tourism',
                      ),
                      isProminent: true,
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(
                              'https://maps.google.com/?q=${Uri.encodeComponent('${dest.name}, Sri Lanka')}',
                              'Google Maps',
                            ),
                            icon: const Icon(Icons.map_outlined, size: 17),
                            label: const Text('Map'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: BorderSide(color: AppTheme.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Add share_plus for real sharing!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share_outlined, size: 17),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: BorderSide(color: AppTheme.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _launchUrl(links.first.url, 'Plan My Visit'),
                            icon: const Icon(
                              Icons.travel_explore_rounded,
                              size: 18,
                            ),
                            label: const Text('Plan My Visit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        'Tapping links opens official external websites',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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

// ── _LinkCard ─────────────────────────────────────────────────────────────────

class _LinkCard extends StatelessWidget {
  final _ExternalLink link;
  final VoidCallback onTap;
  final bool isProminent;

  const _LinkCard({
    required this.link,
    required this.onTap,
    this.isProminent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isProminent
              ? link.color.withValues(alpha: 0.07)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isProminent
                ? link.color.withValues(alpha: 0.3)
                : Colors.grey.shade100,
            width: isProminent ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: link.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(link.icon, color: link.color, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isProminent ? link.color : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    link.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: link.color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _SectionHeader ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: subtitle != null ? 38 : 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 1),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── _Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color == const Color(0xFFFFD700)
              ? const Color(0xFFB8860B)
              : color,
        ),
      ),
    );
  }
}

// ── _InfoCard ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}