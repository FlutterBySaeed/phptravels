import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/hotels/models/hotel_result.dart';
import 'package:phptravels/core/services/hotel_api_service.dart';
import 'package:phptravels/features/account/pages/currency_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/currency_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phptravels/features/hotels/pages/hotel_details_page.dart';
import 'package:phptravels/l10n/app_localizations.dart';

enum ViewMode { mapOnly, listOnly, both }

class HotelsResultsPage extends StatefulWidget {
  final String location;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int rooms;
  final int guests;

  const HotelsResultsPage({
    super.key,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    this.rooms = 1,
    this.guests = 2,
  });

  @override
  State<HotelsResultsPage> createState() => _HotelsResultsPageState();
}

class _HotelsResultsPageState extends State<HotelsResultsPage> {
  ViewMode _viewMode = ViewMode.both;
  List<HotelResult> _hotels = [];
  bool _isLoading = true;
  String? _errorMessage;
  LatLng _mapCenter = const LatLng(31.5204, 74.3587); // Default: Lahore
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Extract city name from location (e.g., "Lahore, Pakistan" -> "lahore")
      final cityName = widget.location.split(',').first.trim();

      final hotels = await HotelAPIService.searchHotels(
        location: cityName,
      );

      if (mounted) {
        setState(() {
          _hotels = hotels;
          _isLoading = false;
          _createMarkers();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).failedToLoadHotels;
          _isLoading = false;
        });
      }
    }
  }

  String _formatDateRange() {
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

    final checkIn = widget.checkInDate;
    final checkOut = widget.checkOutDate;

    final checkInDay = checkIn.day;
    final checkInMonth = months[checkIn.month];
    final checkOutDay = checkOut.day;
    final checkOutMonth = months[checkOut.month];

    return '$checkInDay $checkInMonth - $checkOutDay $checkOutMonth';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          _viewMode == ViewMode.mapOnly || _viewMode == ViewMode.both,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: _isLoading
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
                        onPressed: _fetchHotels,
                        child: Text(AppLocalizations.of(context).retry),
                      ),
                    ],
                  ),
                )
              : _viewMode == ViewMode.both
                  ? Stack(
                      children: [
                        // Full-screen map as background
                        _buildMapView(context),
                        // Draggable list overlay
                        _buildDraggableListOverlay(context),
                        // No toggle button in split mode
                      ],
                    )
                  : Stack(
                      children: [
                        // Map or List view
                        _viewMode == ViewMode.mapOnly
                            ? _buildMapView(context)
                            : Column(
                                children: [
                                  // Show filter bar only in list view
                                  if (_viewMode == ViewMode.listOnly)
                                    _buildFilterBar(context),
                                  Expanded(
                                    child: _buildListView(context),
                                  ),
                                ],
                              ),
                        // Add draggable handle in map view
                        if (_viewMode == ViewMode.mapOnly)
                          _buildMapDragHandle(),
                        _buildViewToggle(),
                      ],
                    ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isMapView =
        _viewMode == ViewMode.mapOnly || _viewMode == ViewMode.both;

    return AppBar(
      backgroundColor: isMapView
          ? Colors.transparent
          : Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: isMapView
            ? BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              )
            : null,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isMapView ? Colors.white : Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.location,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_formatDateRange()} · ${widget.rooms} Room, ${widget.guests}...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
      titleSpacing: 12,
      actions: [
        Consumer<CurrencyProvider>(
          builder: (context, currencyProvider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              decoration: isMapView
                  ? BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: IconButton(
                icon: Icon(
                  Icons.currency_exchange,
                  color: Theme.of(context).iconTheme.color,
                  size: 22,
                ),
                onPressed: () {
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
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(),
      ),
    );
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
              icon: LucideIcons.search,
              label: AppLocalizations.of(context).propertyName,
              onTap: () => _showPropertyNameModal(),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: AppLocalizations.of(context).recommended,
              hasDropdown: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: AppLocalizations.of(context).cheapest,
              hasDropdown: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: AppLocalizations.of(context).priceRange,
              hasDropdown: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: AppLocalizations.of(context).districtAreasHotels,
              hasDropdown: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: AppLocalizations.of(context).starRating,
              hasDropdown: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: AppLocalizations.of(context).reviewScore,
              hasDropdown: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    IconData? icon,
    required String label,
    bool hasDropdown = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
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

  void _createMarkers() {
    if (_hotels.isEmpty) return;

    // Calculate map center based on average of all hotel locations
    double totalLat = 0;
    double totalLng = 0;
    int validCount = 0;

    for (var hotel in _hotels) {
      if (hotel.latitude != 0 && hotel.longitude != 0) {
        totalLat += hotel.latitude;
        totalLng += hotel.longitude;
        validCount++;
      }
    }

    if (validCount > 0) {
      _mapCenter = LatLng(totalLat / validCount, totalLng / validCount);
    }

    // Create markers using actual API coordinates
    _markers = _hotels.map((hotel) {
      return Marker(
        point: LatLng(
          hotel.latitude, // Real latitude from API
          hotel.longitude, // Real longitude from API
        ),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            // Show hotel info in a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${hotel.name} - PKR ${hotel.rawPricePKR.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF2C2C2C),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Icon(
            Icons.location_on,
            color: Color(0xFFE53935),
            size: 40,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMapView(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: 12.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.phptravels.app',
        ),
        MarkerLayer(
          markers: _markers,
        ),
      ],
    );
  }

  Widget _buildDraggableListOverlay(BuildContext context) {
    final controller = DraggableScrollableController();

    controller.addListener(() {
      // When sheet is dragged above 60%, switch to list view
      if (controller.size >= 0.6) {
        if (_viewMode == ViewMode.both) {
          setState(() {
            _viewMode = ViewMode.listOnly;
          });
        }
      }
      // When sheet is dragged below 40%, switch to map view
      else if (controller.size <= 0.4) {
        if (_viewMode == ViewMode.both) {
          setState(() {
            _viewMode = ViewMode.mapOnly;
          });
        }
      }
    });

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.6,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.6],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header as non-scrolling sliver
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Property count header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${_hotels.length} ${AppLocalizations.of(context).propertiesFound}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                        ),
                      ),
                    ),
                    // Filters row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context).filters,
                            icon: LucideIcons.sliders,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context).propertyName,
                            icon: LucideIcons.search,
                            onTap: () => _showPropertyNameModal(),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context).recommended,
                            hasDropdown: true,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context).cheapest,
                            hasDropdown: true,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context).priceRange,
                            hasDropdown: true,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context)
                                .districtAreasHotels,
                            hasDropdown: true,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context).starRating,
                            hasDropdown: true,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: AppLocalizations.of(context).reviewScore,
                            hasDropdown: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Hotel list as sliver
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildHotelCard(context, _hotels[index]),
                      );
                    },
                    childCount: _hotels.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapDragHandle() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          // If dragging up (negative delta), switch to split view
          if (details.delta.dy < -5) {
            setState(() {
              _viewMode = ViewMode.both;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Property count
              Padding(
                padding: EdgeInsets.only(bottom: 20 + bottomPadding),
                child: Text(
                  '${_hotels.length} properties found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          if (notification.overscroll < -20 && _viewMode == ViewMode.listOnly) {
            setState(() {
              _viewMode = ViewMode.both;
            });
            return true;
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 58,
        ),
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHotelCard(context, _hotels[index]),
          );
        },
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, HotelResult hotel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailsPage(
              hotelName: hotel.name,
              location: widget.location,
              checkInDate: widget.checkInDate,
              checkOutDate: widget.checkOutDate,
              guests: widget.guests,
              rooms: widget.rooms,
              pricePerNight: hotel.rawPricePKR,
            ),
          ),
        );
      },
      child: Container(
        height: 212,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Images (touching card edges)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                  ),
                  child: Container(
                    width: 140,
                    height: 140,
                    color: Colors.grey[300],
                    child: Icon(
                      LucideIcons.building2,
                      size: 30,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Two thumbnail images side by side
                Row(
                  children: hotel.thumbnailImages
                      .take(2)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final isFirst = entry.key == 0;
                    return Padding(
                      padding: EdgeInsets.only(right: isFirst ? 4 : 0),
                      child: ClipRRect(
                        borderRadius: isFirst
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                              )
                            : BorderRadius.zero,
                        child: Container(
                          width: 68,
                          height: 66,
                          color: Colors.grey[300],
                          child: Icon(
                            LucideIcons.image,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Right: Hotel info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel name
                        Text(
                          hotel.name,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Star rating
                        if (hotel.starRating > 0)
                          Row(
                            children: List.generate(
                              hotel.starRating,
                              (index) => const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFFFA726),
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        // Review score
                        if (hotel.reviewScore > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${hotel.reviewScore.toStringAsFixed(1)} ${hotel.reviewLabel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        // Amenities
                        ...hotel.amenities.take(1).map(
                              (amenity) => Row(
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      amenity,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontSize: 11,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                    // Price at bottom-right
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<CurrencyProvider>(
                            builder: (context, currencyProvider, child) {
                              return Text(
                                currencyProvider.formatPrice(hotel.rawPricePKR,
                                    compact: true),
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
                          ),
                          Text(
                            'includes taxes and fees',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 9,
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
      ),
    );
  }

  Widget _buildViewToggle() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Higher position in map view to avoid bottom sheet
    final bottomPosition = _viewMode == ViewMode.mapOnly ? 90.0 : 15.0;

    return Positioned(
      bottom: bottomPosition + bottomPadding,
      left: 0,
      right: 0,
      child: Center(
        child: _viewMode == ViewMode.both
            ? _buildDualToggle()
            : _buildSingleToggle(),
      ),
    );
  }

  // Single button for solo modes (List or Map only)
  Widget _buildSingleToggle() {
    final isListView = _viewMode == ViewMode.listOnly;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Go directly to the opposite solo view
          _viewMode = isListView ? ViewMode.mapOnly : ViewMode.listOnly;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isListView ? LucideIcons.map : LucideIcons.list,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isListView ? 'Map View' : 'List View',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dual buttons for split mode
  Widget _buildDualToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // List View Button
          GestureDetector(
            onTap: () {
              setState(() {
                _viewMode = ViewMode.listOnly;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.list,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'List View',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[300],
          ),
          // Map View Button
          GestureDetector(
            onTap: () {
              setState(() {
                _viewMode = ViewMode.mapOnly;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.map,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Map View',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPropertyNameModal() {
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filter hotels based on search text
            final filteredHotels = searchController.text.isEmpty
                ? <HotelResult>[]
                : _hotels.where((hotel) {
                    return hotel.name
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase());
                  }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 155, 40, 40),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                controller: searchController,
                                autofocus: true,
                                onChanged: (value) {
                                  setModalState(() {});
                                },
                                decoration: InputDecoration(
                                  filled: false,
                                  hintText: AppLocalizations.of(context)
                                      .enterPropertyName,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(LucideIcons.search,
                                      size: 22, color: Colors.grey[600]),
                                  suffixIcon: searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear,
                                              size: 20,
                                              color: Colors.grey[600]),
                                          onPressed: () {
                                            searchController.clear();
                                            setModalState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(context).cancel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: searchController.text.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.search,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    AppLocalizations.of(context)
                                        .typeHotelNameToSearch,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Property count
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    '${filteredHotels.length} ${filteredHotels.length == 1 ? AppLocalizations.of(context).propertyFound : AppLocalizations.of(context).propertiesFound}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Filtered results
                                Expanded(
                                  child: filteredHotels.isEmpty
                                      ? Center(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .noCitiesFound,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: filteredHotels.length,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          itemBuilder: (context, index) {
                                            final hotel = filteredHotels[index];
                                            return _buildHotelCard(
                                                context, hotel);
                                          },
                                        ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw some mock roads
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
