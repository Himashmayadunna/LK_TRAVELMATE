class AISuggestion {
  final String name;
  final String location;
  final String description;
  final String category;
  final int estimatedCostPerDay;
  final String bestTimeToVisit;
  final List<String> highlights;
  final String insiderTip;
  final List<String> foodRecommendations;
  final String howToGetThere;
  final String imageUrl;

  const AISuggestion({
    required this.name,
    required this.location,
    required this.description,
    required this.category,
    required this.estimatedCostPerDay,
    required this.bestTimeToVisit,
    required this.highlights,
    required this.insiderTip,
    required this.foodRecommendations,
    required this.howToGetThere,
    required this.imageUrl,
  });

  factory AISuggestion.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? 'Sri Lanka Destination').toString();
    return AISuggestion(
      name: name,
      location: (json['location'] ?? 'Sri Lanka').toString(),
      description: (json['description'] ?? 'Beautiful location worth visiting.').toString(),
      category: (json['category'] ?? 'Travel').toString(),
      estimatedCostPerDay: _toInt(json['estimatedCostPerDay'], 50),
      bestTimeToVisit: (json['bestTimeToVisit'] ?? 'All year').toString(),
      highlights: _toStringList(json['highlights'], const ['Scenic views', 'Local culture']),
      insiderTip: (json['insiderTip'] ?? 'Visit early morning for fewer crowds.').toString(),
      foodRecommendations: _toStringList(json['foodRecommendations'], const ['Rice and curry']),
      howToGetThere: (json['howToGetThere'] ?? 'Travel by bus, train, or taxi from Colombo.').toString(),
      imageUrl: _resolveImageUrl(
        raw: json['imageUrl']?.toString(),
        placeName: name,
      ),
    );
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final match = RegExp(r'\d+').firstMatch(value);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? fallback;
      }
    }
    return fallback;
  }

  static List<String> _toStringList(dynamic value, List<String> fallback) {
    if (value is List) {
      final data = value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (data.isNotEmpty) return data;
    }
    return fallback;
  }

  static String _resolveImageUrl({
    required String? raw,
    required String placeName,
  }) {
    final normalizedRaw = raw?.trim() ?? '';
    if (_isLikelyDirectImageUrl(normalizedRaw)) return normalizedRaw;

    final n = placeName.toLowerCase();
    if (n.contains('unawatuna')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/5/5a/Unawatuna_beach.jpg';
    }
    if (n.contains('mirissa')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg';
    }
    if (n.contains('sigiriya')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg';
    }
    if (n.contains('ella')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Ella_Rock_from_Little_Adam%27s_Peak.jpg';
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
      return 'https://upload.wikimedia.org/wikipedia/commons/6/6b/Yala_National_Park%2C_Sri_Lanka.jpg';
    }

    return 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg';
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