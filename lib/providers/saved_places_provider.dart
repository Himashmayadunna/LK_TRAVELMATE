import 'package:flutter/foundation.dart';

class SavedPlace {
  final String id;
  final String name;
  final String category;
  final String imageUrl;

  SavedPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
  });
}

class SavedPlacesProvider extends ChangeNotifier {
  List<SavedPlace> _savedPlaces = [];
  bool _isLoading = false;

  List<SavedPlace> get savedPlaces => _savedPlaces;
  bool get isLoading => _isLoading;
  int get savedCount => _savedPlaces.length;

  Future<void> fetchSavedPlaces() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Sample data - replace with actual API call
    _savedPlaces = [
      SavedPlace(
        id: '1',
        name: 'Sigiriya Rock Fortress',
        category: 'Historical',
        imageUrl: 'https://example.com/sigiriya.jpg',
      ),
      SavedPlace(
        id: '2',
        name: 'Temple of the Tooth',
        category: 'Religious',
        imageUrl: 'https://example.com/temple.jpg',
      ),
      SavedPlace(
        id: '3',
        name: 'Yala National Park',
        category: 'Nature',
        imageUrl: 'https://example.com/yala.jpg',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void addSavedPlace(SavedPlace place) {
    _savedPlaces.add(place);
    notifyListeners();
  }

  void removeSavedPlace(String id) {
    _savedPlaces.removeWhere((place) => place.id == id);
    notifyListeners();
  }

  bool isPlaceSaved(String id) {
    return _savedPlaces.any((place) => place.id == id);
  }
}
