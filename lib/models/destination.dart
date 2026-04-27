class Destination {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final double rating;
  final String budget;
  final String location;
  final String tagline;
  final String duration;
  final String description;
  final List<String> highlights;
  final String bestTime;
  final int reviewCount;
  final bool isFeatured;

  const Destination({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.budget,
    this.location = '',
    this.tagline = '',
    this.duration = '',
    this.description = '',
    this.highlights = const [],
    this.bestTime = '',
    this.reviewCount = 0,
    this.isFeatured = false,
  });
}