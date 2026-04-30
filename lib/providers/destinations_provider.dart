import 'package:flutter/material.dart';
import '../models/destination.dart';

/// Mock Destinations Provider - replaces Cloud Firestore
/// To enable Firestore later, add google-services.json and restore the original file

class DestinationsProvider extends ChangeNotifier {
  List<Destination> _destinations = [];
  bool _isLoading = false;
  String? _error;

  List<Destination> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Get only trending destinations
  List<Destination> get trendingDestinations => 
      _destinations.where((d) => d.isTrending).toList();

  DestinationsProvider() {
    _loadDestinations();
  }

  void _loadDestinations() {
    _isLoading = true;
    notifyListeners();

    // Mock data - no Firestore required
    _destinations = [
      Destination(
        id: 'sigiriya',
        name: 'Sigiriya Rock',
        imageUrl: 'assets/trending places/sigiriya.jpg',
        category: 'Heritage',
        rating: 4.8,
        budget: '\$50',
        location: 'Matale District',
        tagline: 'Ancient rock fortress',
        duration: '3-4 hours',
        description: 'UNESCO World Heritage site known as Lion Rock',
        highlights: ['Panoramic views', 'Ancient frescoes', 'Water gardens'],
        bestTime: 'Morning',
        reviewCount: 2500,
        isFeatured: true,
        isTrending: true,
      ),
      Destination(
        id: 'mirissa',
        name: 'Mirissa Beach',
        imageUrl: 'assets/trending places/mirissa.webp',
        category: 'Beach',
        rating: 4.6,
        budget: '\$30',
        location: 'Southern Province',
        tagline: 'Pristine beach paradise',
        duration: 'Full day',
        description: 'Beautiful beach with whale watching opportunities',
        highlights: ['Whale watching', 'Sunset views', 'Beach activities'],
        bestTime: 'November - April',
        reviewCount: 1800,
        isFeatured: true,
        isTrending: true,
      ),
      Destination(
        id: 'temple_tooth',
        name: 'Temple of Tooth',
        imageUrl: 'assets/trending places/templeoftooth.webp',
        category: 'Temple',
        rating: 4.7,
        budget: '\$20',
        location: 'Kandy',
        tagline: 'Sacred Buddhist site',
        duration: '1-2 hours',
        description: 'Housing the sacred tooth relic of Buddha',
        highlights: ['Sacred relic', 'Traditional architecture', 'Cultural shows'],
        bestTime: 'Year round',
        reviewCount: 3200,
        isFeatured: true,
        isTrending: true,
      ),
      Destination(
        id: 'ella',
        name: 'Ella Rock',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Ella_Rock_from_Little_Adam%27s_Peak.jpg/1280px-Ella_Rock_from_Little_Adam%27s_Peak.jpg',
        category: 'Hiking',
        rating: 4.5,
        budget: '\$15',
        location: 'Badulla District',
        tagline: 'Scenic mountain hike',
        duration: '3-4 hours',
        description: 'Popular hiking destination with stunning views',
        highlights: ['Mountain views', 'Tea plantations', 'Train ride'],
        bestTime: 'January - April',
        reviewCount: 1500,
        isFeatured: false,
        isTrending: false,
      ),
    ];

    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}