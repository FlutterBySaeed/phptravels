import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/features/hotels/pages/hotel_destination_search_page.dart';
import 'package:phptravels/features/hotels/pages/hotels_results_page.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/search_provider.dart';
import 'package:phptravels/core/services/location_service.dart';
import 'package:uuid/uuid.dart';
import 'package:phptravels/core/services/hotel_search_history_model.dart';
import 'package:phptravels/core/services/search_history_service.dart';
import 'package:phptravels/core/widgets/hotel_recent_searches_section.dart';

class HotelsSearchPage extends StatefulWidget {
  const HotelsSearchPage({super.key});

  @override
  State<HotelsSearchPage> createState() => _HotelsSearchPageState();
}

class _HotelsSearchPageState extends State<HotelsSearchPage> {
  final TextEditingController _destinationController =
      TextEditingController(text: 'Karachi, Pakistan');
  DateTime? _checkInDate = DateTime.now();
  DateTime? _checkOutDate = DateTime.now().add(const Duration(days: 3));
  final List<HotelRoom> _rooms = [HotelRoom()];
  bool _isLoadingLocation = false;
  int _recentSearchesVersion = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SearchProvider>(context, listen: false);
      if (searchProvider.hotelDestination.isNotEmpty) {
        setState(() {
          _destinationController.text = searchProvider.hotelDestination;
        });
      }
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDestination() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: HotelDestinationSearchPage(
            onDestinationSelected: (city, country) {
              // For hotels, use "City, Country" format
              final hotelFormat = city.isNotEmpty && country.isNotEmpty
                  ? '$city, $country'
                  : city;
              setState(() => _destinationController.text = hotelFormat);
              // Update provider with formatted destination for flights
              final flightFormat =
                  '$city (${city.substring(0, 3).toUpperCase()})';
              Provider.of<SearchProvider>(context, listen: false)
                  .setDestination(flightFormat, city: city, country: country);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectDates({bool fromCheckIn = true}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => HotelDatePickerPage(
          isCheckIn: fromCheckIn,
          onDateSelected: (checkIn, checkOut) {
            setState(() {
              _checkInDate = checkIn;
              _checkOutDate = checkOut ?? checkIn?.add(const Duration(days: 1));
            });
          },
          initialCheckInDate: _checkInDate,
          initialCheckOutDate: _checkOutDate,
        ),
      ),
    );
  }

  Future<void> _editGuestsAndRooms() async {
    final updatedRooms = await showModalBottomSheet<List<HotelRoom>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: HotelGuestRoomPickerBottomSheet(initialRooms: _rooms),
        ),
      ),
    );

    if (updatedRooms != null) {
      setState(() {
        _rooms
          ..clear()
          ..addAll(updatedRooms);
      });
    }
  }

  String _formatDate(AppLocalizations l10n, DateTime? date) {
    if (date == null) return '--';
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('EEE, dd MMM', locale).format(date);
  }

  String _guestSummary(AppLocalizations l10n) {
    final totalGuests =
        _rooms.fold<int>(0, (sum, room) => sum + room.totalGuests);
    final roomCount = _rooms.length;
    final guestLabel = totalGuests == 1 ? l10n.guest : l10n.guests;
    final roomLabel = roomCount == 1 ? l10n.room : l10n.rooms;
    return '$totalGuests $guestLabel · $roomCount $roomLabel';
  }

  Future<void> _saveSearchToHistory() async {
    final search = HotelSearchHistory(
      id: const Uuid().v4(),
      location: _destinationController.text,
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      rooms: _rooms.length,
      guests: _rooms.fold<int>(0, (sum, room) => sum + room.totalGuests),
      createdAt: DateTime.now(),
    );

    await SearchHistoryService.saveHotelSearch(search);
  }

  void _populateFormFromHistory(HotelSearchHistory search) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelsResultsPage(
          location: search.location,
          checkInDate: search.checkInDate,
          checkOutDate: search.checkOutDate,
          rooms: search.rooms,
          guests: search.guests,
        ),
      ),
    );
  }

  Future<void> _handleLocationAccess() async {
    // Show loading state
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check and request permissions
      final hasPermission = await LocationService.requestLocationPermission();

      if (!hasPermission) {
        // Check if location services are disabled
        final serviceEnabled = await LocationService.isLocationServiceEnabled();

        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });

          if (!serviceEnabled) {
            // Location services are disabled
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please enable location services in your device settings.'),
                duration: Duration(seconds: 4),
              ),
            );
          } else {
            // Permission denied
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Location permission is required to use this feature.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
        return;
      }

      // Get current location
      final locationAddress = await LocationService.getCurrentLocationAddress();

      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        if (locationAddress != null) {
          _destinationController.text = locationAddress;

          await _saveSearchToHistory();
          setState(() {
            _recentSearchesVersion++;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelsResultsPage(
                location: locationAddress,
                checkInDate: _checkInDate!,
                checkOutDate: _checkOutDate!,
                rooms: _rooms.length,
                guests:
                    _rooms.fold<int>(0, (sum, room) => sum + room.totalGuests),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Unable to retrieve your location. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.hotelsSearchTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
              child: _isLoadingLocation
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      color: AppColors.primaryBlue.withOpacity(0.15),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryBlue),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Getting your location...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _HighlightBanner(
                      text: l10n.needPlaceTonight,
                      onTap: _handleLocationAccess,
                    ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchCard(
                destinationChild: _CompactInfoTile(
                  icon: LucideIcons.search,
                  title: l10n.destination,
                  value: _destinationController.text,
                  onTap: _selectDestination,
                ),
                dateChild: _CompactDateTile(
                  checkInLabel: l10n.checkIn,
                  checkOutLabel: l10n.checkOut,
                  checkInValue: _formatDate(l10n, _checkInDate),
                  checkOutValue: _formatDate(l10n, _checkOutDate),
                  onTap: () => _selectDates(fromCheckIn: true),
                ),
                guestsChild: _CompactInfoTile(
                  icon: LucideIcons.doorOpen,
                  title: l10n.guestsAndRooms,
                  value: _guestSummary(l10n),
                  onTap: _editGuestsAndRooms,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_checkInDate != null && _checkOutDate != null) {
                      await _saveSearchToHistory();
                      setState(() {
                        _recentSearchesVersion++;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelsResultsPage(
                            location: _destinationController.text,
                            checkInDate: _checkInDate!,
                            checkOutDate: _checkOutDate!,
                            rooms: _rooms.length,
                            guests: _rooms.fold<int>(
                                0, (sum, room) => sum + room.totalGuests),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    l10n.searchHotels,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HotelRecentSearchesSection(
                key: ValueKey(_recentSearchesVersion),
                onSearchSelected: (search) {
                  _populateFormFromHistory(search);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class HotelRoom {
  int adults;
  int children;
  final List<int> childAges;

  HotelRoom({
    this.adults = 2,
    this.children = 0,
    List<int>? childAges,
  }) : childAges = childAges ?? [];

  int get totalGuests => adults + children;

  HotelRoom copy() => HotelRoom(
        adults: adults,
        children: children,
        childAges: List<int>.from(childAges),
      );
}

class _HighlightBanner extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _HighlightBanner({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: EdgeInsets.zero,
        color: AppColors.primaryBlue.withOpacity(0.15),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final Widget destinationChild;
  final Widget dateChild;
  final Widget guestsChild;

  const _SearchCard({
    required this.destinationChild,
    required this.dateChild,
    required this.guestsChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          destinationChild,
          const _FullHeightDivider(),
          dateChild,
          const _FullHeightDivider(),
          guestsChild,
        ],
      ),
    );
  }
}

class _FullHeightDivider extends StatelessWidget {
  const _FullHeightDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}

class _CompactInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _CompactInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
}

class _CompactDateTile extends StatelessWidget {
  final String checkInLabel;
  final String checkOutLabel;
  final String checkInValue;
  final String checkOutValue;
  final VoidCallback onTap;

  const _CompactDateTile({
    required this.checkInLabel,
    required this.checkOutLabel,
    required this.checkInValue,
    required this.checkOutValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            children: [
              Icon(LucideIcons.calendar,
                  size: 20, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(checkInLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      checkInValue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0),
                width: 1,
                height: 62,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(checkOutLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      checkOutValue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
}

class HotelDatePickerPage extends StatefulWidget {
  final bool isCheckIn;
  final Function(DateTime?, DateTime?) onDateSelected;
  final DateTime? initialCheckInDate;
  final DateTime? initialCheckOutDate;

  const HotelDatePickerPage({
    super.key,
    required this.isCheckIn,
    required this.onDateSelected,
    this.initialCheckInDate,
    this.initialCheckOutDate,
  });

  @override
  State<HotelDatePickerPage> createState() => _HotelDatePickerPageState();
}

class _HotelDatePickerPageState extends State<HotelDatePickerPage> {
  late DateTime _checkInDate;
  late DateTime? _checkOutDate;
  late bool _selectingCheckIn;
  final ScrollController _scrollController = ScrollController();
  List<DateTime> _months = [];

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.initialCheckInDate ?? DateTime.now();
    _checkOutDate = widget.initialCheckOutDate;
    _selectingCheckIn = widget.isCheckIn;
    _generateMonths();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateMonths() {
    final now = DateTime.now();
    _months = List.generate(24, (index) {
      return DateTime(now.year, now.month + index, 1);
    });
  }

  void _scrollToSelectedMonth() {
    DateTime targetDate;

    if (!_selectingCheckIn && _checkOutDate != null) {
      targetDate = _checkOutDate!;
    } else {
      targetDate = _checkInDate;
    }

    final targetMonthIndex = _months.indexWhere(
      (month) =>
          month.year == targetDate.year && month.month == targetDate.month,
    );

    if (targetMonthIndex != -1 && mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollController.animateTo(
            targetMonthIndex * 320.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  List<DateTime> _getDaysInMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final last = DateTime(date.year, date.month + 1, 0);
    final daysInMonth = last.day;
    final firstWeekday = first.weekday;

    List<DateTime> days = [];

    for (int i = 1; i < firstWeekday; i++) {
      days.add(DateTime(first.year, first.month, -(firstWeekday - i)));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(first.year, first.month, i));
    }

    int totalCells = days.length > 35 ? 42 : 35;
    int nextDay = 1;
    while (days.length < totalCells) {
      days.add(DateTime(first.year, first.month + 1, nextDay));
      nextDay++;
    }

    return days;
  }

  void _onDateSelected(DateTime selectedDate) {
    final today = DateTime.now();
    final cleanToday = DateTime(today.year, today.month, today.day);
    final cleanSelected =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (cleanSelected.isBefore(cleanToday)) return;

    if (_selectingCheckIn) {
      setState(() {
        _checkInDate = cleanSelected;

        if (_checkOutDate != null && !_checkOutDate!.isAfter(_checkInDate)) {
          _checkOutDate = null;
        }
      });

      if (_checkOutDate == null) {
        setState(() => _selectingCheckIn = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedMonth();
        });
      } else {
        widget.onDateSelected(_checkInDate, _checkOutDate);
        Navigator.pop(context);
      }
    } else {
      if (!cleanSelected.isAfter(_checkInDate)) return;

      setState(() {
        _checkOutDate = cleanSelected;
      });

      widget.onDateSelected(_checkInDate, _checkOutDate);
      Navigator.pop(context);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isDateSelectable(DateTime day) {
    final now = DateTime.now();
    final cleanToday = DateTime(now.year, now.month, now.day);
    final cleanDay = DateTime(day.year, day.month, day.day);
    final DateTime checkIn = _checkInDate;

    if (cleanDay.isBefore(cleanToday)) return false;
    if (_selectingCheckIn) return true;

    return cleanDay.isAfter(DateTime(checkIn.year, checkIn.month, checkIn.day));
  }

  bool _isDateInRange(DateTime day) {
    final DateTime checkIn = _checkInDate;
    final DateTime? checkOut = _checkOutDate;
    if (checkOut == null) return false;

    final d = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final r = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final current = DateTime(day.year, day.month, day.day);

    return current.isAfter(d) && current.isBefore(r);
  }

  Widget _buildCalendar(BuildContext context, DateTime currentMonth) {
    final days = _getDaysInMonth(currentMonth);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final monthLabel = DateFormat('MMMM yyyy', localeName).format(currentMonth);
    final weekdayLabels = List.generate(
      7,
      (index) =>
          DateFormat.E(localeName).format(DateTime.utc(2020, 1, 6 + index)),
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
          ),
          child: Center(
            child: Text(
              monthLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == currentMonth.month;
              final isSelectable = isCurrentMonth && _isDateSelectable(day);

              final cleanDay = DateTime(day.year, day.month, day.day);
              final cleanCheckIn = DateTime(
                  _checkInDate.year, _checkInDate.month, _checkInDate.day);
              final cleanCheckOut = _checkOutDate != null
                  ? DateTime(_checkOutDate!.year, _checkOutDate!.month,
                      _checkOutDate!.day)
                  : null;

              final isCheckInSelected = _isSameDay(cleanDay, cleanCheckIn);
              final isCheckOutSelected =
                  cleanCheckOut != null && _isSameDay(cleanDay, cleanCheckOut);
              final isSelected = isCheckInSelected || isCheckOutSelected;
              final isInRange = _isDateInRange(cleanDay);

              return GestureDetector(
                onTap: isSelectable ? () => _onDateSelected(day) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : isInRange
                            ? AppColors.primaryBlue.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : !isCurrentMonth
                                ? Theme.of(context).textTheme.bodySmall?.color
                                : !isSelectable
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).iconTheme.color, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.selectDates,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectingCheckIn = true);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToSelectedMonth();
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          l10n.checkIn.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _selectingCheckIn
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                        : Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: _selectingCheckIn
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectingCheckIn = false);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToSelectedMonth();
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          l10n.checkOut.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: !_selectingCheckIn
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                        : Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: !_selectingCheckIn
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _months.length,
              itemBuilder: (context, index) =>
                  _buildCalendar(context, _months[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class HotelGuestRoomPickerBottomSheet extends StatefulWidget {
  final List<HotelRoom> initialRooms;

  const HotelGuestRoomPickerBottomSheet(
      {super.key, required this.initialRooms});

  @override
  State<HotelGuestRoomPickerBottomSheet> createState() =>
      _HotelGuestRoomPickerBottomSheetState();
}

class _HotelGuestRoomPickerBottomSheetState
    extends State<HotelGuestRoomPickerBottomSheet> {
  late List<HotelRoom> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = widget.initialRooms.map((room) => room.copy()).toList();
  }

  void _updateAdults(int roomIndex, int newValue) {
    setState(() {
      _rooms[roomIndex].adults = newValue.clamp(1, 6);
    });
  }

  void _updateChildren(int roomIndex, int newValue) {
    setState(() {
      final room = _rooms[roomIndex];
      room.children = newValue.clamp(0, 6);
      if (room.childAges.length > room.children) {
        room.childAges.removeRange(room.children, room.childAges.length);
      } else {
        while (room.childAges.length < room.children) {
          room.childAges.add(5);
        }
      }
    });
  }

  void _updateChildAge(int roomIndex, int childIndex, int age) {
    setState(() {
      _rooms[roomIndex].childAges[childIndex] = age;
    });
  }

  void _addRoom() {
    setState(() {
      _rooms.add(HotelRoom());
    });
  }

  void _removeRoom(int index) {
    if (_rooms.length == 1) return;
    setState(() {
      _rooms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        children: [
          _BottomSheetHeader(
            title: l10n.guestsAndRooms,
            onClose: () => Navigator.pop(context),
            onApply: () => Navigator.pop(
                context, _rooms.map((room) => room.copy()).toList()),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _rooms.length + 1,
              itemBuilder: (context, index) {
                if (index < _rooms.length) {
                  return _RoomEditor(
                    room: _rooms[index],
                    index: index,
                    onAdultsChanged: (value) => _updateAdults(index, value),
                    onChildrenChanged: (value) => _updateChildren(index, value),
                    onChildAgeChanged: (childIndex, age) =>
                        _updateChildAge(index, childIndex, age),
                    onRemoveRoom: () => _removeRoom(index),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _addRoom,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.addRoom,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback onApply;

  const _BottomSheetHeader({
    required this.title,
    required this.onClose,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: onApply,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

class _RoomEditor extends StatelessWidget {
  final HotelRoom room;
  final int index;
  final ValueChanged<int> onAdultsChanged;
  final ValueChanged<int> onChildrenChanged;
  final void Function(int childIndex, int age) onChildAgeChanged;
  final VoidCallback onRemoveRoom;

  const _RoomEditor({
    required this.room,
    required this.index,
    required this.onAdultsChanged,
    required this.onChildrenChanged,
    required this.onChildAgeChanged,
    required this.onRemoveRoom,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canRemove = index > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${l10n.room} ${index + 1}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            if (canRemove)
              TextButton(
                onPressed: onRemoveRoom,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.removeRoom,
                  style: const TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.red,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.person, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adults,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '> 17 ${l10n.years}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: room.adults > 1
                      ? () => onAdultsChanged(room.adults - 1)
                      : null,
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    room.adults.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onTap: room.adults < 6
                      ? () => onAdultsChanged(room.adults + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.person, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.children,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '≤ 17 ${l10n.years}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: room.children > 0
                      ? () => onChildrenChanged(room.children - 1)
                      : null,
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    room.children.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onTap: room.children < 6
                      ? () => onChildrenChanged(room.children + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
        if (room.children > 0) ...[
          const SizedBox(height: 16),
          // MODIFIED: Removed the decoration (border bottom) here as requested
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.ageOfChildren,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: List.generate(room.children, (childIndex) {
              return SizedBox(
                width: 70,
                child: _AgeDropdown(
                  value: room.childAges[childIndex],
                  onChanged: (age) => onChildAgeChanged(childIndex, age),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 24),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled
                ? Theme.of(context).iconTheme.color!
                : Theme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled
              ? Theme.of(context).iconTheme.color
              : Theme.of(context).dividerColor,
          weight: 2,
        ),
      ),
    );
  }
}

class _AgeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _AgeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      // MODIFIED: Added menuMaxHeight to limit to ~4 items and isDense for smaller vertical footprint
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        isDense: true,
        menuMaxHeight: 200,
        underline: const SizedBox.shrink(),
        items: List.generate(
          18,
          (index) => DropdownMenuItem(
            value: index,
            child: Text(index.toString()),
          ),
        ),
        onChanged: (age) {
          if (age != null) {
            onChanged(age);
          }
        },
      ),
    );
  }
}
