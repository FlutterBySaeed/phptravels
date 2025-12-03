import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phptravels/features/hotels/pages/hotels_search_page.dart'
    show HotelGuestRoomPickerBottomSheet, HotelRoom;
import 'package:phptravels/features/hotels/widgets/custom_date_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phptravels/features/hotels/pages/room_selection_page.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class HotelDetailsPage extends StatefulWidget {
  final String hotelName;
  final String location;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;
  final double pricePerNight;

  const HotelDetailsPage({
    super.key,
    required this.hotelName,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
    required this.pricePerNight,
  });

  @override
  State<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _showTotalPrice = true;
  bool _showAppBar = false;
  bool _isManualScroll = true; // Track if user is manually scrolling

  // State variables for dates and guests
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int _guests;
  late int _rooms;
  int _currentImageIndex = 0;

  // Keys for each section
  final GlobalKey _overviewKey = GlobalKey();
  final GlobalKey _roomsKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _facilitiesKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _policiesKey = GlobalKey();

  final List<String> _hotelImages = [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
    'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _scrollController = ScrollController();

    // Listen to scroll changes to update tab selection
    _scrollController.addListener(_onScroll);

    // Initialize state from widget
    _checkInDate = widget.checkInDate;
    _checkOutDate = widget.checkOutDate;
    _guests = widget.guests;
    _rooms = widget.rooms;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;

    // Show app bar when scrolled past the image gallery (300px)
    final shouldShowAppBar = scrollPosition > 250;
    if (_showAppBar != shouldShowAppBar) {
      setState(() {
        _showAppBar = shouldShowAppBar;
      });
    }

    if (_showAppBar) {
      int currentSection = 0;
      final keys = [
        _overviewKey,
        _roomsKey,
        _locationKey,
        _reviewsKey,
        _facilitiesKey,
        _aboutKey,
        _policiesKey
      ];

      for (int i = 0; i < keys.length; i++) {
        final key = keys[i];
        if (key.currentContext != null) {
          final RenderBox box =
              key.currentContext!.findRenderObject() as RenderBox;
          final position = box.localToGlobal(Offset.zero);

          // Check if section is in the top portion of viewport
          if (position.dy < viewportHeight / 3 &&
              position.dy > -box.size.height / 2) {
            currentSection = i;
            break;
          }
        }
      }

      // Only update if different (prevents unnecessary rebuilds)
      if (_tabController.index != currentSection) {
        _tabController.index = currentSection;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    GlobalKey? key;
    switch (index) {
      case 0:
        key = _overviewKey;
        break;
      case 1:
        key = _roomsKey;
        break;
      case 2:
        key = _locationKey;
        break;
      case 3:
        key = _reviewsKey;
        break;
      case 4:
        key = _facilitiesKey;
        break;
      case 5:
        key = _aboutKey;
        break;
      case 6:
        key = _policiesKey;
        break;
    }

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  int get _numberOfNights {
    return widget.checkOutDate.difference(widget.checkInDate).inDays;
  }

  double get _totalPrice {
    return widget.pricePerNight * _numberOfNights;
  }

  String _formatDateRange() {
    final format = DateFormat('dd MMM');
    return '${format.format(_checkInDate)} - ${format.format(_checkOutDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // App Bar - smoothly follows scroll position
          AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              final offset =
                  _scrollController.hasClients ? _scrollController.offset : 0.0;
              // Calculate smooth progress (0 to 1) over 300px scroll range
              final progress = (offset / 300).clamp(0.0, 1.0);

              return RepaintBoundary(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: progress,
                    child: Opacity(
                      opacity: progress,
                      child: child!,
                    ),
                  ),
                ),
              );
            },
            child: _buildAppBar(),
          ),
          // Tab Bar - smoothly follows scroll position
          AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              final offset =
                  _scrollController.hasClients ? _scrollController.offset : 0.0;
              // Calculate smooth progress (0 to 1) over 300px scroll range
              final progress = (offset / 300).clamp(0.0, 1.0);

              return RepaintBoundary(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: progress,
                    child: Opacity(
                      opacity: progress,
                      child: child!,
                    ),
                  ),
                ),
              );
            },
            child: _buildTabBar(),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                children: [
                  Container(key: _overviewKey, child: _buildOverviewSection()),
                  Container(key: _roomsKey, child: _buildRoomsSection()),
                  Container(key: _locationKey, child: _buildLocationSection()),
                  Container(key: _reviewsKey, child: _buildReviewsSection()),
                  Container(
                      key: _facilitiesKey, child: _buildFacilitiesSection()),
                  Container(key: _aboutKey, child: _buildAboutSection()),
                  Container(key: _policiesKey, child: _buildPoliciesSection()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Sticky Footer
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.hotelName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDateRange()} • $_guests ${AppLocalizations.of(context).guests} • $_rooms ${AppLocalizations.of(context).room}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        onTap: (index) {
          // Directly scroll to the tapped section
          _scrollToSection(index);
        },
        tabs: [
          Tab(text: AppLocalizations.of(context).overview),
          Tab(text: AppLocalizations.of(context).rooms),
          Tab(text: AppLocalizations.of(context).location),
          Tab(text: AppLocalizations.of(context).reviews),
          Tab(text: AppLocalizations.of(context).facilities),
          Tab(text: AppLocalizations.of(context).aboutThisProperty),
          Tab(text: AppLocalizations.of(context).policies),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Gallery
        _buildImageGallery(),
        const SizedBox(height: 16),
        // Hotel Title Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotelName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(
                          3,
                          (index) => const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '5.0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: _hotelImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_hotelImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        // Floating buttons - shown when app bar is hidden
        if (!_showAppBar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Share button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.share_outlined,
                        color: Colors.black, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        // Page indicators (tracker lines)
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _hotelImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentImageIndex ? 32 : 16,
                height: 4,
                decoration: BoxDecoration(
                  color: index == _currentImageIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        // Photo count indicator
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.image,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_hotelImages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).rooms,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 16),
                // Date and Guest Info Row - Single unified container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Date section
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked =
                                  await showModalBottomSheet<DateTimeRange>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.92,
                                  child: CustomDatePicker(
                                    initialCheckIn: _checkInDate,
                                    initialCheckOut: _checkOutDate,
                                  ),
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  _checkInDate = picked.start;
                                  _checkOutDate = picked.end;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.calendar,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_checkInDate.day.toString().padLeft(2, '0')} - ${_checkOutDate.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM').format(_checkInDate),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Vertical divider
                        Container(
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        // Rooms and Guests section
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final updatedRooms =
                                  await showModalBottomSheet<List<HotelRoom>>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => DraggableScrollableSheet(
                                  initialChildSize: 0.8,
                                  minChildSize: 0.5,
                                  maxChildSize: 0.95,
                                  builder: (_, controller) => Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: HotelGuestRoomPickerBottomSheet(
                                      initialRooms: [
                                        HotelRoom(adults: _guests, children: 0)
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              if (updatedRooms != null &&
                                  updatedRooms.isNotEmpty) {
                                setState(() {
                                  _rooms = updatedRooms.length;
                                  _guests = updatedRooms.fold(
                                      0, (sum, room) => sum + room.totalGuests);
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.doorOpen,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_rooms',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(LucideIcons.users2,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_guests',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Price Toggle - Single container with gray bg
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 240, 240),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPriceToggleButton(
                            AppLocalizations.of(context).totalPrice,
                            _showTotalPrice),
                      ),
                      Expanded(
                        child: _buildPriceToggleButton(
                            AppLocalizations.of(context).perNight,
                            !_showTotalPrice),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Price Display with Arrow
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹ ${(_showTotalPrice ? _totalPrice : widget.pricePerNight).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _showTotalPrice
                                  ? 'for ${_checkOutDate.difference(_checkInDate).inDays} ${AppLocalizations.of(context).nights} ${AppLocalizations.of(context).includingTaxesFees.toLowerCase()}'
                                  : AppLocalizations.of(context)
                                      .perNightWithTaxes,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Badges Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).exclusiveDeal,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .mobileOnlyPrice,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 28,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomSelectionPage(
                            hotelName: widget.hotelName,
                            checkInDate: _checkInDate,
                            checkOutDate: _checkOutDate,
                            guests: _guests,
                            rooms: _rooms,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      AppLocalizations.of(context).seeAllRooms,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPriceToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showTotalPrice = label == 'Total Price';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).location,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 16),
                // Interactive Map
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            LatLng(31.5204, 74.3587), // Lahore coordinates
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.phptravels',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(31.5204, 74.3587),
                              width: 40,
                              height: 40,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  LucideIcons.mapPin,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Address
                _buildLocationItem(
                  LucideIcons.mapPin,
                  '343 R Block Model Town, 54700, Lahore, Punjab',
                ),
                const Divider(height: 32),
                // Distance to landmarks
                _buildLocationItem(
                  LucideIcons.building,
                  'City centre (Lahore)',
                  distance: '9.06 km',
                ),
                const SizedBox(height: 12),
                _buildLocationItem(
                  LucideIcons.plane,
                  'Lahore Airport',
                  distance: '8.28 km',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String text, {String? distance}) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        if (distance != null)
          Text(
            distance,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).guestReviews,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).noReviewsYet,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    final facilities = [
      {'icon': LucideIcons.check, 'name': 'Free Parking'},
      {'icon': LucideIcons.car, 'name': 'Parking Available'},
      {'icon': LucideIcons.ban, 'name': 'Non-smoking Rooms'},
      {'icon': LucideIcons.shirt, 'name': 'Dry Cleaning'},
      {'icon': LucideIcons.wifi, 'name': 'Free WiFi'},
      {'icon': LucideIcons.wind, 'name': 'Air Conditioning'},
      {'icon': LucideIcons.tv, 'name': 'TV'},
      {'icon': LucideIcons.coffee, 'name': 'Breakfast Available'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).facilities,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: facilities.length,
                  itemBuilder: (context, index) {
                    final facility = facilities[index];
                    return Row(
                      children: [
                        Icon(
                          facility['icon'] as IconData,
                          size: 18,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            facility['name'] as String,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).aboutThisProperty,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'dining - Local cuisine breakfasts are available daily from 7:00 AM to noon for a fee. business_amenities - Featured amenities include dry cleaning/laundry services, laundry facilities, and microwave in a common area.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPoliciesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).propertyPolicies,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 16),
                _buildPolicyItem(
                  LucideIcons.calendar,
                  AppLocalizations.of(context).checkInTime,
                  '12:00 PM',
                ),
                const Divider(height: 24),
                _buildPolicyItem(
                  LucideIcons.calendar,
                  AppLocalizations.of(context).checkOutTime,
                  '12:00 PM',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Similar Hotels
          Text(
            AppLocalizations.of(context).nearbySimilarStays,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildSimilarHotelCard(index);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarHotelCard(int index) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.building2,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Similar Hotel ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.5',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(index + 1) * 2} ${AppLocalizations.of(context).kmAway}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  Widget _buildStickyFooter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(top: BorderSide(color: Colors.grey[700]!)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).totalPrice,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '₹ ${_totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context).includesTaxesAndFees}\n${_numberOfNights > 1 ? AppLocalizations.of(context).forMultipleNightsRange(_numberOfNights) : AppLocalizations.of(context).forNightsRange(_numberOfNights)} (${DateFormat('dd MMM').format(_checkInDate)} - ${DateFormat('dd MMM').format(_checkOutDate)})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomSelectionPage(
                    hotelName: widget.hotelName,
                    checkInDate: _checkInDate,
                    checkOutDate: _checkOutDate,
                    guests: _guests,
                    rooms: _rooms,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).chooseRoom,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
