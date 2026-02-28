import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/ai_suggestion_model.dart';
import '../services/gemini_service.dart';

class AISuggestionProvider extends ChangeNotifier {
  List<AISuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _error;

  // User preferences
  String _places = '';
  String _duration = '7 Days';
  String _food = '';
  String _budget = '\$800';

  // ─── GETTERS ────────────────────────────────────────────────────────
  List<AISuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get places => _places;
  String get duration => _duration;
  String get food => _food;
  String get budget => _budget;
  bool get hasSuggestions => _suggestions.isNotEmpty;

  // ─── UPDATE PREFERENCES ─────────────────────────────────────────────
  void setPlaces(String places) {
    _places = places;
    notifyListeners();
  }

  void setDuration(String duration) {
    _duration = duration;
    notifyListeners();
  }

  void setFood(String food) {
    _food = food;
    notifyListeners();
  }

  void setBudget(String budget) {
    _budget = budget;
    notifyListeners();
  }

  // ─── FETCH AI SUGGESTIONS ──────────────────────────────────────────
  Future<void> fetchSuggestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawSuggestions = await GeminiService.getPersonalizedSuggestions(
        places: _places,
        duration: _duration,
        food: _food,
        budget: _budget,
      );

      if (rawSuggestions.isEmpty) {
        _error =
            'No suggestions received. Please check your internet connection and try again.';
        _suggestions = [];
      } else {
        // Fetch real images from Wikipedia API in parallel
        final imageResults = await Future.wait(
          rawSuggestions.map((json) =>
              _fetchWikipediaImage(json['name'] ?? '')),
        );

        _suggestions = [];
        for (int i = 0; i < rawSuggestions.length; i++) {
          final json = rawSuggestions[i];
          // Use Wikipedia image if available, otherwise static fallback
          json['imageUrl'] = imageResults[i].isNotEmpty
              ? imageResults[i]
              : _getImageForPlace(
                  json['name'] ?? '', json['category'] ?? '');
          _suggestions.add(AISuggestion.fromJson(json));
        }
      }
    } catch (e) {
      _error = 'Failed to get suggestions: $e';
      _suggestions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear suggestions
  void clearSuggestions() {
    _suggestions = [];
    _error = null;
    notifyListeners();
  }

  // ─── FETCH IMAGE FROM WIKIPEDIA API (dynamic, always works) ──────
  static Future<String> _fetchWikipediaImage(String placeName) async {
    try {
      final searchTerm = '$placeName Sri Lanka';
      final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query'
        '&generator=search'
        '&gsrsearch=${Uri.encodeComponent(searchTerm)}'
        '&prop=pageimages&format=json&pithumbsize=800'
        '&gsrlimit=1&origin=*',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pages = data['query']?['pages'] as Map<String, dynamic>?;
        if (pages != null) {
          for (final page in pages.values) {
            final thumb = page['thumbnail']?['source'] as String?;
            if (thumb != null && thumb.isNotEmpty) {
              debugPrint('Wikipedia image found for $placeName: $thumb');
              return thumb;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Wikipedia image fetch failed for $placeName: $e');
    }
    return '';
  }

  // ─── STATIC FALLBACK IMAGES (used only if Wikipedia API fails) ────
  static String _getImageForPlace(String name, String category) {
    // Category-based fallback images
    final categoryImages = {
      'beach':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg/800px-Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg',
      'historical':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg/800px-Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg',
      'hiking':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Horton_Plains_World%27s_End_%282%29.jpg/800px-Horton_Plains_World%27s_End_%282%29.jpg',
      'wildlife':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/SriLankan_elephant_-_01.jpg/800px-SriLankan_elephant_-_01.jpg',
      'cultural':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Sri_Dalada_Maligawa.jpg/800px-Sri_Dalada_Maligawa.jpg',
      'surfing':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg/800px-Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg',
      'adventure':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Horton_Plains_World%27s_End_%282%29.jpg/800px-Horton_Plains_World%27s_End_%282%29.jpg',
      'nature':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/SriLankan_elephant_-_01.jpg/800px-SriLankan_elephant_-_01.jpg',
    };

    return categoryImages[category.toLowerCase()] ??
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg/800px-Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg';
  }
}
