import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/THEMES/app_theme.dart';
import 'package:phptravels/PAGES/flight_details_page.dart';
import 'package:phptravels/PAGES/currency_settings.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/currency_provider.dart';
import 'package:phptravels/SERVICES/flight_api_service.dart';

import 'package:phptravels/models/flight_result.dart';

class FlightsResultsPage extends StatefulWidget {
  final String from;
  final String to;
  final DateTime departureDate;
  final int passengers;

  const FlightsResultsPage({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
    this.passengers = 1,
  });

  @override
  State<FlightsResultsPage> createState() => _FlightsResultsPageState();
}

class _FlightsResultsPageState extends State<FlightsResultsPage> {
  // --- Top Bar States ---
  String _selectedPriceType = 'Per Person\nIncl. fee';
  // Removed _selectedCurrency - now using CurrencyProvider

  // --- Filter States ---
  String _selectedSortOption = 'Recommended';
  RangeValues _priceRange = const RangeValues(24474, 34016);
  RangeValues _departTimeRange = const RangeValues(0, 24);
  RangeValues _arriveTimeRange = const RangeValues(0, 24);
  bool _hideArrivalTime = false;

  // Mock Airline Filters
  final Map<String, bool> _airlineFilters = {
    'Airblue': false,
    'Fly Jinnah': false,
    'Pakistan International Airlines': false,
  };

  // Data States
  bool _isLoading = true;
  String? _errorMessage;
  List<FlightResult> _flights = [];
  List<FlightResult> _originalFlights = [];

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final flights = await FlightAPIService.searchFlights(
        fromIATA:
            widget.from, // Assuming these are IATA codes like 'LHE', 'KHI'
        toIATA: widget.to,
        date: widget.departureDate,
      );

      if (mounted) {
        setState(() {
          _flights = flights;
          _originalFlights = List.from(flights);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load flights. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.alertCircle,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchFlights,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _flights.isEmpty
                        ? Center(
                            child: Text(
                              'No flights found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            itemCount: _flights.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child:
                                    _buildFlightCard(context, _flights[index]),
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: _buildFooterBar(context),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      actions: const [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Theme.of(context).dividerColor, height: 1),
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
      'Dec',
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final date = widget.departureDate;
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month];

    return '$weekday, $day $month, ${widget.passengers} Adult${widget.passengers > 1 ? 's' : ''}';
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              icon: LucideIcons.sliders,
              label: null,
              onTap: () => _showSortFilter(context),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Recommended',
              hasDropdown: true,
              onTap: () => _showSortFilter(context),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Stops',
              hasDropdown: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Flight Times',
              hasDropdown: true,
              onTap: () => _showFlightTimesFilter(context),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Price',
              hasDropdown: true,
              onTap: () => _showPriceFilter(context),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Airlines',
              hasDropdown: true,
              onTap: () => _showAirlinesFilter(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    IconData? icon,
    String? label,
    bool hasDropdown = false,
    VoidCallback? onTap,
  }) {
    final isIconOnly = icon != null && label == null;
    final horizontalPadding = isIconOnly ? 10.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 14, color: Theme.of(context).iconTheme.color),
            if (icon != null && label != null) const SizedBox(width: 4),
            if (label != null)
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (hasDropdown) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom + 10
        : 10.0;
    const contentHeight = 44.0;

    return Container(
      height: contentHeight + 10 + bottomPadding,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildDropdownButton(
                context,
                value: _selectedPriceType,
                options: ['Per Person\nIncl. fee', 'Total Price'],
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriceType = newValue!;
                  });
                },
              ),
            ),
          ),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Consumer<CurrencyProvider>(
                  builder: (context, currencyProvider, child) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: const CurrencySettingsSheet(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currencyProvider.currencyCode,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(
    BuildContext context, {
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 14,
          color: Theme.of(context).iconTheme.color,
        ),
        iconSize: 14,
        isDense: true,
        itemHeight: null,
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(option.replaceAll('\n', ' ')),
            ),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return options.map<Widget>((String item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildFlightCard(BuildContext context, FlightResult flight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightDetailsPage(
              from: widget.from,
              to: widget.to,
              fromCode: flight.departureCode,
              toCode: flight.arrivalCode,
              departureDate: widget.departureDate,
              passengers: widget.passengers,
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
              color: Colors.black.withOpacity(0.02),
              blurRadius: 2,
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
                            fontSize: 11, // Reduced from 12
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
                                  fontSize: 14, // Reduced from 16
                                ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            flight.departureCode,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10, // Reduced from 11
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Arrow Line - Shorter length
                      SizedBox(
                        width: 50, // Fixed width for shorter arrow
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                          ), // Reduced padding
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
                                  fontSize: 14, // Reduced from 16
                                ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            flight.arrivalCode,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10, // Reduced from 11
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

  // =========================================================================
  // ========================== BOTTOM SHEETS ================================
  // =========================================================================

  String _formatTime(double value) {
    int hour = value.floor();
    int minute = ((value - hour) * 60).round();
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void _showCustomBottomSheet(
    BuildContext context, {
    required String title,
    required Widget content,
    required VoidCallback onApply,
    String buttonText = 'Apply',
    bool showResultsCount = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header - REMOVED DIVIDER AFTER TITLE
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                8,
              ), // Reduced bottom padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _clearAllFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // REMOVED THE DIVIDER THAT WAS HERE

            // Content
            Expanded(child: content),

            // Bottom Action Bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        onApply();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        showResultsCount
                            ? 'Show ${_flights.length} of ${_originalFlights.length} results'
                            : buttonText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter methods
  void _applyFilters() {
    List<FlightResult> filteredFlights = List.from(_originalFlights);

    // Apply price filter
    filteredFlights = filteredFlights.where((flight) {
      return flight.rawPricePKR >= _priceRange.start &&
          flight.rawPricePKR <= _priceRange.end;
    }).toList();

    // Apply airline filters if any are selected
    final selectedAirlines = _airlineFilters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedAirlines.isNotEmpty) {
      filteredFlights = filteredFlights.where((flight) {
        return selectedAirlines.contains(flight.airline);
      }).toList();
    }

    // Apply departure time filter
    filteredFlights = filteredFlights.where((flight) {
      final departTime = _timeToDouble(flight.departureTime);
      return departTime >= _departTimeRange.start &&
          departTime <= _departTimeRange.end;
    }).toList();

    // Apply arrival time filter if not hidden
    if (!_hideArrivalTime) {
      filteredFlights = filteredFlights.where((flight) {
        final arriveTime = _timeToDouble(flight.arrivalTime);
        return arriveTime >= _arriveTimeRange.start &&
            arriveTime <= _arriveTimeRange.end;
      }).toList();
    }

    // Apply sorting
    filteredFlights = _applySorting(filteredFlights);

    setState(() {
      _flights = filteredFlights;
    });
  }

  double _timeToDouble(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour + (minute / 60);
  }

  List<FlightResult> _applySorting(List<FlightResult> flights) {
    switch (_selectedSortOption) {
      case 'Cheapest':
        flights.sort((a, b) => a.rawPricePKR.compareTo(b.rawPricePKR));
        break;
      case 'Fastest':
        // Simple duration comparison - you might want to parse duration properly
        flights.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'Departure Time (Earliest)':
        flights.sort(
          (a, b) => _timeToDouble(
            a.departureTime,
          ).compareTo(_timeToDouble(b.departureTime)),
        );
        break;
      case 'Departure Time (Latest)':
        flights.sort(
          (a, b) => _timeToDouble(
            b.departureTime,
          ).compareTo(_timeToDouble(a.departureTime)),
        );
        break;
      case 'Recommended':
      default:
        break;
    }
    return flights;
  }

  void _clearAllFilters() {
    setState(() {
      _priceRange = const RangeValues(24474, 34016);
      _departTimeRange = const RangeValues(0, 24);
      _arriveTimeRange = const RangeValues(0, 24);
      _hideArrivalTime = false;
      _selectedSortOption = 'Recommended';
      _airlineFilters.updateAll((key, value) => false);
      _flights = List.from(_originalFlights);
    });
  }

  // 1. Sort / Recommended
  void _showSortFilter(BuildContext context) {
    final options = [
      {
        'label': 'Recommended',
        'sub': 'Sorted by convenience and ...',
        'price': 'PKR 24,474',
      },
      {
        'label': 'Cheapest',
        'sub': 'Sorted based on cheapest pr...',
        'price': 'PKR 24,474',
      },
      {
        'label': 'Fastest',
        'sub': 'Sorted based on shorter fligh...',
        'price': 'PKR 28,536',
      },
      {
        'label': 'Departure Time (Earliest)',
        'sub': 'Sorted the flights from morni...',
        'price': 'PKR 24,474',
      },
      {
        'label': 'Departure Time (Latest)',
        'sub': 'Sorted the flights from night...',
        'price': 'PKR 28,536',
      },
    ];

    _showCustomBottomSheet(
      context,
      title: 'Sort by:',
      buttonText: 'Apply',
      showResultsCount: false,
      onApply: () {
        _applyFilters();
      },
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            separatorBuilder: (c, i) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final opt = options[index];
              final label = opt['label']!;
              final isSelected =
                  _selectedSortOption == label.split(' (')[0].trim() ||
                      (_selectedSortOption == 'Recommended' && index == 0);

              return InkWell(
                onTap: () {
                  setSheetState(
                    () => _selectedSortOption = label.split(' (')[0].trim(),
                  );
                  setState(
                    () => _selectedSortOption = label.split(' (')[0].trim(),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt['sub']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      opt['price']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 2. Flight Times
  void _showFlightTimesFilter(BuildContext context) {
    _showCustomBottomSheet(
      context,
      title: 'Flight Times',
      onApply: () {
        _applyFilters();
      },
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FLIGHT TIMES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),

                // Depart Slider
                Text(
                  'Depart from ${widget.from}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(_departTimeRange.start),
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(_departTimeRange.end),
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryBlue,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: AppColors.primaryBlue,
                    trackHeight: 3,
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 2,
                    ),
                    overlayColor: AppColors.primaryBlue.withOpacity(0.1),
                  ),
                  child: RangeSlider(
                    values: _departTimeRange,
                    min: 0,
                    max: 24,
                    onChanged: (values) {
                      setSheetState(() => _departTimeRange = values);
                      setState(() => _departTimeRange = values);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Arrive Slider - HIDDEN based on _hideArrivalTime
                if (!_hideArrivalTime) ...[
                  Text(
                    'Arrive in ${widget.to}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(_arriveTimeRange.start),
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(_arriveTimeRange.end),
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: Colors.grey[200],
                      thumbColor: AppColors.primaryBlue,
                      trackHeight: 3,
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 2,
                      ),
                      overlayColor: AppColors.primaryBlue.withOpacity(0.1),
                    ),
                    child: RangeSlider(
                      values: _arriveTimeRange,
                      min: 0,
                      max: 24,
                      onChanged: (values) {
                        setSheetState(() => _arriveTimeRange = values);
                        setState(() => _arriveTimeRange = values);
                      },
                    ),
                  ),
                ],

                const Spacer(),

                // Toggle Button for Hide Arrival Time
                InkWell(
                  onTap: () {
                    setSheetState(() {
                      _hideArrivalTime = !_hideArrivalTime;
                    });
                    setState(() {
                      _hideArrivalTime = _hideArrivalTime;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hide arrival time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          _hideArrivalTime
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 3. Price
  void _showPriceFilter(BuildContext context) {
    const double minPrice = 24474;
    const double maxPrice = 34016;

    _showCustomBottomSheet(
      context,
      title: 'Price',
      onApply: () {
        _applyFilters();
      },
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRICE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryBlue,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: AppColors.primaryBlue,
                    trackHeight: 3,
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 2,
                    ),
                    overlayColor: AppColors.primaryBlue.withOpacity(0.1),
                  ),
                  child: RangeSlider(
                    values: _priceRange,
                    min: minPrice,
                    max: maxPrice,
                    onChanged: (values) {
                      setSheetState(() => _priceRange = values);
                      setState(() => _priceRange = values);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Min',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'PKR ${_priceRange.start.toInt()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Max',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'PKR ${_priceRange.end.toInt()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Airlines
  void _showAirlinesFilter(BuildContext context) {
    _showCustomBottomSheet(
      context,
      title: 'Airlines',
      onApply: () {
        _applyFilters();
      },
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'AIRLINES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              _buildAirlineItem(
                context,
                label: 'All Airlines',
                price: '',
                isChecked: !_airlineFilters.containsValue(true),
                isIcon: true,
                onChanged: (v) {
                  setSheetState(() {
                    _airlineFilters.updateAll((key, value) => false);
                  });
                  setState(() {
                    _airlineFilters.updateAll((key, value) => false);
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildAirlineItem(
                context,
                label: 'Airblue',
                price: 'PKR 27,297',
                isChecked: _airlineFilters['Airblue'] ?? false,
                onChanged: (v) {
                  setSheetState(() => _airlineFilters['Airblue'] = v!);
                  setState(() => _airlineFilters['Airblue'] = v!);
                },
              ),
              const SizedBox(height: 16),
              _buildAirlineItem(
                context,
                label: 'Fly Jinnah',
                price: 'PKR 24,474',
                isChecked: _airlineFilters['Fly Jinnah'] ?? false,
                onChanged: (v) {
                  setSheetState(() => _airlineFilters['Fly Jinnah'] = v!);
                  setState(() => _airlineFilters['Fly Jinnah'] = v!);
                },
              ),
              const SizedBox(height: 16),
              _buildAirlineItem(
                context,
                label: 'Pakistan International Airlines',
                price: 'PKR 28,536',
                isChecked:
                    _airlineFilters['Pakistan International Airlines'] ?? false,
                onChanged: (v) {
                  setSheetState(
                    () =>
                        _airlineFilters['Pakistan International Airlines'] = v!,
                  );
                  setState(
                    () =>
                        _airlineFilters['Pakistan International Airlines'] = v!,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAirlineItem(
    BuildContext context, {
    required String label,
    required String price,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    bool isIcon = false,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: () => onChanged(!isChecked),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isIcon
                ? const Icon(LucideIcons.dollarSign)
                : isChecked
                    ? Icon(Icons.check_box, color: AppColors.primaryBlue)
                    : const Icon(Icons.check_box_outline_blank,
                        color: Colors.grey),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(price, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
