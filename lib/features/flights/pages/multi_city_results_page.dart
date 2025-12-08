import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/flights/models/multi_city_segment.dart';
import 'package:phptravels/features/flights/models/flight_result.dart';
import 'package:phptravels/features/flights/widgets/multi_city_flight_card.dart';
import 'package:phptravels/features/flights/pages/multi_city_flight_details_page.dart';
import 'package:phptravels/features/account/pages/payment_methods_page.dart';
import 'package:intl/intl.dart';

class MultiCityResultsPage extends StatefulWidget {
  final List<MultiCitySegment> segments;
  final int passengers;

  const MultiCityResultsPage({
    super.key,
    required this.segments,
    required this.passengers,
  });

  @override
  State<MultiCityResultsPage> createState() => _MultiCityResultsPageState();
}

enum SortOption {
  lowestPrice,
  shortestDuration,
  bestExperience,
  earliestDeparture,
  latestDeparture,
  earliestArrival,
  latestArrival,
}

class _MultiCityResultsPageState extends State<MultiCityResultsPage> {
  int _currentSegmentIndex = 0;
  Map<int, FlightResult?> _selectedFlights = {};
  List<FlightResult> _currentFlights = [];
  bool _isLoading = false;
  final ScrollController _segmentScrollController = ScrollController();
  SortOption _currentSort = SortOption.lowestPrice;
  final GlobalKey _sortButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadFlightsForCurrentSegment();
  }

  @override
  void dispose() {
    _segmentScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFlightsForCurrentSegment() async {
    if (_currentSegmentIndex >= widget.segments.length) return;

    setState(() {
      _isLoading = true;
    });

    final segment = widget.segments[_currentSegmentIndex];
    await Future.delayed(const Duration(milliseconds: 500));
    final flights = _generateMockFlights(segment);

    setState(() {
      _currentFlights = flights;
      _isLoading = false;
    });
    _sortFlights();
  }

  void _sortFlights() {
    setState(() {
      switch (_currentSort) {
        case SortOption.lowestPrice:
          _currentFlights
              .sort((a, b) => a.rawPricePKR.compareTo(b.rawPricePKR));
          break;
        case SortOption.shortestDuration:
          _currentFlights.sort((a, b) => a.duration.compareTo(b.duration));
          break;
        case SortOption.bestExperience:
          // Sort by direct flights first, then by price
          _currentFlights.sort((a, b) {
            if (a.layoverInfo == 'Direct' && b.layoverInfo != 'Direct')
              return -1;
            if (a.layoverInfo != 'Direct' && b.layoverInfo == 'Direct')
              return 1;
            return a.rawPricePKR.compareTo(b.rawPricePKR);
          });
          break;
        case SortOption.earliestDeparture:
          _currentFlights
              .sort((a, b) => a.departureTime.compareTo(b.departureTime));
          break;
        case SortOption.latestDeparture:
          _currentFlights
              .sort((a, b) => b.departureTime.compareTo(a.departureTime));
          break;
        case SortOption.earliestArrival:
          _currentFlights
              .sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
          break;
        case SortOption.latestArrival:
          _currentFlights
              .sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));
          break;
      }
    });
  }

  List<FlightResult> _generateMockFlights(MultiCitySegment segment) {
    // Mock flight data
    final airlines = [
      'Emirates',
      'Pakistan International Airlines',
      'flydubai',
      'Qatar Airways'
    ];
    final logos = ['EK', 'PIA', 'FZ', 'QR'];
    final flights = <FlightResult>[];

    // Extract airport codes
    String extractCode(String location) {
      final match = RegExp(r'\(([^)]+)\)$').firstMatch(location);
      return match?.group(1) ?? location;
    }

    final fromCode = extractCode(segment.from);
    final toCode = extractCode(segment.to);

    for (int i = 0; i < 5; i++) {
      final airlineIndex = i % airlines.length;
      flights.add(FlightResult(
        airline: airlines[airlineIndex],
        flightNumber: 'FL${1000 + i}',
        departureTime: '${10 + i * 2}:00',
        arrivalTime: '${14 + i * 2}:00',
        departureCode: fromCode,
        arrivalCode: toCode,
        duration: '${3 + i}h 30m',
        layoverInfo:
            i % 3 == 0 ? 'Direct' : '${i % 3} stop${i % 3 > 1 ? "s" : ""}',
        rawPricePKR: 40000 + (i * 5000),
        airlineLogo: logos[airlineIndex],
        badges: i == 0 ? ['Best Value'] : [],
      ));
    }

    return flights;
  }

  void _selectSegment(int index) {
    if (index != _currentSegmentIndex) {
      setState(() {
        _currentSegmentIndex = index;
      });
      _loadFlightsForCurrentSegment();
      _scrollToSegment(index);
    }
  }

  void _scrollToSegment(int index) {
    // Calculate scroll position to show the selected card
    final cardWidth = 160.0;
    final spacing = 12.0;
    final scrollPosition = (cardWidth + spacing) * index;

    // Animate scroll if controller is attached
    if (_segmentScrollController.hasClients) {
      _segmentScrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectFlight(FlightResult flight) {
    setState(() {
      _selectedFlights[_currentSegmentIndex] = flight;
    });

    // Move to next segment only if it doesn't have a selection yet
    if (_currentSegmentIndex < widget.segments.length - 1) {
      // Check if next segment already has a flight selected
      final nextSegmentIndex = _currentSegmentIndex + 1;
      if (!_selectedFlights.containsKey(nextSegmentIndex)) {
        // Next segment is not selected, switch to it
        setState(() {
          _currentSegmentIndex = nextSegmentIndex;
        });
        _loadFlightsForCurrentSegment();
        _scrollToSegment(nextSegmentIndex);
      }
      // If next segment already has a selection, stay on current segment
    } else {
      // All segments have flights selected - navigate to booking
      _navigateToBooking();
    }
  }

  void _navigateToBooking() {
    // Navigate to multi-city flight details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiCityFlightDetailsPage(
          segments: widget.segments,
          selectedFlights: Map<int, FlightResult>.from(_selectedFlights),
          passengers: widget.passengers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Flight ${_currentSegmentIndex + 1}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).dividerColor,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Segment cards section
          _buildSegmentCards(),
          const SizedBox(height: 0),
          _buildActionButtons(),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onHorizontalDragEnd: (details) {
                      // Detect swipe direction
                      if (details.primaryVelocity! > 0) {
                        // Swiped right - go to previous segment
                        if (_currentSegmentIndex > 0) {
                          _selectSegment(_currentSegmentIndex - 1);
                        }
                      } else if (details.primaryVelocity! < 0) {
                        // Swiped left - go to next segment
                        if (_currentSegmentIndex < widget.segments.length - 1) {
                          _selectSegment(_currentSegmentIndex + 1);
                        }
                      }
                    },
                    child: _buildFlightsList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentCards() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        controller: _segmentScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (_currentSegmentIndex > 0)
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: () => _selectSegment(_currentSegmentIndex - 1),
              ),
            for (int i = 0; i < widget.segments.length; i++) ...[
              SizedBox(
                width: 160,
                child: _buildSegmentCard(i),
              ),
              if (i < widget.segments.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentCard(int index) {
    final segment = widget.segments[index];
    final isSelected = index == _currentSegmentIndex;
    final hasSelectedFlight = _selectedFlights.containsKey(index);
    final dateFormat = DateFormat('EEE, dd MMM');
    final dateStr =
        segment.date != null ? dateFormat.format(segment.date!) : '';

    String extractCode(String location) {
      final match = RegExp(r'\(([^)]+)\)$').firstMatch(location);
      return match?.group(1) ?? location;
    }

    final fromCode = extractCode(segment.from);
    final toCode = extractCode(segment.to);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: GestureDetector(
        onTap: () => _selectSegment(index),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : Theme.of(context).dividerColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with flight icon, number, and date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Theme.of(context).cardColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.plane,
                      size: 12,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${index + 1} of ${widget.segments.length}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Route display
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (hasSelectedFlight)
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.primaryBlue,
                      )
                    else
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$fromCode → $toCode',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildActionButton(LucideIcons.arrowUpDown, 'SORT'),
          _buildActionButton(LucideIcons.filter, 'FILTER'),
          _buildActionButton(LucideIcons.dollarSign, 'PRICE'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (label == 'SORT') {
            _showSortModal();
          } else if (label == 'PRICE') {
            _showPaymentMethodsSheet();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortModal() {
    showMenu<SortOption>(
      context: context,
      position: const RelativeRect.fromLTRB(
        16, // Left padding
        235, // Top position
        double.infinity,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      items: [
        _buildPopupMenuItem('Lowest Price', SortOption.lowestPrice),
        _buildPopupMenuItem('Shortest Duration', SortOption.shortestDuration),
        _buildPopupMenuItem('Best Experience', SortOption.bestExperience),
        _buildPopupMenuItem('Earliest Departure', SortOption.earliestDeparture),
        _buildPopupMenuItem('Latest Departure', SortOption.latestDeparture),
        _buildPopupMenuItem('Earliest Arrival', SortOption.earliestArrival),
        _buildPopupMenuItem('Latest Arrival', SortOption.latestArrival),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _currentSort = value;
        });
        _sortFlights();
      }
    });
  }

  void _showPaymentMethodsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: const PaymentPickerBottomSheet(),
      ),
    );
  }

  PopupMenuItem<SortOption> _buildPopupMenuItem(
      String title, SortOption option) {
    final isSelected = _currentSort == option;
    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          if (isSelected)
            const Icon(
              Icons.check,
              color: AppColors.primaryBlue,
              size: 20,
            )
          else
            const SizedBox(width: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? AppColors.primaryBlue : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightsList() {
    if (_currentFlights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plane, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No flights found for this route',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      itemCount: _currentFlights.length,
      itemBuilder: (context, index) {
        final flight = _currentFlights[index];
        final segment = widget.segments[_currentSegmentIndex];
        final selectedFlight = _selectedFlights[_currentSegmentIndex];
        final isSelected = selectedFlight != null &&
            selectedFlight.flightNumber == flight.flightNumber;
        return GestureDetector(
          onTap: () => _selectFlight(flight),
          child: MultiCityFlightCard(
            flight: flight,
            from: segment.from,
            to: segment.to,
            passengers: widget.passengers,
            isSelected: isSelected,
          ),
        );
      },
    );
  }
}
