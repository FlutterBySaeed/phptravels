import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/SERVICES/airport_service.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkBlue = Color(0xFF1D4ED8);
  static const Color lightBlue = Color(0xFFE0F2FE);
  static const Color veryLightBlue = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF22C55E);
}

class AppTextStyles {
  static const TextStyle title = TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter');
  static const TextStyle bodySmall = TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter');
  static const TextStyle bodyMedium = TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Inter');
  static const TextStyle bodyMediumBold = TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter');
  static const TextStyle button = TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter', letterSpacing: 0.2);
}

enum TripType { oneWay, roundTrip, multiCity }

class PassengerCount {
  int adults;
  int children;
  int infants;

  PassengerCount({this.adults = 1, this.children = 0, this.infants = 0});

  PassengerCount copyWith({int? adults, int? children, int? infants}) {
    return PassengerCount(adults: adults ?? this.adults, children: children ?? this.children, infants: infants ?? this.infants);
  }

  int get total => adults + children + infants;
}

class MultiCitySegment {
  String from;
  String to;
  DateTime? date;
  TextEditingController fromController;
  TextEditingController toController;

  MultiCitySegment({this.from = '', this.to = '', this.date})
      : fromController = TextEditingController(text: from),
        toController = TextEditingController(text: to);

  MultiCitySegment copyWith({String? from, String? to, DateTime? date}) {
    return MultiCitySegment(from: from ?? this.from, to: to ?? this.to, date: date ?? this.date);
  }

  void dispose() {
    fromController.dispose();
    toController.dispose();
  }
}

class FlightsSearchPage extends StatefulWidget {
  const FlightsSearchPage({super.key});
  @override
  State<FlightsSearchPage> createState() => _FlightsSearchPageState();
}

class _FlightsSearchPageState extends State<FlightsSearchPage> {
  TripType _tripType = TripType.roundTrip;
  final TextEditingController _oneWayFromController = TextEditingController(text: 'Lahore (LHE)');
  final TextEditingController _oneWayToController = TextEditingController();
  final TextEditingController _roundTripFromController = TextEditingController(text: 'Lahore (LHE)');
  final TextEditingController _roundTripToController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;
  PassengerCount _passengers = PassengerCount();
  String _cabinClass = 'Economy';
  final List<MultiCitySegment> _multiCitySegments = [];

  @override
  void initState() {
    super.initState();
    _departureDate = DateTime.now();
    _initializeMultiCitySegments();
  }

  void _initializeMultiCitySegments() {
  _multiCitySegments.clear(); 
  _multiCitySegments.add(
    MultiCitySegment(
      from: 'LHE',
      date: DateTime.now(), 
    )
  );
  _multiCitySegments.add(MultiCitySegment());
}

  @override
  void dispose() {
    _oneWayFromController.dispose();
    _oneWayToController.dispose();
    _roundTripFromController.dispose();
    _roundTripToController.dispose();
    for (final segment in _multiCitySegments) {
      segment.dispose();
    }
    super.dispose();
  }

  void _updateTripType(TripType type) {
    setState(() {
      _tripType = type;
    });
  }

  void _swapAirports() {
    setState(() {
      if (_tripType == TripType.oneWay) {
        final temp = _oneWayFromController.text;
        _oneWayFromController.text = _oneWayToController.text;
        _oneWayToController.text = temp;
      } else if (_tripType == TripType.roundTrip) {
        final temp = _roundTripFromController.text;
        _roundTripFromController.text = _roundTripToController.text;
        _roundTripToController.text = temp;
      }
    });
  }

  void _updatePassengers(PassengerCount newCount) {
    setState(() {
      _passengers = newCount;
    });
  }

  void _updateCabinClass(String cabinClass) {
    setState(() {
      _cabinClass = cabinClass;
    });
  }

  void _updateDates(DateTime? departure, DateTime? returnDate) {
    setState(() {
      _departureDate = departure;
      _returnDate = returnDate;
    });
  }

  void _updateMultiCitySegment(int index, MultiCitySegment newSegment) {
    setState(() {
      if (index < _multiCitySegments.length) {
        _multiCitySegments[index].fromController.text = newSegment.from;
        _multiCitySegments[index].toController.text = newSegment.to;
        _multiCitySegments[index].date = newSegment.date;
        _multiCitySegments[index].from = newSegment.from;
        _multiCitySegments[index].to = newSegment.to;
      }
    });
  }

  void _addMultiCitySegment() {
    if (_multiCitySegments.length < 4) {
      setState(() {
        _multiCitySegments.add(MultiCitySegment());
      });
    }
  }

  void _removeMultiCitySegment(int index) {
    if (_multiCitySegments.length > 2) {
      setState(() {
        _multiCitySegments.removeAt(index);
      });
    }
  }

  void _onFieldsUpdated() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              TripTypeSelector(currentType: _tripType, onTypeChanged: _updateTripType),
              const SizedBox(height: 6),
              _buildSearchForm(),
              const SizedBox(height: 30),
              const SearchButton(),
            ],
          ),
        ),
      ),
    );
  }

 PreferredSizeWidget _buildAppBar() {
  return AppBar(
    backgroundColor: AppColors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text('Flights Search', style: AppTextStyles.title),
    titleSpacing: 0,
    centerTitle: false,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        color: AppColors.borderLight,
        height: 1,
      ),
    ),
  );
}
  Widget _buildSearchForm() {
    switch (_tripType) {
      case TripType.oneWay:
        return OneWayForm(
          fromController: _oneWayFromController,
          toController: _oneWayToController,
          departureDate: _departureDate,
          passengers: _passengers,
          cabinClass: _cabinClass,
          onSwapAirports: _swapAirports,
          onDateSelected: (date, _) => _updateDates(date, null),
          onPassengersChanged: _updatePassengers,
          onCabinClassChanged: _updateCabinClass,
          onFieldsUpdated: _onFieldsUpdated,
        );
      case TripType.roundTrip:
        return RoundTripForm(
          fromController: _roundTripFromController,
          toController: _roundTripToController,
          departureDate: _departureDate,
          returnDate: _returnDate,
          passengers: _passengers,
          cabinClass: _cabinClass,
          onSwapAirports: _swapAirports,
          onDateSelected: _updateDates,
          onPassengersChanged: _updatePassengers,
          onCabinClassChanged: _updateCabinClass,
          onFieldsUpdated: _onFieldsUpdated,
        );
      case TripType.multiCity:
        return MultiCityForm(
          segments: _multiCitySegments,
          passengers: _passengers,
          cabinClass: _cabinClass,
          onSegmentUpdated: _updateMultiCitySegment,
          onSegmentAdded: _addMultiCitySegment,
          onSegmentRemoved: _removeMultiCitySegment,
          onPassengersChanged: _updatePassengers,
          onCabinClassChanged: _updateCabinClass,
        );
    }
  }
}

class TripTypeSelector extends StatelessWidget {
  final TripType currentType;
  final ValueChanged<TripType> onTypeChanged;

  const TripTypeSelector({super.key, required this.currentType, required this.onTypeChanged});

  @override
  Widget build(BuildContext context) {
    final types = TripType.values;
    final labels = ['One-way', 'Round-trip', 'Multi-city'];

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(types.length, (index) {
  final isSelected = currentType == types[index];
  return GestureDetector(
    onTap: () => onTypeChanged(types[index]),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5), // Reduced margin
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 1, offset: const Offset(0, 1))] : [],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced horizontal padding
      child: Text(
        labels[index],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10, // Reduced font size
          fontFamily: 'Inter',
          color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
        ),
      ),
    ),
  );
}),
      ),
    );
  }
}

class _FormContainer extends StatelessWidget {
  final List<Widget> children;
  const _FormContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class OneWayForm extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final DateTime? departureDate;
  final PassengerCount passengers;
  final String cabinClass;
  final VoidCallback onSwapAirports;
  final Function(DateTime?, DateTime?) onDateSelected;
  final ValueChanged<PassengerCount> onPassengersChanged;
  final ValueChanged<String> onCabinClassChanged;
  final VoidCallback onFieldsUpdated;

  const OneWayForm({
    super.key,
    required this.fromController,
    required this.toController,
    required this.departureDate,
    required this.passengers,
    required this.cabinClass,
    required this.onSwapAirports,
    required this.onDateSelected,
    required this.onPassengersChanged,
    required this.onCabinClassChanged,
    required this.onFieldsUpdated,
  });

    @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _FormContainer(
          children: [
            AirportField(label: 'From', controller: fromController,  hint: '', isFromField: true, onFieldUpdated: onFieldsUpdated),
            const _Divider(),
            AirportField(label: '', controller: toController,  hint: 'To', isFromField: false, onFieldUpdated: onFieldsUpdated),
            const _Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: DateField(label: 'Departure Date', date: departureDate, isDeparture: true, onDateSelected: (date, _) => onDateSelected(date, null)),
            ),
            const _Divider(),
            PassengerClassRow(passengers: passengers, cabinClass: cabinClass, onTap: () => _showPassengerPicker(context)),
            const _Divider(),
            const PaymentSection(),
          ],
        ),
        Positioned(
          top: 56,
          right: 20,
          child: _SwapButton(onTap: onSwapAirports),
        ),
      ],
    );
  }

  void _showPassengerPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      minChildSize: 0.56,
      maxChildSize: 0.70,
      builder: (context, scrollController) => PassengerPickerBottomSheet(
        passengers: passengers,
        cabinClass: cabinClass,
        onApply: (newPassengers, newCabinClass) {
          onPassengersChanged(newPassengers);
          onCabinClassChanged(newCabinClass);
        },
      ),
    ),
  );
}
}

class RoundTripForm extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final PassengerCount passengers;
  final String cabinClass;
  final VoidCallback onSwapAirports;
  final Function(DateTime?, DateTime?) onDateSelected;
  final ValueChanged<PassengerCount> onPassengersChanged;
  final ValueChanged<String> onCabinClassChanged;
  final VoidCallback onFieldsUpdated;

  const RoundTripForm({
    super.key,
    required this.fromController,
    required this.toController,
    required this.departureDate,
    required this.returnDate,
    required this.passengers,
    required this.cabinClass,
    required this.onSwapAirports,
    required this.onDateSelected,
    required this.onPassengersChanged,
    required this.onCabinClassChanged,
    required this.onFieldsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _FormContainer(

          children: [
            
            AirportField(label: 'From', controller: fromController,  hint: '', isFromField: true, onFieldUpdated: onFieldsUpdated),
            const _Divider(),
            AirportField(label: '', controller: toController,  hint: 'To', isFromField: false, onFieldUpdated: onFieldsUpdated),
            const _Divider(),
            

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  child: SizedBox(
    height: 76,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _RoundTripDateField(
              label: 'Departure Date',
              date: departureDate,
              isDeparture: true,
              onDateSelected: onDateSelected,
              initialDepartureDate: departureDate,
              initialReturnDate: returnDate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16), // ← ADJUST THIS (8, 12, 16, 20, etc.)
            child: Container(
              width: 1,
              color: AppColors.borderLight,
            ),
          ),
          Expanded(
            child: _RoundTripDateField(
              label: 'Return Date',
              date: returnDate,
              isDeparture: false,
              onDateSelected: onDateSelected,
              initialDepartureDate: departureDate,
              initialReturnDate: returnDate,
            ),
          ),
        ],
      ),
    ),
  ),
),
            const _Divider(),
            PassengerClassRow(passengers: passengers, cabinClass: cabinClass, onTap: () => _showPassengerPicker(context)),
            const _Divider(),
            const PaymentSection(),
          ],
        ),
        Positioned(
          top: 56,
          right: 20,
          child: _SwapButton(onTap: onSwapAirports),
        ),
      ],
    );
  }
  void _showPassengerPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      minChildSize: 0.56,
      maxChildSize: 0.70,
      builder: (context, scrollController) => PassengerPickerBottomSheet(
        passengers: passengers,
        cabinClass: cabinClass,
        onApply: (newPassengers, newCabinClass) {
          onPassengersChanged(newPassengers);
          onCabinClassChanged(newCabinClass);
        },
      ),
    ),
  );
}
}

class MultiCityForm extends StatefulWidget {
  final List<MultiCitySegment> segments;
  final PassengerCount passengers;
  final String cabinClass;
  final Function(int, MultiCitySegment) onSegmentUpdated;
  final VoidCallback onSegmentAdded;
  final Function(int) onSegmentRemoved;
  final ValueChanged<PassengerCount> onPassengersChanged;
  final ValueChanged<String> onCabinClassChanged;

  const MultiCityForm({
    super.key,
    required this.segments,
    required this.passengers,
    required this.cabinClass,
    required this.onSegmentUpdated,
    required this.onSegmentAdded,
    required this.onSegmentRemoved,
    required this.onPassengersChanged,
    required this.onCabinClassChanged,
  });

  @override
  State<MultiCityForm> createState() => _MultiCityFormState();
}

class _MultiCityFormState extends State<MultiCityForm> {
  // Sort segments by date
  List<MultiCitySegment> get sortedSegments {
    final sorted = List<MultiCitySegment>.from(widget.segments);
    
    sorted.sort((a, b) {
      // Handle null dates - put them at the end
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      
      // Compare dates
      return a.date!.compareTo(b.date!);
    });
    
    return sorted;
  }
  // Enhanced update function that triggers rebuild
  void _onSegmentUpdated(int index, MultiCitySegment updatedSegment) {
    widget.onSegmentUpdated(index, updatedSegment);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sortedSegmentsList = sortedSegments;
    
    return _FormContainer(
      children: [
        Column(
          children: [
            for (int i = 0; i < sortedSegmentsList.length; i++) ...[
              MultiCitySegmentRow(
                segment: sortedSegmentsList[i],
                index: widget.segments.indexOf(sortedSegmentsList[i]),
                canRemove: widget.segments.length > 2,
                onSegmentUpdated: (updatedSegment) {
                  final originalIndex = widget.segments.indexOf(sortedSegmentsList[i]);
                  _onSegmentUpdated(originalIndex, updatedSegment);
                },
                onSegmentRemoved: () {
                  final originalIndex = widget.segments.indexOf(sortedSegmentsList[i]);
                  widget.onSegmentRemoved(originalIndex);
                },
              ),
              if (i < sortedSegmentsList.length - 1) const _Divider(),
            ],
          ],
        ),
        const _Divider(),
        if (widget.segments.length < 4) _AddFlightButton(onTap: widget.onSegmentAdded),
        if (widget.segments.length < 4) const _Divider(),
        PassengerClassRow(
          passengers: widget.passengers, 
          cabinClass: widget.cabinClass, 
          onTap: () => _showPassengerPicker(context)
        ),
        const _Divider(),
        const PaymentSection(),
      ],
    );
  }

  void _showPassengerPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      minChildSize: 0.56,
      maxChildSize: 0.70,
      builder: (context, scrollController) => PassengerPickerBottomSheet(
        passengers: widget.passengers,  // ← ADD widget.
        cabinClass: widget.cabinClass,  // ← ADD widget.
        onApply: (newPassengers, newCabinClass) {
          widget.onPassengersChanged(newPassengers);  // ← ADD widget.
          widget.onCabinClassChanged(newCabinClass);  // ← ADD widget.
        },
      ),
    ),
  );
}
}
class AirportField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  // final IconData icon;
  final String? hint;
  final bool isFromField;
  final VoidCallback onFieldUpdated;

  const AirportField({
    super.key,
    required this.label,
    required this.controller,
    // required this.icon,
    this.hint,
    required this.isFromField,
    required this.onFieldUpdated,
  });

  @override
Widget build(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => _showDestinationSearch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12), // Increased vertical padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32, 
              height: 32, 
              alignment: Alignment.center,
                child: isFromField 
                  ? const Icon(LucideIcons.planeTakeoff, size: 18, color: Colors.black)
                  : const Icon(LucideIcons.planeLanding, size: 18, color: Colors.black),
            
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45, 
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label.isNotEmpty) Text(label, style: AppTextStyles.bodySmall),
                    if (label.isNotEmpty) const SizedBox(height: 3),
                    Text(
                      controller.text.isEmpty ? (hint ?? '') : controller.text,
                      style: TextStyle(
                        color: controller.text.isEmpty ? AppColors.borderLight : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: controller.text.isEmpty ? FontWeight.w700 : FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showDestinationSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationSearchPage(
          onDestinationSelected: (destination) {
            controller.text = destination;
            onFieldUpdated();
          },
        ),
      ),
    );
  }
}

class DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isDeparture;
  final Function(DateTime?, DateTime?) onDateSelected;

  const DateField({
    super.key,
    required this.label,
    required this.date,
    required this.isDeparture,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDatePicker(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Increased vertical padding
          child: Row(
            children: [
              if (isDeparture) Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(LucideIcons.calendar, size: 18, color: Colors.black)), // Changed to black
              if (isDeparture) const SizedBox(width: 8),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
  final displayText = _getDisplayText();
  return Container(
    height: 36, // Increased height
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 3),
        Text(
          displayText, 
          style: AppTextStyles.bodyMediumBold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

  String _getDisplayText() {
    if (date != null) {
      return '${_getWeekday(date!.weekday)}, ${date!.day} ${_getMonth(date!.month)}';
    }
    return isDeparture ? 'Today' : 'Return Date';
  }

  void _showDatePicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CustomDatePickerPage(
          isDeparture: isDeparture,
          onDateSelected: onDateSelected,
          initialDepartureDate: isDeparture ? date : null,
          initialReturnDate: !isDeparture ? date : null,
          tripType: TripType.oneWay,
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  String _getMonth(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}

class MultiCitySegmentRow extends StatefulWidget {
  final MultiCitySegment segment;
  final int index;
  final bool canRemove;
  final ValueChanged<MultiCitySegment> onSegmentUpdated;
  final VoidCallback onSegmentRemoved;

  const MultiCitySegmentRow({
    super.key,
    required this.segment,
    required this.index,
    required this.canRemove,
    required this.onSegmentUpdated,
    required this.onSegmentRemoved,
  });

  @override
  State<MultiCitySegmentRow> createState() => _MultiCitySegmentRowState();
}

class _MultiCitySegmentRowState extends State<MultiCitySegmentRow> {
  void _onFieldUpdated() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced horizontal padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Remove Button - moved slightly left
          Container(
            height: 42,
            child: Center(
              child: _RemoveSegmentButton(
                canRemove: widget.canRemove, 
                onRemove: widget.onSegmentRemoved
              ),
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing
          
          
          const SizedBox(width: 12),
          
          
          Expanded(
            flex: 1,
            child: _CompactAirportField(
              label: 'From',
              controller: widget.segment.fromController,
              onDestinationSelected: (destination) {
                widget.segment.from = destination;
                widget.onSegmentUpdated(widget.segment);
              },
              onFieldUpdated: _onFieldUpdated,
            ),
          ),
          
          
          Container(
            width: 1,
            height: 30,
            color: AppColors.borderLight,
          ),
          const SizedBox(width: 8),
          
          // To Field
          Expanded(
            flex: 1,
            child: _CompactAirportField(
              label: 'To',
              controller: widget.segment.toController,
              onDestinationSelected: (destination) {
                widget.segment.to = destination;
                widget.onSegmentUpdated(widget.segment);
              },
              onFieldUpdated: _onFieldUpdated,
            ),
          ),
          
          // Vertical Divider between To and Date
          Container(
            width: 1,
            height: 30,
            color: AppColors.borderLight,
          ),
          const SizedBox(width: 8),
          
          // Date Field
          Expanded(
            flex: 1,
            child: _CompactDateField(
              date: widget.segment.date,
              onDateSelected: (date) {
                setState(() {
                  widget.segment.date = date;
                  widget.onSegmentUpdated(widget.segment);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _CompactAirportField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onDestinationSelected;
  final VoidCallback onFieldUpdated;

  const _CompactAirportField({
    required this.label,
    required this.controller,
    required this.onDestinationSelected,
    required this.onFieldUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final display = controller.text.isNotEmpty ? controller.text : '...';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDestinationSearch(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 54, // Increased height
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Container(
                height: 28, // Increased height
                alignment: Alignment.centerLeft,
                child: Text(
                  display,
                  style: TextStyle(
                    color: controller.text.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: controller.text.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDestinationSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationSearchPage(
          onDestinationSelected: (destination) {
            onDestinationSelected(destination);
            onFieldUpdated();
          },
        ),
      ),
    );
  }
}

class _CompactDateField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime?> onDateSelected;

  const _CompactDateField({required this.date, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDatePicker(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 54, // Increased height
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Date', style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Container(
                height: 28, // Increased height
                alignment: Alignment.centerLeft,
                child: Text(
                  date != null ? '${date!.day}, ${_getMonth(date!.month)}' : '...',
                  style: TextStyle(
                    color: date != null ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: date != null ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CustomDatePickerPage(
          isDeparture: true,
          onDateSelected: (departureDate, returnDate) => onDateSelected(departureDate),
          initialDepartureDate: date,
          tripType: TripType.multiCity,
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}

class PassengerClassRow extends StatelessWidget {
  final PassengerCount passengers;
  final String cabinClass;
  final VoidCallback onTap;

  const PassengerClassRow({super.key, required this.passengers, required this.cabinClass, required this.onTap});

  @override
Widget build(BuildContext context) {
  final passengerText = _buildPassengerText();
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12), // Increased vertical padding
        child: Row(
          children: [
            Container(
              width: 32, 
              height: 32, 
              alignment: Alignment.center, 
              child: Icon(LucideIcons.users, size: 18, color: Colors.black) // Changed to black
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 47, // Increased height
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      '$passengerText · $cabinClass', 
                      style: AppTextStyles.bodyMediumBold, 
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  String _buildPassengerText() {
    final parts = <String>[];
    parts.add('${passengers.adults} Adult${passengers.adults > 1 ? 's' : ''}');
    if (passengers.children > 0) {
      parts.add('${passengers.children} Child${passengers.children > 1 ? 'ren' : ''}');
    }
    if (passengers.infants > 0) {
      parts.add('${passengers.infants} Infant${passengers.infants > 1 ? 's' : ''}');
    }
    return parts.join(', ');
  }
}

class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPaymentPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 32, 
                height: 32, 
                alignment: Alignment.center, 
                child: Icon(LucideIcons.creditCard, size: 20, color: Colors.black)
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 46,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Payment Types', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 3),
                      _buildPaymentLogos(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentLogos() {
    return SizedBox(
      height: 20, 
      child: Row(
        children: [
          
          Image.asset(
            'assets/images/easypay.png',
            height: 20,
            width: 40, 
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/mastercard_credit.png',
            height: 20,
            width: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/payfast.png',
            height: 20,
            width: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/visa.png',
            height: 20,
            width: 40,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  void _showPaymentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 40),  
        child: const PaymentPickerBottomSheet(),
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.darkBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Search Flights', textAlign: TextAlign.center, style: AppTextStyles.button)),
          ),
        ),
      ),
    );
  }
}

class PaymentPickerBottomSheet extends StatefulWidget {
  const PaymentPickerBottomSheet({super.key});

  @override
  State<PaymentPickerBottomSheet> createState() => _PaymentPickerBottomSheetState();
}

class _PaymentPickerBottomSheetState extends State<PaymentPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAll = false; // Add this to track show more/less state
  
  final List<PaymentMethod> _allPaymentMethods = [
    PaymentMethod(id: 'mastercard', name: 'MasterCard Credit', icon: Icons.credit_card, isSelected: true),
    PaymentMethod(id: 'visa', name: 'Visa Credit', icon: Icons.credit_card, isSelected: true),
    PaymentMethod(id: 'easypaisa', name: 'Easypaisa', icon: Icons.smartphone, isSelected: true),
    PaymentMethod(id: 'payfast', name: 'PayFast', icon: Icons.payment, isSelected: true),
    PaymentMethod(id: 'amex', name: 'American Express', icon: Icons.credit_card, isSelected: false),
    PaymentMethod(id: 'Bank', name: 'Bank Transfer', icon: Icons.payment, isSelected: false),
    PaymentMethod(id: 'Diners', name: 'Diners Club', icon: Icons.payment, isSelected: false),
    PaymentMethod(id: 'mastercs', name: 'MasterCard Cirrus', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'MasterDebit', name: 'MasterCard Debit', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'paypal', name: 'PayPal', icon: Icons.paypal, isSelected: false),
    PaymentMethod(id: 'VisaBeb', name: 'Visa Debit', icon: Icons.payment, isSelected: false),
    PaymentMethod(id: 'cash', name: 'Cash Payment', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'WesternUnion', name: 'Western Union', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'Bitcoin', name: 'Bitcoin', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'CardInstallments', name: 'Card Installments', icon: Icons.account_balance_wallet, isSelected: false),
  ];

  late List<PaymentMethod> _filteredMethods;
  static const int _initialDisplayCount = 5; // Show 5 items initially (4 + American Express)

  @override
  void initState() {
    super.initState();
    _filteredMethods = _allPaymentMethods;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMethods(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMethods = _allPaymentMethods;
        _showAll = false; // Reset to collapsed when searching
      } else {
        _filteredMethods = _allPaymentMethods
            .where((method) => method.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _togglePaymentMethod(String id) {
    setState(() {
      final method = _allPaymentMethods.firstWhere((m) => m.id == id);
      method.isSelected = !method.isSelected;
    });
  }

  void _toggleShowMore() {
    setState(() {
      _showAll = !_showAll;
    });
  }

  void _applyChanges() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Text(
                      'By selecting one or more (max 10) payment types,\nprices on PHPTRAVELS will include applicable minimum\npayment fees. Please note that not all providers\nsupport all payment types.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                  _buildPaymentMethodsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    final itemsToShow = _showAll ? _filteredMethods.length : _initialDisplayCount.clamp(0, _filteredMethods.length);
    final visibleMethods = _filteredMethods.take(itemsToShow).toList();
    final hasMoreItems = _filteredMethods.length > _initialDisplayCount;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleMethods.length + (hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        // Build show more/less button at the end
        if (index == visibleMethods.length) {
          return _buildShowMoreButton();
        }
        return _buildPaymentMethodItem(visibleMethods[index]);
      },
    );
  }

  Widget _buildShowMoreButton() {
    return GestureDetector(
      onTap: _toggleShowMore,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _showAll ? 'Show less' : 'Show more',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: AppColors.textPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                _showAll ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.check, size: 20, color: AppColors.textPrimary),
              onPressed: _applyChanges,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search payment type',alignLabelWithHint: false,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  contentPadding: EdgeInsets.zero,
                   isDense: true, 
                ),
                onChanged: _filterMethods,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _filterMethods('');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _togglePaymentMethod(method.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: method.isSelected ? AppColors.primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: method.isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: method.isSelected
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  method.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(method.icon, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 0.8, color: AppColors.borderLight);
  }
}

class _SwapButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SwapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.white,
          border: Border.all(
            color: const Color.fromARGB(119, 114, 115, 118),
            width: 1,
          ),
        ),
        child: Icon(
          LucideIcons.arrowUpDown,
          size: 16,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}

class _RemoveSegmentButton extends StatelessWidget {
  final bool canRemove;
  final VoidCallback onRemove;
  const _RemoveSegmentButton({required this.canRemove, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canRemove ? onRemove : null,
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(
            color: canRemove ? Colors.black : AppColors.borderLight, 
            width: 2
          )
        ),
        child: Icon(
          Icons.close, 
          size: 12, 
          color: canRemove ? Colors.black : AppColors.textSecondary
        ),
      ),
    );
  }
}

class _AddFlightButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFlightButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent, 
                    shape: BoxShape.circle, 
                    border: Border.all(color: AppColors.primaryBlue, width: 2)
                  ),
                  child: Icon(LucideIcons.plus, size: 14, color: AppColors.primaryBlue), 
                ),
                const SizedBox(width: 8),
                Text(
                  'Add another flight', 
                  style: TextStyle(
                    color: AppColors.textPrimary, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w600, 
                    decorationThickness: 2.0, 
                    decorationColor: AppColors.textPrimary, 
                    height: 1.5, 
                    fontFamily: 'Inter', 
                    decoration: TextDecoration.underline
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationSearchPage extends StatefulWidget {
  final Function(String) onDestinationSelected;
  const DestinationSearchPage({super.key, required this.onDestinationSelected});

  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Map<String, String>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.length >= 2) {
      final results = await AirportService.fetchCities(query);
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
  }

  void _selectDestination(String destination) {
    widget.onDestinationSelected(destination);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, 
      appBar: _buildAppBar(), 
      body: Column(
        children: [
          _buildSearchBar(), 
          Expanded(child: _buildSearchResults())
        ]
      )
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20), 
        onPressed: () => Navigator.pop(context)
      ),
      title: const Text('Select Destination', style: AppTextStyles.title),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background, 
          borderRadius: BorderRadius.circular(10), 
          border: Border.all(color: AppColors.borderLight, width: 1)
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 24, 
              height: 24, 
              alignment: Alignment.center, 
              child: Icon(Icons.search, size: 20, color: AppColors.textSecondary)
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500, 
                  fontFamily: 'Inter', 
                  color: AppColors.textPrimary
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none, 
                  hintText: 'Search destination...', 
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary, 
                    fontSize: 14, 
                    fontFamily: 'Inter'
                  )
                ),
                onChanged: _performSearch,
              ),
            ),
            if (_searchController.text.isNotEmpty) 
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary), 
                onPressed: _clearSearch
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final airport = _searchResults[index];
        return _buildAirportItem(airport);
      },
    );
  }

  Widget _buildAirportItem(Map<String, String> airport) {
    return Material(
      child: InkWell(
        onTap: () => _selectDestination(airport['name'] ?? ''),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCountryFlag(airport['flag']),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      airport['name']?.split(',')[0] ?? '', 
                      style: const TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w500, 
                        fontFamily: 'Inter', 
                        color: AppColors.textPrimary
                      )
                    ),
                    const SizedBox(height: 2),
                    Text(
                      airport['name']?.split(',').sublist(1).join(',') ?? '', 
                      style: const TextStyle(
                        fontSize: 11, 
                        color: AppColors.textSecondary, 
                        fontFamily: 'Inter', 
                        fontWeight: FontWeight.w400
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                airport['code'] ?? '', 
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w600, 
                  color: AppColors.primaryBlue, 
                  fontFamily: 'Inter'
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryFlag(String? flagUrl) {
    return Container(
      width: 28,
      height: 18,
      alignment: Alignment.center,
      child: flagUrl != null 
          ? Image.network(
              flagUrl, 
              width: 28, 
              height: 18, 
              errorBuilder: (_, __, ___) => _buildFlagPlaceholder()
            ) 
          : _buildFlagPlaceholder(),
    );
  }

  Widget _buildFlagPlaceholder() {
    return const Icon(Icons.flag_outlined, size: 18, color: AppColors.primaryBlue);
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  bool isSelected;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
  });
}

class PaymentMethodChip extends StatelessWidget {
  final String label;
  final String? subLabel;
  const PaymentMethodChip({super.key, required this.label, this.subLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}

class DatePickerConfig {
  static const List<String> weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  static const List<String> shortMonths = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
  
  // For one-way and multi-city, always select departure. For round-trip, use the widget value
  if (widget.tripType == TripType.roundTrip) {
    _selectingDeparture = widget.isDeparture;
  } else {
    _selectingDeparture = true; // Always departure for one-way and multi-city
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
      (month) => month.year == targetDate.year && month.month == targetDate.month,
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
  final cleanSelected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

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

    // Past dates disabled
    if (cleanDay.isBefore(cleanToday)) return false;

    if (_selectingDeparture) {
      return true;
    } else {
      // Return must be AFTER departure (not same day, not before)
      return cleanDay.isAfter(_departureDate);
    }
  }

  bool _isDateInRange(DateTime day) {
    if (_departureDate == null || _returnDate == null) return false;

    final d = DateTime(_departureDate.year, _departureDate.month, _departureDate.day);
    final r = DateTime(_returnDate!.year, _returnDate!.month, _returnDate!.day);
    final current = DateTime(day.year, day.month, day.day);

    // Between departure and return (exclusive of both endpoints)
    return current.isAfter(d) && current.isBefore(r);
  }

  Widget _buildCalendar(DateTime currentMonth) {
    final days = _getDaysInMonth(currentMonth);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          child: Center(
            child: Text(
              '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
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
              final cleanDeparture = DateTime(_departureDate.year, _departureDate.month, _departureDate.day);
              final cleanReturn = _returnDate != null 
                  ? DateTime(_returnDate!.year, _returnDate!.month, _returnDate!.day)
                  : null;

              final isDepartureSelected = _isSameDay(cleanDay, cleanDeparture);
              final isReturnSelected = cleanReturn != null && _isSameDay(cleanDay, cleanReturn);
              final isSelected = isDepartureSelected || isReturnSelected;
              final isInRange = _isDateInRange(cleanDay);

              return GestureDetector(
                onTap: isSelectable ? () => _onDateSelected(day) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : isInRange
                            ? AppColors.lightBlue
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
                                ? AppColors.textSecondary
                                : !isSelectable
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
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

  String _getMonthName(int month) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month];
  }

@override
Widget build(BuildContext context) {
  final bool showBothTabs = widget.tripType == TripType.roundTrip;
  
  return Scaffold(
    backgroundColor: AppColors.white,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        showBothTabs ? 'Select Dates' : 'Select Departure Date',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
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
                          'DEPARTURE DATE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectingDeparture ? AppColors.textPrimary : AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: _selectingDeparture ? AppColors.primaryBlue : Colors.transparent,
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
                          'RETURN DATE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: !_selectingDeparture ? AppColors.textPrimary : AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: !_selectingDeparture ? AppColors.primaryBlue : Colors.transparent,
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
            itemBuilder: (context, index) => _buildCalendar(_months[index]),
          ),
        ),
      ],
    ),
  );
}
}

class PassengerPickerBottomSheet extends StatefulWidget {
  final PassengerCount passengers;
  final String cabinClass;
  final Function(PassengerCount, String) onApply;

  const PassengerPickerBottomSheet({super.key, required this.passengers, required this.cabinClass, required this.onApply});

  @override
  State<PassengerPickerBottomSheet> createState() => _PassengerPickerBottomSheetState();
}

class _PassengerPickerBottomSheetState extends State<PassengerPickerBottomSheet> {
  late PassengerCount _tempPassengers;
  late String _tempCabinClass;
  final List<String> _cabinClasses = ['Economy', 'Premium Economy', 'Business', 'First Class'];

  @override
  void initState() {
    super.initState();
    _tempPassengers = PassengerCount(adults: widget.passengers.adults, children: widget.passengers.children, infants: widget.passengers.infants);
    _tempCabinClass = widget.cabinClass;
  }

  void _applyChanges() {
    widget.onApply(_tempPassengers, _tempCabinClass);
    Navigator.pop(context);
  }

  void _updateAdultCount(int newCount) {
    if (newCount >= 1 && newCount <= 9) {
      setState(() {
        _tempPassengers.adults = newCount;
        if (_tempPassengers.infants > newCount) {
          _tempPassengers.infants = newCount;
        }
      });
    }
  }

  void _updateChildCount(int newCount) {
    if (newCount >= 0 && newCount <= 8) {
      setState(() {
        _tempPassengers.children = newCount;
      });
    }
  }

  void _updateInfantCount(int newCount) {
    if (newCount >= 0 && newCount <= _tempPassengers.adults) {
      setState(() {
        _tempPassengers.infants = newCount;
      });
    }
  }

  int _getTotalPassengers() {
    return _tempPassengers.total;
  }

@override
Widget build(BuildContext context) {
  return SafeArea(
    top: false,
    bottom: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPassengersSection(),
                  const SizedBox(height: 45),
                  _buildCabinClassSection(),
                  const SizedBox(height: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildHeader() {
  return Container(
    height: 60, 
    child: Column(
      children: [
        // Main content row
        Expanded( // Takes available space
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 30, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context), 
                padding: EdgeInsets.zero,
              ),
              const Text(
                'Passengers & Cabin\n Class',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter', 
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, size: 30, color: AppColors.textPrimary),
                onPressed: _applyChanges, 
                padding: EdgeInsets.all(0),
              ),
            ],
          ),
        ),
        // Divider at bottom
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.borderLight,
        ),
      ],
    ),
  );
}

  Widget _buildPassengersSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'PASSENGERS', 
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w600, 
          color: AppColors.textPrimary, 
          fontFamily: 'Inter', 
          letterSpacing: 0.3
        )
      ),
      const SizedBox(height: 25), 
      _buildPassengerCounter('Adult', '(>12 years)', _tempPassengers.adults, _updateAdultCount, icon: LucideIcons.user, minValue: 1),
      const SizedBox(height: 23),
      _buildPassengerCounter('Child', '(2-12 years)', _tempPassengers.children, _updateChildCount, icon: Icons.child_care_outlined),
      const SizedBox(height: 23),
      _buildPassengerCounter('Infant', '(<2 years)', _tempPassengers.infants, _updateInfantCount, icon: LucideIcons.baby, maxValue: _tempPassengers.adults),
    ],
  );
}

  Widget _buildPassengerCounter(String title, String subtitle, int count, Function(int) onCountChanged, {required IconData icon, int minValue = 0, int? maxValue}) {
    final canDecrease = count > minValue;
    final canIncrease = _getTotalPassengers() < 9 && (maxValue == null || count < maxValue);

    return Row(
      children: [
        Padding(padding: const EdgeInsets.only(right: 12), child: Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(icon, size: 25, color: Colors.black))), // Changed to black
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        Row(
          children: [
            _buildCounterButton(Icons.remove, canDecrease, onTap: canDecrease ? () => onCountChanged(count - 1) : null),
            const SizedBox(width: 10),
            SizedBox(width: 20, child: Text(count.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: AppColors.textPrimary))),
            const SizedBox(width: 10),
            _buildCounterButton(Icons.add, canIncrease, onTap: canIncrease ? () => onCountChanged(count + 1) : null),
          ],
        ),
      ],
        );
      }

  Widget _buildCounterButton(IconData icon, bool isEnabled, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all( color: isEnabled ? Colors.black : AppColors.borderLight, width: 2)), // Changed to black
        child: Icon(icon, size: 18, color: isEnabled ? Colors.black : AppColors.borderLight , weight: 2,), // Changed to black
      ),
    );
  }

  Widget _buildCabinClassSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CABIN CLASS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Inter', letterSpacing: 0.3)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 4.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _cabinClasses.map((cabin) => _buildCabinClassOption(cabin)).toList(),
        ),
      ],
    );
  }

  Widget _buildCabinClassOption(String cabin) {
    final isSelected = _tempCabinClass == cabin;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempCabinClass = cabin;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.borderLight : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.textPrimary : AppColors.borderLight, width: 1),
        ),
        child: Center(child: Text(cabin, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? AppColors.textPrimary : AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Inter'))),
      ),
    );
  }
}

extension DateTimeUtils on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension StringUtils on String {
  String get firstPart => split(',').first;
  String get remainingParts => split(',').sublist(1).join(',');

}

class _RoundTripDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isDeparture;
  final Function(DateTime?, DateTime?) onDateSelected;
  final DateTime? initialDepartureDate;
  final DateTime? initialReturnDate;

  const _RoundTripDateField({
    required this.label,
    required this.date,
    required this.isDeparture,
    required this.onDateSelected,
    this.initialDepartureDate,
    this.initialReturnDate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDatePicker(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Increased vertical padding
          child: Row(
            children: [
              if (isDeparture) Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(LucideIcons.calendar, size: 18, color: Colors.black)), // Changed to black
              if (isDeparture) const SizedBox(width: 8),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final displayText = _getDisplayText();
    if (!isDeparture && date == null) {
      return Center(
        child: Text('Return Date', style: const TextStyle(color: AppColors.borderLight, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 3),
          Text(displayText, style: AppTextStyles.bodyMediumBold),
        ],
      );
    }
  }

  String _getDisplayText() {
    if (date != null) {
      return '${_getWeekday(date!.weekday)}, ${date!.day} ${_getMonth(date!.month)}';
    }
    return isDeparture ? 'Today' : 'Return Date';
  }

  void _showDatePicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CustomDatePickerPage(
          isDeparture: isDeparture,
          onDateSelected: onDateSelected,
          initialDepartureDate: initialDepartureDate,
          initialReturnDate: initialReturnDate,
          tripType: TripType.roundTrip,
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  String _getMonth(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}

