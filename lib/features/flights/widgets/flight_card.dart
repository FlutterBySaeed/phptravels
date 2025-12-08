import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/flights/models/flight_result.dart';
import 'package:phptravels/features/flights/pages/flight_details_page.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/currency_provider.dart';

class FlightCard extends StatelessWidget {
  final FlightResult flight;
  final String from;
  final String to;
  final DateTime departureDate;
  final int passengers;

  const FlightCard({
    super.key,
    required this.flight,
    required this.from,
    required this.to,
    required this.departureDate,
    required this.passengers,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightDetailsPage(
              from: from,
              to: to,
              fromCode: flight.departureCode,
              toCode: flight.arrivalCode,
              departureDate: departureDate,
              passengers: passengers,
              departureTime: flight.departureTime,
              arrivalTime: flight.arrivalTime,
              duration: flight.duration,
              airline: flight.airline,
              flightNumber: flight.flightNumber,
              flightClass: 'Economy',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Logo/Name and Badges - More Compact
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Logo and Name
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'FJ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      flight.airline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),

                // Right: Badges - More Compact
                if (flight.badges.isNotEmpty)
                  Row(
                    children: flight.badges.map((badge) {
                      final isBestValue = badge == 'Best Value';
                      final bgColor = isBestValue
                          ? const Color(0xFFFFF3E0)
                          : AppColors.primaryBlue.withOpacity(0.1);
                      final textColor = isBestValue
                          ? const Color(0xFFF57C00)
                          : AppColors.primaryBlue;

                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Middle: Times, Path, Price - More Compact
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flight Path Section
                Expanded(
                  child: Row(
                    children: [
                      // Departure
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.departureTime,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            flight.departureCode,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Arrow Line - Shorter length
                      SizedBox(
                        width: 50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 1,
                                color: Colors.grey[300],
                                width: double.infinity,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Arrival
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.arrivalTime,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            flight.arrivalCode,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Price
                Consumer<CurrencyProvider>(
                  builder: (context, currencyProvider, child) {
                    return Text(
                      currencyProvider.formatPrice(flight.rawPricePKR,
                          compact: true),
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Footer: Duration & Direct - More Compact
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 3),
                Text(
                  '${flight.duration} • ${flight.layoverInfo ?? "Direct"}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
