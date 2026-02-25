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
