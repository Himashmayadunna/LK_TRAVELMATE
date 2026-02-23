import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/destination_service.dart';

class DestinationProvider extends ChangeNotifier {
  final DestinationService _service = DestinationService();

  List<DestinationModel> _destinations = [];
  List<DestinationModel> _filteredDestinations = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // ─── GETTERS ────────────────────────────────────────────────────────
  List<DestinationModel> get destinations => _filteredDestinations;
  List<DestinationModel> get allDestinations => _destinations;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DestinationModel> get featuredDestinations =>
      _destinations.where((d) => d.rating >= 4.5).toList();

  List<DestinationModel> destinationsByBudget(String budget) =>
      _destinations.where((d) => d.budgetLevel == budget).toList();

  // ─── FETCH FROM FIRESTORE ───────────────────────────────────────────
  Future<void> fetchDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _destinations = await _service.fetchDestinations();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load destinations. Please try again.';
      // If Firestore fails, load sample data for development
      _destinations = _getSampleDestinations();
      _applyFilters();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── CATEGORY FILTER ────────────────────────────────────────────────
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // ─── SEARCH ─────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ─── APPLY FILTERS ──────────────────────────────────────────────────
  void _applyFilters() {
    _filteredDestinations = _destinations.where((dest) {
      final matchesCategory =
          _selectedCategory == 'All' || dest.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          dest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dest.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ─── SAMPLE DATA (Development fallback) ─────────────────────────────
  List<DestinationModel> _getSampleDestinations() {
    return const [
      DestinationModel(
        id: '1',
        name: 'Mirissa Beach',
        category: 'Beach',
        description:
            'A stunning crescent-shaped beach on the south coast, famous for whale watching and surfing.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg/1280px-Coconut_Tree_Hill%2C_Mirissa.jpg',
        budgetLevel: 'mid',
        rating: 4.7,
        location: 'Southern Province',
      ),
      DestinationModel(
        id: '2',
        name: 'Sigiriya Rock Fortress',
        category: 'Historical',
        description:
            'An ancient rock fortress and UNESCO World Heritage Site rising 200m above the surrounding jungle.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg/1280px-Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg',
        budgetLevel: 'mid',
        rating: 4.9,
        location: 'Matale District',
      ),
      DestinationModel(
        id: '3',
        name: 'Ella Rock',
        category: 'Hiking',
        description:
            'A breathtaking hike through tea plantations with panoramic views of the hill country.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Ella_Rock_from_Little_Adam%27s_Peak.jpg/1280px-Ella_Rock_from_Little_Adam%27s_Peak.jpg',
        budgetLevel: 'low',
        rating: 4.6,
        location: 'Badulla District',
      ),
      DestinationModel(
        id: '4',
        name: 'Yala National Park',
        category: 'Wildlife',
        description:
            'Sri Lanka\'s most famous wildlife sanctuary, home to leopards, elephants, and diverse birdlife.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Leopard_on_a_horizontal_tree_trunk.jpg/1280px-Leopard_on_a_horizontal_tree_trunk.jpg',
        budgetLevel: 'premium',
        rating: 4.8,
        location: 'Southern & Uva Provinces',
      ),
      DestinationModel(
        id: '5',
        name: 'Temple of the Sacred Tooth Relic',
        category: 'Cultural',
        description:
            'A revered Buddhist temple in Kandy housing the relic of the tooth of the Buddha.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Sri_Dalada_Maligawa.jpg/1280px-Sri_Dalada_Maligawa.jpg',
        budgetLevel: 'low',
        rating: 4.7,
        location: 'Kandy',
      ),
      DestinationModel(
        id: '6',
        name: 'Arugam Bay',
        category: 'Surfing',
        description:
            'World-renowned surfing destination on the east coast, offering consistent waves and laid-back vibes.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Arugam_Bay_beach.jpg/1280px-Arugam_Bay_beach.jpg',
        budgetLevel: 'low',
        rating: 4.5,
        location: 'Eastern Province',
      ),
      DestinationModel(
        id: '7',
        name: 'Sinharaja Forest Reserve',
        category: 'Adventure',
        description:
            'A UNESCO World Heritage rainforest teeming with endemic species and thrilling trails.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Sinharaja_Forest_Reserve.jpg/1280px-Sinharaja_Forest_Reserve.jpg',
        budgetLevel: 'mid',
        rating: 4.6,
        location: 'Sabaragamuwa Province',
      ),
      DestinationModel(
        id: '8',
        name: 'Galle Fort',
        category: 'Historical',
        description:
            'A well-preserved 16th-century Portuguese and Dutch colonial fortress overlooking the Indian Ocean.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Galle_Fort_-_Aerial_View.jpg/1280px-Galle_Fort_-_Aerial_View.jpg',
        budgetLevel: 'mid',
        rating: 4.8,
        location: 'Galle',
      ),
      DestinationModel(
        id: '9',
        name: 'Bentota Beach',
        category: 'Beach',
        description:
            'A luxurious golden beach resort area with water sports, river safaris, and premium resorts.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Bentota_Beach_Hotel.jpg/1280px-Bentota_Beach_Hotel.jpg',
        budgetLevel: 'premium',
        rating: 4.5,
        location: 'Galle District',
      ),
      DestinationModel(
        id: '10',
        name: 'Knuckles Mountain Range',
        category: 'Hiking',
        description:
            'A UNESCO heritage mountain range with misty peaks, diverse ecosystems, and challenging trails.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Knuckles_Mountain_Range.jpg/1280px-Knuckles_Mountain_Range.jpg',
        budgetLevel: 'low',
        rating: 4.4,
        location: 'Central Province',
      ),
    ];
  }
}
