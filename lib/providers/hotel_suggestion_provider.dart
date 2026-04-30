import 'package:flutter/foundation.dart';

import '../models/ai_suggestion_model.dart';
import '../service/ai_service.dart';

class HotelSuggestionProvider extends ChangeNotifier {
  static const String _defaultImageUrl =
      'https://upload.wikimedia.org/wikipedia/commons/5/5a/Unawatuna_beach.jpg';

  List<AISuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _error;

  String _place = '';
  String _details = '';
  String _notes = '';

  List<AISuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get place => _place;
  String get details => _details;
  String get notes => _notes;

  void setPlace(String place) {
    _place = place;
    notifyListeners();
  }

  void setDetails(String details) {
    _details = details;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  Future<void> fetchSuggestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawSuggestions = await GeminiService.getHotelSuggestions(
        place: _place,
        details: _details,
        notes: _notes,
      );

      if (rawSuggestions.isEmpty) {
        _suggestions = [];
        _error = 'No hotel suggestions received. Please try again.';
      } else {
        final usedImageUrls = <String>{};
        _suggestions = [];

        for (final rawSuggestion in rawSuggestions) {
          final json = Map<String, dynamic>.from(rawSuggestion);
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
      _error = 'Failed to get hotel suggestions: $e';
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

    final candidates = <String>[];

    final raw = (json['imageUrl'] ?? '').toString().trim();
    if (_isLikelyDirectImageUrl(raw)) {
      candidates.add(raw);
    }

    final resolved = _getExactImageForHotel(name, location);
    if (resolved.isNotEmpty) {
      candidates.add(resolved);
    }

    candidates.add(_defaultImageUrl);

    for (final candidate in candidates) {
      if (!usedImageUrls.contains(candidate)) return candidate;
    }

    return candidates.first;
  }

  static String _getExactImageForHotel(String name, String location) {
    final text = '$name $location'.toLowerCase();

    if (text.contains('ella')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg';
    }
    if (text.contains('kandy')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Sri_Dalada_Maligawa.jpg';
    }
    if (text.contains('galle') || text.contains('unawatuna')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/5/5a/Unawatuna_beach.jpg';
    }
    if (text.contains('mirissa')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg';
    }
    if (text.contains('sigiriya') || text.contains('dambulla')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/1/1f/Sigiriya_Luftbild_%2829781064900%29.jpg';
    }
    if (text.contains('colombo')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/1/14/Colombo_skyline.jpg';
    }
    if (text.contains('nuwara')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/7/7a/Tea_plantations_in_Nuwara_Eliya.jpg';
    }

    return '';
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