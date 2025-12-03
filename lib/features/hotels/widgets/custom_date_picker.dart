import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime initialCheckIn;
  final DateTime initialCheckOut;

  const CustomDatePicker({
    super.key,
    required this.initialCheckIn,
    required this.initialCheckOut,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkInDate = widget.initialCheckIn;
    _checkOutDate = widget.initialCheckOut;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      if (_tabController.index == 0) {
        // Selecting check-in date
        _checkInDate = date;
        // Ensure check-out is at least 1 day after check-in
        if (_checkOutDate != null && !date.isBefore(_checkOutDate!)) {
          _checkOutDate = date.add(const Duration(days: 1));
        }
        // Auto-switch to check-out tab
        _tabController.animateTo(1);
      } else {
        // Selecting check-out date
        if (_checkInDate != null) {
          // Check-out must be at least 1 day after check-in
          if (date.isAfter(_checkInDate!)) {
            _checkOutDate = date;

            // Auto-close when both dates are selected
            if (_checkInDate != null && _checkOutDate != null) {
              Navigator.of(context).pop(DateTimeRange(
                start: _checkInDate!,
                end: _checkOutDate!,
              ));
            }
          }
          // If date is same as or before check-in, do nothing (invalid selection)
        }
      }
    });
  }

  int get _numberOfNights {
    if (_checkInDate != null && _checkOutDate != null) {
      return _checkOutDate!.difference(_checkInDate!).inDays;
    }
    return 0;
  }

  String _getDateRangeText() {
    if (_checkInDate == null || _checkOutDate == null) {
      return '';
    }
    final format = DateFormat('E, d MMM');
    final nights = _numberOfNights;
    return '${format.format(_checkInDate!)} - ${format.format(_checkOutDate!)} ($nights Night${nights != 1 ? 's' : ''})';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _tabController.index == 0
                            ? 'Pick check-in date'
                            : 'Pick check-out date',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_checkInDate != null && _checkOutDate != null)
                        Text(
                          _getDateRangeText(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), //
              ],
            ),
          ),
          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'CHECK-IN DATE'),
                Tab(text: 'CHECK-OUT DATE'),
              ],
            ),
          ),
          // Calendar
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCalendar(),
                _buildCalendar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final startMonth = DateTime(now.year, now.month, 1);

    return ListView.builder(
      itemCount: 12, // Show 12 months ahead
      itemBuilder: (context, index) {
        final monthDate =
            DateTime(startMonth.year, startMonth.month + index, 1);
        return Column(
          children: [
            // Month header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                DateFormat('MMMM yyyy').format(monthDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Day headers (only for first month)
            if (index == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 8),
            // Calendar grid
            _buildMonthGrid(monthDate),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildMonthGrid(DateTime monthDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    int firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(monthDate.year, monthDate.month, day);
      dayWidgets.add(_buildDayCell(date));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: dayWidgets,
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isCheckIn =
        _checkInDate != null && DateUtils.isSameDay(date, _checkInDate!);
    final isCheckOut =
        _checkOutDate != null && DateUtils.isSameDay(date, _checkOutDate!);
    final isInRange = _checkInDate != null &&
        _checkOutDate != null &&
        date.isAfter(_checkInDate!) &&
        date.isBefore(_checkOutDate!);
    final isPast =
        date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    // When on check-out tab, disable dates that are on or before check-in
    final isInvalidCheckOut = _tabController.index == 1 &&
        _checkInDate != null &&
        !date.isAfter(_checkInDate!);

    Color? backgroundColor;
    Color? textColor = Colors.black;
    FontWeight fontWeight = FontWeight.normal;

    if (isCheckIn || isCheckOut) {
      backgroundColor = AppColors.primaryBlue;
      textColor = Colors.white;
      fontWeight = FontWeight.w700;
    } else if (isInRange) {
      backgroundColor = AppColors.primaryBlue.withOpacity(0.1);
    }

    if (isPast || isInvalidCheckOut) {
      textColor = Colors.grey[300];
    }

    return InkWell(
      onTap: (isPast || isInvalidCheckOut) ? null : () => _onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
