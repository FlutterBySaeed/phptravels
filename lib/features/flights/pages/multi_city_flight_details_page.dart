import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/flights/models/flight_result.dart';
import 'package:phptravels/features/flights/models/multi_city_segment.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/currency_provider.dart';
import 'package:intl/intl.dart';
import 'package:phptravels/core/services/airport_service.dart';

class MultiCityFlightDetailsPage extends StatelessWidget {
  final List<MultiCitySegment> segments;
  final Map<int, FlightResult> selectedFlights;
  final int passengers;

  const MultiCityFlightDetailsPage({
    super.key,
    required this.segments,
    required this.selectedFlights,
    required this.passengers,
  });

  String _extractCode(String location) {
    final match = RegExp(r'\(([^)]+)\)$').firstMatch(location);
    return match?.group(1) ?? location;
  }

  Future<String> _getAirportName(String code) async {
    try {
      final results = await AirportService.fetchAirports(code);
      if (results.isNotEmpty) {
        final airport = results.firstWhere(
          (a) => a['code'] == code && a['loctype'] == 'ap',
          orElse: () => results.first,
        );
        return airport['fullName'] ?? airport['city'] ?? code;
      }
    } catch (e) {
      // If API fails, return code
    }
    return code;
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var flight in selectedFlights.values) {
      total += flight.rawPricePKR;
    }
    return total;
  }

  String _getDateRange() {
    if (segments.isEmpty) return '';
    final firstDate = segments.first.date;
    final lastDate = segments.last.date;
    if (firstDate == null || lastDate == null) return '';

    final formatter = DateFormat('EEE, dd MMM');
    return '${formatter.format(firstDate)} - ${formatter.format(lastDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final totalPricePKR = _calculateTotalPrice();
    final displayPrice = currencyProvider.convertFromPKR(totalPricePKR);
    final currencySymbol = currencyProvider.currentCurrency.symbol;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Multicity, ${segments.length} flights',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _getDateRange(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book with section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'BOOK WITH:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '1 OPTIONS',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Booking option card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00A699),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'kupi.com',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '$currencySymbol ${displayPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Price',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Includes $currencySymbol 0 fee',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Itinerary section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ITINERARY',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Airline fees',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Single card with all flights and top notch
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipPath(
                      clipper: TicketClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Display each flight segment
                            ...selectedFlights.entries.map((entry) {
                              final segmentIndex = entry.key;
                              final flight = entry.value;
                              final isLast =
                                  segmentIndex == selectedFlights.length - 1;

                              return Column(
                                children: [
                                  _buildFlightSegment(
                                      context, flight, segmentIndex),
                                  if (!isLast) ...[
                                    const SizedBox(height: 16),
                                    // Layover indicator between flights
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Layover',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFlightDetailModal(BuildContext context, FlightResult flight,
      MultiCitySegment segment, int segmentIndex) {
    final fromCode = _extractCode(segment.from);
    final toCode = _extractCode(segment.to);
    final formatter = DateFormat('EEE, dd MMM');
    final dateStr = segment.date != null ? formatter.format(segment.date!) : '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipPath(
        clipper: TicketClipper(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top notch
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Flight ${segmentIndex + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Flight summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$fromCode ${flight.departureTime}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${flight.duration}  ${flight.layoverInfo ?? "Direct"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$toCode ${flight.arrivalTime}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Timeline
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Timeline with Stack for perfect alignment
                      IntrinsicHeight(
                        child: Stack(
                          children: [
                            // Vertical blue line positioned absolutely
                            Positioned(
                              left: 77,
                              top: 30,
                              bottom: 18,
                              child: Container(
                                width: 2,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            // Content Column
                            Column(
                              children: [
                                // Departure Airport
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            segment.date != null
                                                ? DateFormat('d MMM')
                                                    .format(segment.date!)
                                                : '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            flight.departureTime,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    // Blue dot
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(top: 18),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 16),
                                          FutureBuilder<String>(
                                            future: _getAirportName(fromCode),
                                            builder: (context, snapshot) {
                                              final airportName =
                                                  snapshot.data ??
                                                      '$fromCode Airport';
                                              return Text(
                                                airportName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Airline info section
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 96, top: 12, bottom: 8),
                                  child: Row(
                                    children: [
                                      // Airline logo
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            flight.airlineLogo,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              flight.airline,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${flight.flightNumber}, Economy',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Amenities icons
                                            Row(
                                              children: [
                                                Icon(Icons.restaurant,
                                                    size: 20,
                                                    color: Colors.red[300]),
                                                const SizedBox(width: 12),
                                                Icon(Icons.live_tv,
                                                    size: 20,
                                                    color: Colors.red[300]),
                                                const SizedBox(width: 12),
                                                Icon(Icons.wifi,
                                                    size: 20,
                                                    color: Colors.red[300]),
                                                const SizedBox(width: 12),
                                                Icon(Icons.usb,
                                                    size: 20,
                                                    color: Colors.red[300]),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: Colors.grey[400]),
                                    ],
                                  ),
                                ),
                                // Duration
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          flight.duration,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrival Airport
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            segment.date != null
                                                ? DateFormat('d MMM')
                                                    .format(segment.date!)
                                                : '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            flight.arrivalTime,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    // Blue dot
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(top: 18),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 16),
                                          FutureBuilder<String>(
                                            future: _getAirportName(toCode),
                                            builder: (context, snapshot) {
                                              final airportName =
                                                  snapshot.data ??
                                                      '$toCode Airport';
                                              return Text(
                                                airportName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightSegment(
      BuildContext context, FlightResult flight, int segmentIndex) {
    final segment = segments[segmentIndex];
    final fromCode = _extractCode(segment.from);
    final toCode = _extractCode(segment.to);

    return GestureDetector(
      onTap: () =>
          _showFlightDetailModal(context, flight, segment, segmentIndex),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Flight ${segmentIndex + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$fromCode → $toCode',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Flight Details
          Row(
            children: [
              // Airline Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    flight.airlineLogo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Departure
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$fromCode ${flight.departureTime}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          segment.from.split('(')[0].trim(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // Duration Arrow
                    Column(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          flight.duration,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    // Arrival
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$toCode ${flight.arrivalTime}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          segment.to.split('(')[0].trim(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Airline Name and Flight Number
          Text(
            '${flight.airline} ${flight.flightNumber}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          // Layover info if available
          if (flight.layoverInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              flight.layoverInfo!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom clipper for ticket-style card with top center notch
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = 25.0; // Bigger notch
    final notchCenterX = size.width / 2;
    path.moveTo(0, 0);
    path.lineTo(notchCenterX - notchRadius, 0);

    // Top center notch (half circle cut inward)
    path.arcToPoint(
      Offset(notchCenterX + notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Top line from notch to top right
    path.lineTo(size.width, 0);
    // Right side
    path.lineTo(size.width, size.height);
    // Bottom
    path.lineTo(0, size.height);
    // Close path back to start
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
