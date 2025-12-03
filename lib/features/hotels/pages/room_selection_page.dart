import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class RoomSelectionPage extends StatefulWidget {
  final String hotelName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;

  const RoomSelectionPage({
    super.key,
    required this.hotelName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
  });

  @override
  State<RoomSelectionPage> createState() => _RoomSelectionPageState();
}

class _RoomSelectionPageState extends State<RoomSelectionPage> {
  String _selectedFilter = 'Total Price';
  String _priceMode = 'Total Price'; // 'Total Price' or 'Price per night'
  bool _showBreakfastOnly = false; // Toggle for breakfast filter
  final Map<String, String?> _selectedRoomOptions = {};
  final Map<String, bool> _expandedRooms = {};

  String get _dateRange {
    final formatter = DateFormat('dd MMM');
    return '${formatter.format(widget.checkInDate)} - ${formatter.format(widget.checkOutDate)}';
  }

  int get _nights {
    return widget.checkOutDate.difference(widget.checkInDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hotelName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$_dateRange · ${widget.guests} Guests · ${widget.rooms} room',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showPriceModal(),
                    child: _buildFilterPill(
                        AppLocalizations.of(context).totalPrice,
                        true), // Always shown as selected
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(
                        () => _showBreakfastOnly = !_showBreakfastOnly),
                    child: _buildFilterPill(
                        AppLocalizations.of(context).breakfastIncluded,
                        _showBreakfastOnly),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() {
                      // Toggle: if already selected, deselect it
                      if (_selectedFilter ==
                          AppLocalizations.of(context).freeCancellation) {
                        _selectedFilter = '';
                      } else {
                        _selectedFilter =
                            AppLocalizations.of(context).freeCancellation;
                      }
                    }),
                    child: _buildFilterPill(
                        AppLocalizations.of(context).freeCancellation,
                        _selectedFilter ==
                            AppLocalizations.of(context).freeCancellation),
                  ),
                ],
              ),
            ),
          ),
          // Room list
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              children: [
                _buildRoomCard(
                  roomName: 'Executive, King, Executive\nLounge Access',
                  imageUrl:
                      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
                  photoCount: 3,
                  options: [
                    RoomOption(
                      id: 'room1_option1',
                      name: 'Room only',
                      price: 36757,
                      cancellationDate: DateTime(2024, 12, 8),
                    ),
                    RoomOption(
                      id: 'room1_option2',
                      name: 'Breakfast Included',
                      price: 47231,
                      cancellationDate: DateTime(2024, 12, 9),
                    ),
                  ],
                  roomId: 'room1',
                ),
                const SizedBox(height: 16),
                _buildRoomCard(
                  roomName: 'Executive',
                  imageUrl:
                      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400',
                  photoCount: 8,
                  options: [
                    RoomOption(
                      id: 'room2_option1',
                      name: 'Breakfast Included',
                      price: 40832,
                      cancellationDate: DateTime(2024, 12, 9),
                    ),
                  ],
                  roomId: 'room2',
                  startCollapsed: true, // Start collapsed for this room
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? AppColors.primaryBlue : Colors.grey[700],
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRoomCard({
    required String roomName,
    required String imageUrl,
    required int photoCount,
    required List<RoomOption> options,
    required String roomId,
    int? basePrice,
    bool showSelectButton = false,
    bool startCollapsed = false, // New parameter
  }) {
    final selectedOption = _selectedRoomOptions[roomId];
    final hasOptions = options.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    roomName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Room image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.image,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$photoCount',
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
                ),
              ],
            ),
          ),
          // Options or simple price
          if (hasOptions) ...[
            // Initialize expanded state and selected option
            Builder(
              builder: (context) {
                final isExpanded = _expandedRooms[roomId] ??
                    !startCollapsed; // Use startCollapsed parameter
                final currentSelected =
                    _selectedRoomOptions[roomId] ?? options.first.id;
                final selectedOptionData = options.firstWhere(
                    (opt) => opt.id == currentSelected,
                    orElse: () => options.first);

                return Column(
                  children: [
                    // Show collapsed view or expanded view
                    if (isExpanded) ...[
                      // Expanded view - show all options with radio buttons
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: options
                              .where((option) {
                                // Filter options based on breakfast filter
                                if (_showBreakfastOnly) {
                                  return option.name
                                      .toLowerCase()
                                      .contains('breakfast');
                                }
                                return true;
                              })
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final option = entry.value;
                                final isSelected = currentSelected == option.id;
                                final isLast = index == options.length - 1;

                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedRoomOptions[roomId] =
                                              option.id;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSelected
                                                  ? Icons.radio_button_checked
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color: isSelected
                                                  ? AppColors.primaryBlue
                                                  : Colors.grey[400],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    option.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Free Cancellation before ${DateFormat('dd MMM').format(option.cancellationDate)}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      color:
                                                          AppColors.primaryBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '₹ ${NumberFormat('#,##,###').format(option.price)}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  '1 Night',
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
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        color: Colors.grey[200],
                                      ),
                                  ],
                                );
                              })
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Book Now button when expanded
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹ ${NumberFormat('#,##,###').format(selectedOptionData.price)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'for $_nights Night, ${widget.guests} Guests',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Including taxes & fees',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.info,
                                        size: 14,
                                        color: AppColors.primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () {
                                          final selectedOpt =
                                              options.firstWhere(
                                            (opt) =>
                                                opt.id ==
                                                (_selectedRoomOptions[roomId] ??
                                                    options.first.id),
                                          );
                                          _showChargesSummary(
                                              context, selectedOpt.price);
                                        },
                                        child: Text(
                                          'Charges Summary',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                AppLocalizations.of(context).bookNow,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Collapsed view - show option card when clicked
                      if (_expandedRooms[roomId] == true)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked,
                                color: AppColors.primaryBlue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedOptionData.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Free Cancellation before ${DateFormat('dd MMM').format(selectedOptionData.cancellationDate)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹ ${NumberFormat('#,##,###').format(selectedOptionData.price)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '1 Night',
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
                      if (_expandedRooms[roomId] == true)
                        const SizedBox(height: 16),
                      // Price summary and buttons - always visible
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹ ${NumberFormat('#,##,###').format(selectedOptionData.price)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'for $_nights Night, ${widget.guests} Guests',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Including taxes & fees',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.info,
                                        size: 14,
                                        color: AppColors.primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () {
                                          _showChargesSummary(context,
                                              selectedOptionData.price);
                                        },
                                        child: Text(
                                          'Charges Summary',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Show Select button if not expanded, Book Now if expanded
                            if (_expandedRooms[roomId] != true)
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _expandedRooms[roomId] = true;
                                  });
                                },
                                icon: const Icon(Icons.keyboard_arrow_down),
                                label: const Text('Select'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  side: BorderSide(
                                      color: AppColors.primaryBlue, width: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ] else if (showSelectButton) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹ ${NumberFormat('#,##,###').format(basePrice!)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'for $_nights Night, ${widget.guests} Guests',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Including taxes & fees',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down),
                    label: const Text('Select'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: BorderSide(color: AppColors.primaryBlue, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showChargesSummary(BuildContext context, int roomPrice) {
    // Calculate breakdown
    final basePrice = (roomPrice * 0.88).round(); // Approximate base price
    final taxes = roomPrice - basePrice; // Taxes and fees

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Charges Summary',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Room details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).roomCharges,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹ ${NumberFormat('#,##,###').format(basePrice)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '₹ ${NumberFormat('#,##,###').format(basePrice)} x 1 room x $_nights night',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 14),
            // Taxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Taxes, Fees & Surcharges',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹ ${NumberFormat('#,##,###').format(taxes)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Charges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '₹ ${NumberFormat('#,##,###').format(roomPrice)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showPriceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 22),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Show price as',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Price per night option
            InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = 'Price per night';
                });
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      _selectedFilter == 'Price per night'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedFilter == 'Price per night'
                          ? AppColors.primaryBlue
                          : Colors.grey[400],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Price per night',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Total Price option
            InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = 'Total Price';
                });
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      _selectedFilter == 'Total Price'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedFilter == 'Total Price'
                          ? AppColors.primaryBlue
                          : Colors.grey[400],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class RoomOption {
  final String id;
  final String name;
  final int price;
  final DateTime cancellationDate;

  RoomOption({
    required this.id,
    required this.name,
    required this.price,
    required this.cancellationDate,
  });
}
