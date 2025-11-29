// lib/models/api_flight_response.dart

class AviationStackResponse {
  final List<FlightData> data;
  final Pagination? pagination;

  AviationStackResponse({
    required this.data,
    this.pagination,
  });

  factory AviationStackResponse.fromJson(Map<String, dynamic> json) {
    return AviationStackResponse(
      data: (json['data'] as List?)
              ?.map((e) => FlightData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Pagination {
  final int limit;
  final int offset;
  final int count;
  final int total;

  Pagination({
    required this.limit,
    required this.offset,
    required this.count,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      limit: json['limit'] ?? 0,
      offset: json['offset'] ?? 0,
      count: json['count'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class FlightData {
  final FlightInfo? flight;
  final AirlineInfo? airline;
  final DepartureInfo? departure;
  final ArrivalInfo? arrival;
  final String? flightStatus;
  final String? flightDate;

  FlightData({
    this.flight,
    this.airline,
    this.departure,
    this.arrival,
    this.flightStatus,
    this.flightDate,
  });

  factory FlightData.fromJson(Map<String, dynamic> json) {
    return FlightData(
      flight: json['flight'] != null
          ? FlightInfo.fromJson(json['flight'] as Map<String, dynamic>)
          : null,
      airline: json['airline'] != null
          ? AirlineInfo.fromJson(json['airline'] as Map<String, dynamic>)
          : null,
      departure: json['departure'] != null
          ? DepartureInfo.fromJson(json['departure'] as Map<String, dynamic>)
          : null,
      arrival: json['arrival'] != null
          ? ArrivalInfo.fromJson(json['arrival'] as Map<String, dynamic>)
          : null,
      flightStatus: json['flight_status'] as String?,
      flightDate: json['flight_date'] as String?,
    );
  }
}

class FlightInfo {
  final String? number;
  final String? iata;
  final String? icao;

  FlightInfo({
    this.number,
    this.iata,
    this.icao,
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) {
    return FlightInfo(
      number: json['number'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
    );
  }
}

class AirlineInfo {
  final String? name;
  final String? iata;
  final String? icao;

  AirlineInfo({
    this.name,
    this.iata,
    this.icao,
  });

  factory AirlineInfo.fromJson(Map<String, dynamic> json) {
    return AirlineInfo(
      name: json['name'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
    );
  }
}

class DepartureInfo {
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? terminal;
  final String? gate;
  final String? scheduled;
  final String? estimated;
  final String? actual;

  DepartureInfo({
    this.airport,
    this.timezone,
    this.iata,
    this.icao,
    this.terminal,
    this.gate,
    this.scheduled,
    this.estimated,
    this.actual,
  });

  factory DepartureInfo.fromJson(Map<String, dynamic> json) {
    return DepartureInfo(
      airport: json['airport'] as String?,
      timezone: json['timezone'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
      terminal: json['terminal'] as String?,
      gate: json['gate'] as String?,
      scheduled: json['scheduled'] as String?,
      estimated: json['estimated'] as String?,
      actual: json['actual'] as String?,
    );
  }
}

class ArrivalInfo {
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? terminal;
  final String? gate;
  final String? scheduled;
  final String? estimated;
  final String? actual;

  ArrivalInfo({
    this.airport,
    this.timezone,
    this.iata,
    this.icao,
    this.terminal,
    this.gate,
    this.scheduled,
    this.estimated,
    this.actual,
  });

  factory ArrivalInfo.fromJson(Map<String, dynamic> json) {
    return ArrivalInfo(
      airport: json['airport'] as String?,
      timezone: json['timezone'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
      terminal: json['terminal'] as String?,
      gate: json['gate'] as String?,
      scheduled: json['scheduled'] as String?,
      estimated: json['estimated'] as String?,
      actual: json['actual'] as String?,
    );
  }
}
