class Destination {
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final bool isAIRecommended;

  const Destination({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
    this.isAIRecommended = false,
  });
}

// ─── EXPLORE PAGE MODEL ─────────────────────────────────────────────
class DestinationModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final String budgetLevel; // 'low', 'mid', 'premium'
  final double rating;
  final String location;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.budgetLevel,
    this.rating = 0.0,
    this.location = '',
  });

  /// Create from Firestore document snapshot
  factory DestinationModel.fromMap(Map<String, dynamic> map, String docId) {
    return DestinationModel(
      id: docId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      budgetLevel: map['budgetLevel'] ?? 'mid',
      rating: (map['rating'] ?? 0).toDouble(),
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'budgetLevel': budgetLevel,
      'rating': rating,
      'location': location,
    };
  }
}

class TravelPlan {
  final String interest;
  final String budget;
  final String duration;
  final String interestIcon;
  final String budgetIcon;
  final String durationIcon;

  const TravelPlan({
    required this.interest,
    required this.budget,
    required this.duration,
    this.interestIcon = '🏖️',
    this.budgetIcon = '💰',
    this.durationIcon = '📅',
  });
}

class CategoryItem {
  final String name;
  final String emoji;
  final int placeCount;

  const CategoryItem({
    required this.name,
    required this.emoji,
    required this.placeCount,
  });
}

class PopularPlace {
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final String distance;
  final bool isFavorite;

  const PopularPlace({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    this.isFavorite = false,
  });
}
