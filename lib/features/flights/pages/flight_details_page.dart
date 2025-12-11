import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/account/pages/currency_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/currency_provider.dart';

class BookingOption {
  final String providerName;
  final String providerLogo;
  final double rawPricePKR; // Store price in PKR as base

  BookingOption({
    required this.providerName,
    required this.providerLogo,
    required this.rawPricePKR,
  });
}

class FlightDetailsPage extends StatefulWidget {
  final String from;
  final String to;
  final String fromCode;
  final String toCode;
  final DateTime departureDate;
  final int passengers;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String airline;
  final String flightNumber;
  final String flightClass;

  const FlightDetailsPage({
    super.key,
    required this.from,
    required this.to,
    required this.fromCode,
    required this.toCode,
    required this.departureDate,
    this.passengers = 1,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.airline,
    this.flightNumber = '9P580',
    this.flightClass = 'Economy',
  });

  @override
  State<FlightDetailsPage> createState() => _FlightDetailsPageState();
}

class _FlightDetailsPageState extends State<FlightDetailsPage> {
  bool _showDetails = true;
  String _selectedPriceType = 'Per Person\nIncl. fee';
  // Removed _selectedCurrency - now using CurrencyProvider
  final List<BookingOption> _bookingOptions = [
    BookingOption(
      providerName: 'phptravels',
      providerLogo: 'phptravels',
      rawPricePKR: 107416,
    ),
    BookingOption(
      providerName: 'Waya',
      providerLogo: 'waya',
      rawPricePKR: 118484,
    ),
    BookingOption(
      providerName: 'Sastaticket',
      providerLogo: 'sastaticket',
      rawPricePKR: 120986,
    ),
    BookingOption(
      providerName: 'Mytickets',
      providerLogo: 'mytickets',
      rawPricePKR: 121635,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFlightHeader(context),
                  _buildFlightTimeline(context),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildFooterBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.from} to ${widget.to}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
            ),
            Text(
              _formatSubtitle(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      actions: const [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Theme.of(context).dividerColor,
          height: 1,
        ),
      ),
    );
  }

  String _formatSubtitle() {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final date = widget.departureDate;
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month];

    return '$weekday, $day $month, ${widget.passengers} Adult${widget.passengers > 1 ? 's' : ''}';
  }

  Widget _buildFlightHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'FJ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
                      '${widget.fromCode} ${widget.departureTime}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatSubtitle().split(',')[0]}, ${_formatSubtitle().split(',')[1]}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                // Arrow with duration
                Column(
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.duration,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Arrival
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.toCode} ${widget.arrivalTime}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightTimeline(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All content is conditionally shown
          if (_showDetails) ...[
            // Departure Airport
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      '${_formatSubtitle().split(',')[0]}\n${widget.departureTime}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.fromCode} ${widget.from} Airport',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Timeline Line with airline info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 42),
                SizedBox(
                  width: 12,
                  child: Center(
                    child: Container(
                      width: 2,
                      height: 60,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      children: [
                        // Airline Logo
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.airline,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.flightNumber}, ${widget.flightClass}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
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

            // Arrival Airport
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      '${_formatSubtitle().split(',')[0]}\n${widget.arrivalTime}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Green dot for arrival
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.toCode} ${widget.to} Airport',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _showDetails ? 'Hide details' : 'Show details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showDetails
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
