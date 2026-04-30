import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../service/ai_service.dart';
import '../models/ai_suggestion_model.dart';

class AISuggestionProvider extends ChangeNotifier {
  static const String _defaultImageUrl =
      'https://upload.wikimedia.org/wikipedia/commons/1/1f/Sigiriya_Luftbild_%2829781064900%29.jpg';

  List<AISuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _error;

  String _places = '';
  String _duration = '7 Days';
  String _food = '';
  String _budget = '\$800';

  List<AISuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get places => _places;
  String get duration => _duration;
  String get food => _food;
  String get budget => _budget;
  bool get hasSuggestions => _suggestions.isNotEmpty;

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
        _suggestions = [];
        _error = 'No suggestions received. Please try again.';
      } else {
        final usedImageUrls = <String>{};
        _suggestions = [];
        for (var i = 0; i < rawSuggestions.length; i++) {
          final json = Map<String, dynamic>.from(rawSuggestions[i]);
          final imageUrl = await _resolveImageForSuggestion(
            json,
            usedImageUrls,
          );
          usedImageUrls.add(imageUrl);
          json['imageUrl'] = imageUrl;
          _suggestions.add(AISuggestion.fromJson(json));
        }
      }
    } catch (e) {
      _suggestions = [];
      _error = 'Failed to get suggestions: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
    _error = null;
    notifyListeners();
  }

  static Future<String> _resolveImageForSuggestion(
    Map<String, dynamic> json,
    Set<String> usedImageUrls,
  ) async {
    final name = (json['name'] ?? '').toString();
    final location = (json['location'] ?? '').toString();
    final category = (json['category'] ?? '').toString();

    // 1) Try image API first to get the most accurate place image.
    final apiImage = await _fetchImageFromWikipedia(
      placeName: name,
      location: location,
      usedImageUrls: usedImageUrls,
    );
    if (apiImage.isNotEmpty) return apiImage;

    // 2) Accept API-provided direct image only if valid and not already used.
    final candidates = <String>[];

    // 2) Accept API-provided direct image.
    final raw = (json['imageUrl'] ?? '').toString().trim();
    if (_isLikelyDirectImageUrl(raw)) {
      candidates.add(raw);
    }

    // 3) Deterministic known place map.
    final resolved = _getExactImageForPlace(name);
    if (resolved.isNotEmpty) {
      candidates.add(resolved);
    }

    // 4) Category fallback.
    final categoryImage = _getImageForCategory(category);
    if (categoryImage.isNotEmpty) {
      candidates.add(categoryImage);
    }

    // 5) Last-resort default (always valid).
    candidates.add(_defaultImageUrl);

    // Prefer a non-used image, but if not possible, still return a valid one.
    for (final candidate in candidates) {
      if (!usedImageUrls.contains(candidate)) return candidate;
    }
    return candidates.first;
  }

  static Future<String> _fetchImageFromWikipedia({
    required String placeName,
    required String location,
    required Set<String> usedImageUrls,
  }) async {
    if (placeName.trim().isEmpty) return '';

    final titleCandidates = <String>[
      '$placeName, Sri Lanka',
      placeName,
      if (location.trim().isNotEmpty) '$placeName, $location',
    ];

    for (final title in titleCandidates) {
      final image = await _fetchImageForTitle(title);
      if (image.isNotEmpty && !usedImageUrls.contains(image)) {
        return image;
      }
    }

    // Search fallback with Sri Lanka context to improve accuracy.
    final image = await _fetchImageFromSearch(
      '$placeName Sri Lanka',
      usedImageUrls,
    );
    if (image.isNotEmpty) return image;

    return await _fetchImageFromSearch(placeName, usedImageUrls);
  }

  static Future<String> _fetchImageForTitle(String title) async {
    try {
      final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query'
        '&format=json&origin=*'
        '&prop=pageimages'
        '&piprop=original|thumbnail'
        '&pithumbsize=1200'
        '&titles=${Uri.encodeComponent(title)}',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return '';

      final data = jsonDecode(response.body);
      final pages = data['query']?['pages'] as Map<String, dynamic>?;
      if (pages == null) return '';

      for (final page in pages.values) {
        final original = page['original']?['source']?.toString() ?? '';
        if (_isLikelyDirectImageUrl(original)) return original;

        final thumb = page['thumbnail']?['source']?.toString() ?? '';
        if (_isLikelyDirectImageUrl(thumb)) return thumb;
      }
    } catch (_) {
      return '';
    }
    return '';
  }

  static Future<String> _fetchImageFromSearch(
    String query,
    Set<String> usedImageUrls,
  ) async {
    try {
      final searchUrl = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query'
        '&format=json&origin=*'
        '&list=search'
        '&srsearch=${Uri.encodeComponent(query)}'
        '&srlimit=6',
      );

      final searchResponse =
          await http.get(searchUrl).timeout(const Duration(seconds: 8));
      if (searchResponse.statusCode != 200) return '';

      final searchData = jsonDecode(searchResponse.body);
      final results = searchData['query']?['search'] as List<dynamic>?;
      if (results == null || results.isEmpty) return '';

      for (final result in results) {
        final title = (result['title'] ?? '').toString().trim();
        if (title.isEmpty) continue;

        final image = await _fetchImageForTitle(title);
        if (image.isNotEmpty && !usedImageUrls.contains(image)) {
          return image;
        }
      }
    } catch (_) {
      return '';
    }
    return '';
  }

  static String _getExactImageForPlace(String name) {
    final n = name.toLowerCase();

    if (n.contains('unawatuna')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg/800px-Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg';
    }
    if (n.contains('mirissa')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg';
    }
    if (n.contains('sigiriya')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/1/1f/Sigiriya_Luftbild_%2829781064900%29.jpg';
    }
    if (n.contains('ella')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg';
    }
    if (n.contains('kandy')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Sri_Dalada_Maligawa.jpg';
    }
    if (n.contains('galle')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/e/e0/Galle_Fort.jpg';
    }
    if (n.contains('nuwara')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/7/7a/Tea_plantations_in_Nuwara_Eliya.jpg';
    }
    if (n.contains('yala')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/0/03/Elephant_Herd_Yala_National_Park.jpg';
    }
    if (n.contains('diyaluma')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/3/35/Diyaluma_Falls_01.jpg';
    }
    if (n.contains('bambarakanda')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/a/a9/Bambarakanda_Falls.jpg';
    }
    if (n.contains('dunhinda')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/2/2c/Dunhinda_Falls_Sri_Lanka.jpg';
    }
    if (n.contains('arugam')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/1/1c/Arugam_Bay%2C_Sri_Lanka.jpg';
    }
    if (n.contains('trincomalee')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/9/93/Marble_Beach_Trincomalee.jpg';
    }
    if (n.contains('polonnaruwa')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/5/5f/Polonnaruwa_Gal_Vihara.jpg';
    }
    if (n.contains('anuradh')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/8/8d/Ruwanwelisaya_Stupa_Anuradhapura.jpg';
    }
    if (n.contains('hikkaduwa')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/4/43/Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg';
    }

    return '';
  }

  static String _getImageForCategory(String category) {
    final normalizedCategory = category.toLowerCase();

    if (normalizedCategory.contains('beach') ||
        normalizedCategory.contains('coast') ||
        normalizedCategory.contains('surf')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/4/43/Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg';
    }
    if (normalizedCategory.contains('waterfall') ||
        normalizedCategory.contains('falls')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/3/35/Diyaluma_Falls_01.jpg';
    }
    if (normalizedCategory.contains('wildlife') ||
        normalizedCategory.contains('forest') ||
        normalizedCategory.contains('safari') ||
        normalizedCategory.contains('nature')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/0/03/Elephant_Herd_Yala_National_Park.jpg';
    }
    if (normalizedCategory.contains('cultural') ||
        normalizedCategory.contains('heritage') ||
        normalizedCategory.contains('historical') ||
        normalizedCategory.contains('temple')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Sri_Dalada_Maligawa.jpg';
    }
    if (normalizedCategory.contains('hiking') ||
        normalizedCategory.contains('hill') ||
        normalizedCategory.contains('mountain') ||
        normalizedCategory.contains('adventure')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg';
    }

    const categoryImages = {
      'beach':
        'https://upload.wikimedia.org/wikipedia/commons/4/43/Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg',
      'historical':
        'https://upload.wikimedia.org/wikipedia/commons/1/1f/Sigiriya_Luftbild_%2829781064900%29.jpg',
      'hiking':
        'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg',
      'wildlife':
        'https://upload.wikimedia.org/wikipedia/commons/0/03/Elephant_Herd_Yala_National_Park.jpg',
      'cultural':
        'https://upload.wikimedia.org/wikipedia/commons/c/c4/Sri_Dalada_Maligawa.jpg',
      'surfing':
        'https://upload.wikimedia.org/wikipedia/commons/4/43/Tropical_beach_-_Unawatuna_-_Sri_Lanka.jpg',
      'adventure':
        'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg',
      'nature':
        'https://upload.wikimedia.org/wikipedia/commons/0/03/Elephant_Herd_Yala_National_Park.jpg',
      'waterfall':
        'https://upload.wikimedia.org/wikipedia/commons/3/35/Diyaluma_Falls_01.jpg',
      'waterfalls':
        'https://upload.wikimedia.org/wikipedia/commons/3/35/Diyaluma_Falls_01.jpg',
      'forest':
        'https://upload.wikimedia.org/wikipedia/commons/0/03/Elephant_Herd_Yala_National_Park.jpg',
    };

    return categoryImages[normalizedCategory] ?? _defaultImageUrl;
  }

  static bool _isLikelyDirectImageUrl(String url) {
    if (url.isEmpty || !url.startsWith('http')) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    if (host.contains('upload.wikimedia.org')) return true;
    if (host.contains('images.unsplash.com')) return true;

    final path = uri.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp');
  }
}