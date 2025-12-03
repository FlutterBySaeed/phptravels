class FlightResult {
  final String airline;
  final String? airline2;
  final String departureTime;
  final String arrivalTime;
  final String departureCode;
  final String arrivalCode;
  final String duration;
  final String? layoverInfo;
  final double rawPricePKR; // Store price in PKR as base
  final List<String> badges;
  final bool isNextDay;
  final String airlineLogo;
  final String? airline2Logo;
  final String flightNumber; // Added flight number

  FlightResult({
    required this.airline,
    this.airline2,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureCode,
    required this.arrivalCode,
    required this.duration,
    this.layoverInfo,
    required this.rawPricePKR,
    this.badges = const [],
    this.isNextDay = false,
    required this.airlineLogo,
    this.airline2Logo,
    this.flightNumber = '', // Default empty string if not provided
  });
}
