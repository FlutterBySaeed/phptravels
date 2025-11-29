class HotelResult {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String mainImage;
  final List<String> thumbnailImages;
  final int starRating;
  final double reviewScore;
  final String reviewLabel;
  final double rawPricePKR;
  final List<String> amenities;
  final List<String> badges;

  HotelResult({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.mainImage,
    required this.thumbnailImages,
    required this.starRating,
    required this.reviewScore,
    required this.reviewLabel,
    required this.rawPricePKR,
    required this.amenities,
    required this.badges,
  });

  factory HotelResult.fromJson(Map<String, dynamic> json) {
    return HotelResult(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      mainImage: json['mainImage'] as String,
      thumbnailImages: List<String>.from(json['thumbnailImages'] as List),
      starRating: json['starRating'] as int,
      reviewScore: (json['reviewScore'] as num).toDouble(),
      reviewLabel: json['reviewLabel'] as String,
      rawPricePKR: (json['rawPricePKR'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List),
      badges: List<String>.from(json['badges'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'mainImage': mainImage,
      'thumbnailImages': thumbnailImages,
      'starRating': starRating,
      'reviewScore': reviewScore,
      'reviewLabel': reviewLabel,
      'rawPricePKR': rawPricePKR,
      'amenities': amenities,
      'badges': badges,
    };
  }
}
