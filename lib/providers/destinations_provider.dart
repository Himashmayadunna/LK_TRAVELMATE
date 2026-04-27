import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination.dart';  // ← clean import

class DestinationsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Destination> _destinations = [];
  bool _isLoading = false;
  String? _error;

  List<Destination> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DestinationsProvider() {
    _listenToDestinations();
  }

  void _listenToDestinations() {
    _isLoading = true;
    notifyListeners();

    _db
        .collection('destinations')
        .orderBy('isFeatured', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _destinations = snapshot.docs.map((doc) {
          final data = doc.data();
          return Destination(
            id: doc.id,
            name: data['name'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            category: data['category'] ?? '',
            rating: (data['rating'] ?? 0).toDouble(),
            budget: data['budget'] ?? '',
            location: data['location'] ?? '',
            tagline: data['tagline'] ?? '',
            duration: data['duration'] ?? '',
            description: data['description'] ?? '',
            highlights: List<String>.from(data['highlights'] ?? []),
            bestTime: data['bestTime'] ?? '',
            reviewCount: data['reviewCount'] ?? 0,
            isFeatured: data['isFeatured'] ?? false,
          );
        }).toList();

        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}