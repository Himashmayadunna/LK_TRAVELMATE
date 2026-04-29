import 'package:flutter/foundation.dart';
import 'dart:async';

/// Mock Saved Places Provider - replaces Cloud Firestore
/// To enable Firestore later, add google-services.json and restore the original file

class SavedPlace {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String location;
  final DateTime? savedAt;

  SavedPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.location,
    this.savedAt,
  });
}

class SavedPlacesProvider extends ChangeNotifier {
  // Mock local storage - no Firestore required
  List<SavedPlace> _savedPlaces = [];
  bool _isLoading = false;
  String? _activeUserId;
  String? _lastError;

  List<SavedPlace> get savedPlaces => _savedPlaces;
  bool get isLoading => _isLoading;
  int get savedCount => _savedPlaces.length;
  String? get lastError => _lastError;

  static String buildPlaceId({required String name, String? location}) {
    final base =
        '${name.trim().toLowerCase()}_${(location ?? '').trim().toLowerCase()}';
    return base
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  Future<void> configureForUser(String? userId) async {
    if (_activeUserId == userId) return;

    _activeUserId = userId;
    _lastError = null;

    if (userId == null || userId.isEmpty) {
      _savedPlaces = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSavedPlaces() async {
    _savedPlaces = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSavedPlace({
    required String name,
    required String category,
    required String imageUrl,
    required String location,
  }) async {
    if (_activeUserId == null) {
      throw Exception('Please sign in to save places.');
    }

    final docId = buildPlaceId(name: name, location: location);
    if (docId.isEmpty) {
      throw Exception('Invalid place details. Please try another place.');
    }

    // Mock: just add locally
    final place = SavedPlace(
      id: docId,
      name: name,
      category: category,
      imageUrl: imageUrl,
      location: location,
      savedAt: DateTime.now(),
    );
    
    final index = _savedPlaces.indexWhere((p) => p.id == docId);
    if (index >= 0) {
      _savedPlaces[index] = place;
    } else {
      _savedPlaces.insert(0, place);
    }
    notifyListeners();
  }

  Future<void> removeSavedPlace(String id) async {
    _savedPlaces.removeWhere((place) => place.id == id);
    notifyListeners();
  }

  bool isPlaceSaved(String id) {
    return _savedPlaces.any((place) => place.id == id);
  }

  @override
  void dispose() {
    super.dispose();
  }
}