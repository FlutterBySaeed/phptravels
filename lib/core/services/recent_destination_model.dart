class RecentDestination {
  final String city;
  final String country;
  final String? code;
  final DateTime searchedAt;

  RecentDestination({
    required this.city,
    required this.country,
    this.code,
    required this.searchedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'code': code,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  factory RecentDestination.fromJson(Map<String, dynamic> json) {
    return RecentDestination(
      city: json['city'],
      country: json['country'],
      code: json['code'],
      searchedAt: DateTime.parse(json['searchedAt']),
    );
  }
}
