class AISuggestion {
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final String budgetLevel;
  final double estimatedCostPerDay;
  final String bestTimeToVisit;
  final String category;
  final List<String> highlights;
  final String insiderTip;
  final List<String> foodRecommendations;
  final String howToGetThere;
  final double latitude;
  final double longitude;

  const AISuggestion({
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.budgetLevel,
    required this.estimatedCostPerDay,
    required this.bestTimeToVisit,
    required this.category,
    required this.highlights,
    required this.insiderTip,
    this.foodRecommendations = const [],
    this.howToGetThere = '',
    this.latitude = 7.8731,
    this.longitude = 80.7718,
  });

  factory AISuggestion.fromJson(Map<String, dynamic> json) {
    return AISuggestion(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      budgetLevel: json['budgetLevel'] ?? 'mid',
      estimatedCostPerDay: (json['estimatedCostPerDay'] ?? 0).toDouble(),
      bestTimeToVisit: json['bestTimeToVisit'] ?? '',
      category: json['category'] ?? '',
      highlights: List<String>.from(json['highlights'] ?? []),
      insiderTip: json['insiderTip'] ?? '',
      foodRecommendations:
          List<String>.from(json['foodRecommendations'] ?? []),
      howToGetThere: json['howToGetThere'] ?? '',
      latitude: (json['latitude'] ?? 7.8731).toDouble(),
      longitude: (json['longitude'] ?? 80.7718).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'budgetLevel': budgetLevel,
      'estimatedCostPerDay': estimatedCostPerDay,
      'bestTimeToVisit': bestTimeToVisit,
      'category': category,
      'highlights': highlights,
      'insiderTip': insiderTip,
      'foodRecommendations': foodRecommendations,
      'howToGetThere': howToGetThere,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
