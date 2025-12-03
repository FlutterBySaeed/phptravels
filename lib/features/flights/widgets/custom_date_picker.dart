import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:phptravels/features/flights/models/trip_type.dart';

class DatePickerConfig {
  static const List<String> weekdays = [
    '',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  static const List<String> months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static const List<String> shortMonths = [
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
}

class CalendarMonth {
  final DateTime month;
  final List<DateTime> days;
  CalendarMonth(this.month, this.days);
}

class CustomDatePickerPage extends StatefulWidget {
  final bool isDeparture;
  final Function(DateTime?, DateTime?) onDateSelected;
  final DateTime? initialDepartureDate;
  final DateTime? initialReturnDate;
  final TripType tripType;

  const CustomDatePickerPage({
    super.key,
    required this.isDeparture,
    required this.onDateSelected,
    required this.tripType,
    this.initialDepartureDate,
    this.initialReturnDate,
  });

  @override
  State<CustomDatePickerPage> createState() => _CustomDatePickerPageState();
}

class _CustomDatePickerPageState extends State<CustomDatePickerPage> {
  late DateTime _departureDate;
  late DateTime? _returnDate;
  late bool _selectingDeparture;
  final ScrollController _scrollController = ScrollController();
  List<DateTime> _months = [];

  @override
  void initState() {
    super.initState();
    _departureDate = widget.initialDepartureDate ?? DateTime.now();
    _returnDate = widget.initialReturnDate;

    if (widget.tripType == TripType.roundTrip) {
      _selectingDeparture = widget.isDeparture;
    } else {
      _selectingDeparture = true;
    }

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

    if (!_selectingDeparture && _returnDate != null) {
      targetDate = _returnDate!;
    } else {
      targetDate = _departureDate;
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

    // Add previous month's days
    for (int i = 1; i < firstWeekday; i++) {
      days.add(DateTime(first.year, first.month, -(firstWeekday - i)));
    }

    // Add current month's days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(first.year, first.month, i));
    }

    // Add next month's days to fill grid
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

    // Prevent selecting past dates
    if (cleanSelected.isBefore(cleanToday)) return;

    if (widget.tripType == TripType.roundTrip) {
      // Original round trip logic
      if (_selectingDeparture) {
        setState(() {
          _departureDate = cleanSelected;

          // Clear return date if it's before or equal to new departure date
          if (_returnDate != null && !_returnDate!.isAfter(_departureDate)) {
            _returnDate = null;
          }
        });

        // Auto-switch to return date selection only if return is empty
        if (_returnDate == null) {
          setState(() => _selectingDeparture = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSelectedMonth();
          });
        }
      } else {
        // Return date must be AFTER departure date
        if (!cleanSelected.isAfter(_departureDate)) return;

        setState(() {
          _returnDate = cleanSelected;
        });

        // Callback and close
        widget.onDateSelected(_departureDate, _returnDate);
        Navigator.pop(context);
      }
    } else {
      // One-way and multi-city logic - select and close immediately
      setState(() {
        _departureDate = cleanSelected;
      });

      // Pass the date back correctly
      if (widget.tripType == TripType.oneWay) {
        widget.onDateSelected(_departureDate, null);
      } else if (widget.tripType == TripType.multiCity) {
        // For multi-city, we only pass the departure date (no return date)
        widget.onDateSelected(_departureDate, null);
      }

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
    final DateTime departure = _departureDate;

    if (cleanDay.isBefore(cleanToday)) return false;
    if (_selectingDeparture) return true;

    return cleanDay
        .isAfter(DateTime(departure.year, departure.month, departure.day));
  }

  bool _isDateInRange(DateTime day) {
    final DateTime departure = _departureDate;
    final DateTime? returnDate = _returnDate;
    if (returnDate == null) return false;

    final d = DateTime(departure.year, departure.month, departure.day);
    final r = DateTime(returnDate.year, returnDate.month, returnDate.day);
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

              // Create clean date for comparison
              final cleanDay = DateTime(day.year, day.month, day.day);
              final cleanDeparture = DateTime(_departureDate.year,
                  _departureDate.month, _departureDate.day);
              final cleanReturn = _returnDate != null
                  ? DateTime(
                      _returnDate!.year, _returnDate!.month, _returnDate!.day)
                  : null;

              final isDepartureSelected = _isSameDay(cleanDay, cleanDeparture);
              final isReturnSelected =
                  cleanReturn != null && _isSameDay(cleanDay, cleanReturn);
              final isSelected = isDepartureSelected || isReturnSelected;
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
    final bool showBothTabs = widget.tripType == TripType.roundTrip;
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
          showBothTabs ? l10n.selectDates : l10n.selectDepartureDate,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Column(
        children: [
          if (showBothTabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectingDeparture = true);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToSelectedMonth();
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            l10n.departureDate.toUpperCase(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _selectingDeparture
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
                            color: _selectingDeparture
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
                        setState(() => _selectingDeparture = false);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToSelectedMonth();
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            l10n.returnDate.toUpperCase(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: !_selectingDeparture
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodySmall
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
                            color: !_selectingDeparture
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
