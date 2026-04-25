import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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

  factory SavedPlace.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return SavedPlace(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      category: (data['category'] ?? 'Travel').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      location: (data['location'] ?? 'Sri Lanka').toString(),
      savedAt: (data['savedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class SavedPlacesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SavedPlace> _savedPlaces = [];
  bool _isLoading = false;
  String? _activeUserId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _savedPlacesSub;
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
    await _savedPlacesSub?.cancel();
    _savedPlacesSub = null;

    _activeUserId = userId;
    _lastError = null;

    if (userId == null || userId.isEmpty) {
      _savedPlaces = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final collection = _collection;
    if (collection == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _savedPlacesSub = collection
        .orderBy('savedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _savedPlaces = snapshot.docs
                .map(SavedPlace.fromFirestore)
                .toList(growable: false);
            _isLoading = false;
            _lastError = null;
            notifyListeners();
          },
          onError: (Object e) {
            _isLoading = false;
            _lastError = 'Failed to sync saved places: $e';
            notifyListeners();
          },
        );
  }

  CollectionReference<Map<String, dynamic>>? get _collection {
    final userId = _activeUserId;
    if (userId == null || userId.isEmpty) return null;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_places');
  }

  Future<void> fetchSavedPlaces() async {
    final collection = _collection;
    if (collection == null) {
      _savedPlaces = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await collection
          .orderBy('savedAt', descending: true)
          .get();
      _savedPlaces = snapshot.docs
          .map(SavedPlace.fromFirestore)
          .toList(growable: false);
      _lastError = null;
    } catch (e) {
      _savedPlaces = [];
      _lastError = 'Failed to load saved places: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSavedPlace({
    required String name,
    required String category,
    required String imageUrl,
    required String location,
  }) async {
    final collection = _collection;
    if (collection == null) {
      throw Exception('Please sign in to save places.');
    }

    final docId = buildPlaceId(name: name, location: location);
    if (docId.isEmpty) {
      throw Exception('Invalid place details. Please try another place.');
    }

    try {
      await collection.doc(docId).set({
        'name': name,
        'category': category,
        'imageUrl': imageUrl,
        'location': location,
        'savedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _lastError = null;
    } catch (e) {
      _lastError = 'Failed to save place: $e';
      notifyListeners();
      throw Exception('Could not save this place to Firebase.');
    }

    final index = _savedPlaces.indexWhere((p) => p.id == docId);
    final place = SavedPlace(
      id: docId,
      name: name,
      category: category,
      imageUrl: imageUrl,
      location: location,
      savedAt: DateTime.now(),
    );
    if (index >= 0) {
      _savedPlaces[index] = place;
    } else {
      _savedPlaces.insert(0, place);
    }
    notifyListeners();
  }

  Future<void> removeSavedPlace(String id) async {
    final collection = _collection;
    if (collection != null && id.isNotEmpty) {
      try {
        await collection.doc(id).delete();
        _lastError = null;
      } catch (e) {
        _lastError = 'Failed to remove place: $e';
        notifyListeners();
        throw Exception('Could not remove this place from Firebase.');
      }
    }
    _savedPlaces.removeWhere((place) => place.id == id);
    notifyListeners();
  }

  bool isPlaceSaved(String id) {
    return _savedPlaces.any((place) => place.id == id);
  }

  @override
  void dispose() {
    _savedPlacesSub?.cancel();
    super.dispose();
  }
}
