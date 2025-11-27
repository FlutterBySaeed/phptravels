import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/SERVICES/airport_service.dart';
import 'package:phptravels/THEMES/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:phptravels/models/search_history_model.dart';
import 'package:phptravels/services/search_history_service.dart';
import 'package:phptravels/widgets/recent_searches_section.dart';

enum TripType { oneWay, roundTrip, multiCity }

class PassengerCount {
  int adults;
  int children;
  int infants;

  PassengerCount({this.adults = 1, this.children = 0, this.infants = 0});

  PassengerCount copyWith({int? adults, int? children, int? infants}) {
    return PassengerCount(
        adults: adults ?? this.adults,
        children: children ?? this.children,
        infants: infants ?? this.infants);
  }

  int get total => adults + children + infants;
}

class MultiCitySegment {
  String from;
  String to;
  DateTime? date;
  TextEditingController fromController;
  TextEditingController toController;
  bool hasError;

  MultiCitySegment(
      {this.from = '', this.to = '', this.date, this.hasError = false})
      : fromController = TextEditingController(text: from),
        toController = TextEditingController(text: to);

  MultiCitySegment copyWith(
      {String? from, String? to, DateTime? date, bool? hasError}) {
    return MultiCitySegment(
        from: from ?? this.from,
        to: to ?? this.to,
        date: date ?? this.date,
        hasError: hasError ?? this.hasError);
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
  final TextEditingController _oneWayFromController =
      TextEditingController(text: 'Lahore (LHE)');
  final TextEditingController _oneWayToController = TextEditingController();
  final TextEditingController _roundTripFromController =
      TextEditingController(text: 'Lahore (LHE)');
  final TextEditingController _roundTripToController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;
  PassengerCount _passengers = PassengerCount();
  String _cabinClass = 'economy';
  final List<MultiCitySegment> _multiCitySegments = [];
  int _recentSearchesVersion = 0;
  bool _validateFields = false;

  @override
  void initState() {
    super.initState();
    _departureDate = DateTime.now();
    _initializeMultiCitySegments();
  }

  Future<void> _saveSearchToHistory() async {
    final tripTypeString = _tripType.toString().split('.').last;

    final search = FlightSearchHistory(
      id: const Uuid().v4(),
      from: _tripType == TripType.oneWay
          ? _oneWayFromController.text
          : _roundTripFromController.text,
      to: _tripType == TripType.oneWay
          ? _oneWayToController.text
          : _roundTripToController.text,
      departureDate: _departureDate ?? DateTime.now(),
      returnDate: _returnDate,
      passengers: _passengers.total,
      cabinClass: _cabinClass,
      tripType: tripTypeString,
      createdAt: DateTime.now(),
    );

    await SearchHistoryService.saveSearch(search);
  }

  void _initializeMultiCitySegments() {
    _multiCitySegments.clear();
    _multiCitySegments.add(MultiCitySegment(
      from: 'LHE',
      date: DateTime.now(),
    ));
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
      _validateFields = false;
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
        _multiCitySegments[index].hasError = newSegment.hasError;
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
    setState(() {
      _validateFields = false;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    switch (_tripType) {
      case TripType.oneWay:
        if (_oneWayToController.text.isEmpty) {
          isValid = false;
        }
        break;
      case TripType.roundTrip:
        if (_roundTripToController.text.isEmpty || _returnDate == null) {
          isValid = false;
        }
        break;
      case TripType.multiCity:
        for (final segment in _multiCitySegments) {
          if (segment.to.isEmpty || segment.date == null) {
            segment.hasError = true;
            isValid = false;
          } else {
            segment.hasError = false;
          }
        }
        break;
    }

    setState(() {
      _validateFields = !isValid;
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              TripTypeSelector(
                currentType: _tripType,
                onTypeChanged: _updateTripType,
              ),
              const SizedBox(height: 6),
              _buildSearchForm(),
              const SizedBox(height: 30),
              SearchButton(
                onSearchPressed: () async {
                  if (_validateForm()) {
                    await _saveSearchToHistory();
                    setState(() {
                      _recentSearchesVersion++;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              RecentSearchesSection(
                key: ValueKey(_recentSearchesVersion),
                onSearchSelected: (search) {
                  _populateFormFromHistory(search);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _populateFormFromHistory(FlightSearchHistory search) {
    setState(() {
      if (search.tripType == 'oneWay') {
        _tripType = TripType.oneWay;
        _oneWayFromController.text = search.from;
        _oneWayToController.text = search.to;
        _departureDate = search.departureDate;
      } else if (search.tripType == 'roundTrip') {
        _tripType = TripType.roundTrip;
        _roundTripFromController.text = search.from;
        _roundTripToController.text = search.to;
        _departureDate = search.departureDate;
        _returnDate = search.returnDate;
      }

      _passengers = PassengerCount(
        adults: search.passengers,
        children: 0,
        infants: 0,
      );
      _cabinClass = search.cabinClass;
      _validateFields = false;
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: Theme.of(context).iconTheme.color, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(l10n.searchFlights,
          style: Theme.of(context).textTheme.titleLarge),
      titleSpacing: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Theme.of(context).dividerColor,
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
          validateFields: _validateFields,
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
          validateFields: _validateFields,
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
          validateFields: _validateFields,
        );
    }
  }
}

class TripTypeSelector extends StatelessWidget {
  final TripType currentType;
  final ValueChanged<TripType> onTypeChanged;

  const TripTypeSelector(
      {super.key, required this.currentType, required this.onTypeChanged});

  @override
  Widget build(BuildContext context) {
    final types = TripType.values;
    final l10n = AppLocalizations.of(context);
    final labels = [l10n.oneWay, l10n.roundTrip, l10n.multiCity];

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
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Theme.of(context).dividerColor, width: 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  color: isSelected
                      ? AppColors.textPrimary
                      : Theme.of(context).textTheme.bodyMedium?.color,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
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
  final bool validateFields;

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
    required this.validateFields,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final toHasError = validateFields && toController.text.isEmpty;

    return Stack(
      children: [
        _FormContainer(
          children: [
            AirportField(
              label: l10n.from,
              controller: fromController,
              hint: '',
              isFromField: true,
              onFieldUpdated: onFieldsUpdated,
              hasError: false,
            ),
            const _Divider(),
            AirportField(
              label: '',
              controller: toController,
              hint: l10n.to,
              isFromField: false,
              onFieldUpdated: onFieldsUpdated,
              hasError: toHasError,
            ),
            const _Divider(),
            _DateFieldContainer(
              child: SingleDateField(
                date: departureDate,
                isDeparture: true,
                onDateSelected: (date) => onDateSelected(date, null),
                hasError: false,
              ),
            ),
            const _Divider(),
            PassengerClassRow(
                passengers: passengers,
                cabinClass: cabinClass,
                onTap: () => _showPassengerPicker(context)),
            const _Divider(),
            const PaymentSection(),
          ],
        ),
        PositionedDirectional(
          top: 56,
          end: 20,
          child: _SwapButton(onTap: onSwapAirports),
        ),
      ],
    );
  }

  void _showPassengerPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showGeneralDialog(
      context: context,
      barrierLabel: l10n.passengersAndCabin,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _PassengerPickerSideSheet(
          passengers: passengers,
          cabinClass: cabinClass,
          onApply: (newPassengers, newCabinClass) {
            onPassengersChanged(newPassengers);
            onCabinClassChanged(newCabinClass);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offsetAnimation, child: child);
      },
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
  final bool validateFields;

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
    required this.validateFields,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final toHasError = validateFields && toController.text.isEmpty;
    final returnDateHasError = validateFields && returnDate == null;

    return Stack(
      children: [
        _FormContainer(
          children: [
            AirportField(
              label: l10n.from,
              controller: fromController,
              hint: '',
              isFromField: true,
              onFieldUpdated: onFieldsUpdated,
              hasError: false,
            ),
            const _Divider(),
            AirportField(
              label: '',
              controller: toController,
              hint: l10n.to,
              isFromField: false,
              onFieldUpdated: onFieldsUpdated,
              hasError: toHasError,
            ),
            const _Divider(),
            _DateFieldContainer(
              child: DualDateField(
                departureDate: departureDate,
                returnDate: returnDate,
                onDateSelected: onDateSelected,
                validateFields: validateFields,
              ),
            ),
            const _Divider(),
            PassengerClassRow(
                passengers: passengers,
                cabinClass: cabinClass,
                onTap: () => _showPassengerPicker(context)),
            const _Divider(),
            const PaymentSection(),
          ],
        ),
        PositionedDirectional(
          top: 56,
          end: 20,
          child: _SwapButton(onTap: onSwapAirports),
        ),
      ],
    );
  }

  void _showPassengerPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showGeneralDialog(
      context: context,
      barrierLabel: l10n.passengersAndCabin,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _PassengerPickerSideSheet(
          passengers: passengers,
          cabinClass: cabinClass,
          onApply: (newPassengers, newCabinClass) {
            onPassengersChanged(newPassengers);
            onCabinClassChanged(newCabinClass);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offsetAnimation, child: child);
      },
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
  final bool validateFields;

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
    required this.validateFields,
  });

  @override
  State<MultiCityForm> createState() => _MultiCityFormState();
}

class _MultiCityFormState extends State<MultiCityForm> {
  List<MultiCitySegment> get sortedSegments {
    final sorted = List<MultiCitySegment>.from(widget.segments);

    sorted.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;

      return a.date!.compareTo(b.date!);
    });

    return sorted;
  }

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
                  final originalIndex =
                      widget.segments.indexOf(sortedSegmentsList[i]);
                  _onSegmentUpdated(originalIndex, updatedSegment);
                },
                onSegmentRemoved: () {
                  final originalIndex =
                      widget.segments.indexOf(sortedSegmentsList[i]);
                  widget.onSegmentRemoved(originalIndex);
                },
                validateFields: widget.validateFields,
              ),
              if (i < sortedSegmentsList.length - 1) const _Divider(),
            ],
          ],
        ),
        const _Divider(),
        if (widget.segments.length < 4)
          _AddFlightButton(onTap: widget.onSegmentAdded),
        if (widget.segments.length < 4) const _Divider(),
        PassengerClassRow(
            passengers: widget.passengers,
            cabinClass: widget.cabinClass,
            onTap: () => _showPassengerPicker(context)),
        const _Divider(),
        const PaymentSection(),
      ],
    );
  }

  void _showPassengerPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showGeneralDialog(
      context: context,
      barrierLabel: l10n.passengersAndCabin,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _PassengerPickerSideSheet(
          passengers: widget.passengers,
          cabinClass: widget.cabinClass,
          onApply: (newPassengers, newCabinClass) {
            widget.onPassengersChanged(newPassengers);
            widget.onCabinClassChanged(newCabinClass);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

class _DateFieldContainer extends StatelessWidget {
  final Widget child;

  const _DateFieldContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: child,
    );
  }
}

class SingleDateField extends StatelessWidget {
  final DateTime? date;
  final bool isDeparture;
  final Function(DateTime?) onDateSelected;
  final bool hasError;

  const SingleDateField({
    super.key,
    required this.date,
    required this.isDeparture,
    required this.onDateSelected,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final dateDisplay = date != null
        ? DateFormat('EEE, d MMM', localeName).format(date!)
        : l10n.today;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDatePicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.calendar,
                  size: 18,
                  color:
                      hasError ? Colors.red : Theme.of(context).iconTheme.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.departureDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: hasError ? Colors.red : null,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateDisplay,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasError ? Colors.red : null,
                          ),
                      overflow: TextOverflow.ellipsis,
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

  void _showDatePicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CustomDatePickerPage(
          isDeparture: true,
          onDateSelected: (departureDate, returnDate) =>
              onDateSelected(departureDate),
          initialDepartureDate: date,
          tripType: TripType.oneWay,
        ),
      ),
    );
  }
}

class DualDateField extends StatelessWidget {
  final DateTime? departureDate;
  final DateTime? returnDate;
  final Function(DateTime?, DateTime?) onDateSelected;
  final bool validateFields;

  const DualDateField({
    super.key,
    required this.departureDate,
    required this.returnDate,
    required this.onDateSelected,
    required this.validateFields,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final returnDateHasError = validateFields && returnDate == null;

    return Container(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 60,
            child: _DateFieldItem(
              label: l10n.departureDate,
              date: departureDate,
              isDeparture: true,
              onTap: () => _showDatePicker(context, isDeparture: true),
              showIcon: true,
              hasError: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
          Expanded(
            flex: 40,
            child: _DateFieldItem(
              label: l10n.returnDate,
              date: returnDate,
              isDeparture: false,
              onTap: () => _showDatePicker(context, isDeparture: false),
              showIcon: false,
              dynamicLabel: true,
              hasError: returnDateHasError,
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context, {required bool isDeparture}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CustomDatePickerPage(
          isDeparture: isDeparture,
          onDateSelected: onDateSelected,
          initialDepartureDate: departureDate,
          initialReturnDate: returnDate,
          tripType: TripType.roundTrip,
        ),
      ),
    );
  }
}

class _DateFieldItem extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isDeparture;
  final VoidCallback onTap;
  final bool showIcon;
  final bool dynamicLabel;
  final bool hasError;

  const _DateFieldItem({
    required this.label,
    required this.date,
    required this.isDeparture,
    required this.onTap,
    this.showIcon = false,
    this.dynamicLabel = false,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowLabel = dynamicLabel ? date != null : true;
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final displayText = date != null
        ? DateFormat('EEE, d MMM', localeName).format(date!)
        : (isDeparture ? l10n.today : l10n.returnDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showIcon) ...[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.calendar,
                    size: 18,
                    color: hasError
                        ? Colors.red
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (shouldShowLabel)
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: hasError ? Colors.red : null,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (shouldShowLabel) const SizedBox(height: 2),
                    Text(
                      displayText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: hasError
                                ? Colors.red
                                : ((date == null && !isDeparture)
                                    ? Theme.of(context).hintColor
                                    : null),
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class AirportField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool isFromField;
  final VoidCallback onFieldUpdated;
  final bool hasError;

  const AirportField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    required this.isFromField,
    required this.onFieldUpdated,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDestinationSearch(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: isFromField
                    ? Icon(LucideIcons.planeTakeoff,
                        size: 18,
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).iconTheme.color)
                    : Icon(LucideIcons.planeLanding,
                        size: 18,
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).iconTheme.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 45,
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (label.isNotEmpty)
                        Text(label,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: hasError ? Colors.red : null,
                                    )),
                      if (label.isNotEmpty) const SizedBox(height: 3),
                      Text(
                        controller.text.isEmpty
                            ? (hint ?? '')
                            : controller.text,
                        style: TextStyle(
                          color: hasError
                              ? Colors.red
                              : (controller.text.isEmpty
                                  ? Theme.of(context).hintColor
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                          fontSize: 13,
                          fontWeight: controller.text.isEmpty
                              ? FontWeight.w700
                              : FontWeight.w600,
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

class MultiCitySegmentRow extends StatefulWidget {
  final MultiCitySegment segment;
  final int index;
  final bool canRemove;
  final ValueChanged<MultiCitySegment> onSegmentUpdated;
  final VoidCallback onSegmentRemoved;
  final bool validateFields;

  const MultiCitySegmentRow({
    super.key,
    required this.segment,
    required this.index,
    required this.canRemove,
    required this.onSegmentUpdated,
    required this.onSegmentRemoved,
    required this.validateFields,
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
    final l10n = AppLocalizations.of(context);
    final toHasError = widget.validateFields && widget.segment.to.isEmpty;
    final dateHasError = widget.validateFields && widget.segment.date == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 42,
            child: Center(
              child: _RemoveSegmentButton(
                  canRemove: widget.canRemove,
                  onRemove: widget.onSegmentRemoved),
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: _CompactAirportField(
              label: l10n.from,
              controller: widget.segment.fromController,
              onDestinationSelected: (destination) {
                widget.segment.from = destination;
                widget.onSegmentUpdated(widget.segment);
              },
              onFieldUpdated: _onFieldUpdated,
              hasError: false,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: _CompactAirportField(
              label: l10n.to,
              controller: widget.segment.toController,
              onDestinationSelected: (destination) {
                widget.segment.to = destination;
                widget.onSegmentUpdated(widget.segment);
              },
              onFieldUpdated: _onFieldUpdated,
              hasError: toHasError,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(width: 8),
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
              hasError: dateHasError,
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
  final bool hasError;

  const _CompactAirportField({
    required this.label,
    required this.controller,
    required this.onDestinationSelected,
    required this.onFieldUpdated,
    required this.hasError,
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
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError ? Colors.red : null,
                      )),
              const SizedBox(height: 4),
              Container(
                height: 28,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  display,
                  style: TextStyle(
                    color: hasError
                        ? Colors.red
                        : (controller.text.isNotEmpty
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Theme.of(context).textTheme.bodySmall?.color),
                    fontSize: 12,
                    fontWeight: controller.text.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.w500,
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
  final bool hasError;

  const _CompactDateField(
      {required this.date,
      required this.onDateSelected,
      required this.hasError});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final dateDisplay =
        date != null ? DateFormat('d, MMM', localeName).format(date!) : '...';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDatePicker(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasError ? Colors.red : null,
                  )),
              const SizedBox(height: 4),
              Container(
                height: 28,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  dateDisplay,
                  style: TextStyle(
                    color: hasError
                        ? Colors.red
                        : (date != null
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Theme.of(context).textTheme.bodySmall?.color),
                    fontSize: 12,
                    fontWeight:
                        date != null ? FontWeight.w600 : FontWeight.w500,
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
          onDateSelected: (departureDate, returnDate) =>
              onDateSelected(departureDate),
          initialDepartureDate: date,
          tripType: TripType.multiCity,
        ),
      ),
    );
  }
}

class PassengerClassRow extends StatelessWidget {
  final PassengerCount passengers;
  final String cabinClass;
  final VoidCallback onTap;

  const PassengerClassRow(
      {super.key,
      required this.passengers,
      required this.cabinClass,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final passengerText = _buildPassengerText(AppLocalizations.of(context));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            children: [
              Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(LucideIcons.users,
                      size: 18, color: Theme.of(context).iconTheme.color)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 47,
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 3),
                      Text(
                        '$passengerText · ${_localizeCabinClass(AppLocalizations.of(context), cabinClass)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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

  String _buildPassengerText(AppLocalizations l10n) {
    final parts = <String>[];
    parts.add(
        '${passengers.adults} ${passengers.adults == 1 ? l10n.adult : l10n.adults}');
    if (passengers.children > 0) {
      parts.add(
          '${passengers.children} ${passengers.children == 1 ? l10n.child : l10n.children}');
    }
    if (passengers.infants > 0) {
      parts.add(
          '${passengers.infants} ${passengers.infants == 1 ? l10n.infant : l10n.infants}');
    }
    return parts.join(', ');
  }
}

String _localizeCabinClass(AppLocalizations l10n, String code) {
  switch (code) {
    case 'premiumEconomy':
      return l10n.premiumEconomy;
    case 'business':
      return l10n.business;
    case 'firstClass':
      return l10n.firstClass;
    case 'economy':
    default:
      return l10n.economy;
  }
}

class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  child: Icon(LucideIcons.creditCard,
                      size: 20, color: Theme.of(context).iconTheme.color)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 46,
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.paymentTypes,
                          style: Theme.of(context).textTheme.bodySmall),
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: const PaymentPickerBottomSheet(),
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  final VoidCallback? onSearchPressed;

  const SearchButton({
    super.key,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSearchPressed,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                l10n.searchFlights,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentPickerBottomSheet extends StatefulWidget {
  const PaymentPickerBottomSheet({super.key});

  @override
  State<PaymentPickerBottomSheet> createState() =>
      _PaymentPickerBottomSheetState();
}

class _PaymentPickerBottomSheetState extends State<PaymentPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAll = false;

  final List<PaymentMethod> _allPaymentMethods = [
    PaymentMethod(
        id: 'mastercard',
        name: 'MasterCard Credit',
        icon: Icons.credit_card,
        isSelected: true),
    PaymentMethod(
        id: 'visa',
        name: 'Visa Credit',
        icon: Icons.credit_card,
        isSelected: true),
    PaymentMethod(
        id: 'easypaisa',
        name: 'Easypaisa',
        icon: Icons.smartphone,
        isSelected: true),
    PaymentMethod(
        id: 'payfast', name: 'PayFast', icon: Icons.payment, isSelected: true),
    PaymentMethod(
        id: 'amex',
        name: 'American Express',
        icon: Icons.credit_card,
        isSelected: false),
    PaymentMethod(
        id: 'Bank',
        name: 'Bank Transfer',
        icon: Icons.payment,
        isSelected: false),
    PaymentMethod(
        id: 'Diners',
        name: 'Diners Club',
        icon: Icons.payment,
        isSelected: false),
    PaymentMethod(
        id: 'mastercs',
        name: 'MasterCard Cirrus',
        icon: Icons.account_balance_wallet,
        isSelected: false),
    PaymentMethod(
        id: 'MasterDebit',
        name: 'MasterCard Debit',
        icon: Icons.account_balance_wallet,
        isSelected: false),
    PaymentMethod(
        id: 'paypal', name: 'PayPal', icon: Icons.paypal, isSelected: false),
    PaymentMethod(
        id: 'VisaBeb',
        name: 'Visa Debit',
        icon: Icons.payment,
        isSelected: false),
    PaymentMethod(
        id: 'cash',
        name: 'Cash Payment',
        icon: Icons.account_balance_wallet,
        isSelected: false),
    PaymentMethod(
        id: 'WesternUnion',
        name: 'Western Union',
        icon: Icons.account_balance_wallet,
        isSelected: false),
    PaymentMethod(
        id: 'Bitcoin',
        name: 'Bitcoin',
        icon: Icons.account_balance_wallet,
        isSelected: false),
    PaymentMethod(
        id: 'CardInstallments',
        name: 'Card Installments',
        icon: Icons.account_balance_wallet,
        isSelected: false),
  ];

  late List<PaymentMethod> _filteredMethods;
  static const int _initialDisplayCount = 5;

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
        _showAll = false;
      } else {
        _filteredMethods = _allPaymentMethods
            .where((method) =>
                method.name.toLowerCase().contains(query.toLowerCase()))
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
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context, l10n),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Text(
                      l10n.paymentMethodsInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ),
                  _buildPaymentMethodsList(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList(BuildContext context, AppLocalizations l10n) {
    final itemsToShow = _showAll
        ? _filteredMethods.length
        : _initialDisplayCount.clamp(0, _filteredMethods.length);
    final visibleMethods = _filteredMethods.take(itemsToShow).toList();
    final hasMoreItems = _filteredMethods.length > _initialDisplayCount;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleMethods.length + (hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == visibleMethods.length) {
          return _buildShowMoreButton(context, l10n);
        }
        return _buildPaymentMethodItem(context, visibleMethods[index]);
      },
    );
  }

  Widget _buildShowMoreButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _toggleShowMore,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _showAll ? l10n.showLess : l10n.showMore,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
              ),
              const SizedBox(width: 6),
              Icon(
                _showAll ? Icons.expand_less : Icons.expand_more,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Text(
            l10n.paymentMethods,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.check,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              onPressed: _applyChanges,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, size: 18, color: Theme.of(context).hintColor),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.top,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.searchPaymentType,
                  alignLabelWithHint: false,
                  hintStyle: Theme.of(context).textTheme.bodySmall,
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
                  child: Icon(Icons.close,
                      size: 16, color: Theme.of(context).hintColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(BuildContext context, PaymentMethod method) {
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
                  color: method.isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  border: Border.all(
                    color: method.isSelected
                        ? AppColors.primaryBlue
                        : Theme.of(context).dividerColor,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(method.icon,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
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
    return Divider(
        height: 1, thickness: 0.8, color: Theme.of(context).dividerColor);
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
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Icon(
          LucideIcons.arrowUpDown,
          size: 16,
          color: Theme.of(context).iconTheme.color,
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
                color: canRemove
                    ? Theme.of(context).iconTheme.color!
                    : Theme.of(context).dividerColor,
                width: 2)),
        child: Icon(Icons.close,
            size: 12,
            color: canRemove
                ? Theme.of(context).iconTheme.color
                : Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }
}

class _AddFlightButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFlightButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                      border:
                          Border.all(color: AppColors.primaryBlue, width: 2)),
                  child: Icon(LucideIcons.plus,
                      size: 14, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 8),
                Text(l10n.addAnotherFlight,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decorationThickness: 2.0,
                        decorationColor:
                            Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                        fontFamily: 'Inter',
                        decoration: TextDecoration.underline)),
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
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

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
      setState(() {
        _isLoading = true;
      });

      final results = await AirportService.fetchAirports(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchResults = [];
        _isLoading = false;
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
      title: Text(
        l10n.searchFlights,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      titleSpacing: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Theme.of(context).dividerColor,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: Icon(
                Icons.search,
                size: 20,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.searchDestination,
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                ),
                onChanged: _performSearch,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: Theme.of(context).hintColor,
                ),
                onPressed: _clearSearch,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.length >= 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No airports found',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Type at least 2 characters to search',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final airport = _searchResults[index];
        return _buildAirportItem(context, airport);
      },
    );
  }

  Widget _buildAirportItem(BuildContext context, Map<String, dynamic> airport) {
    // Determine if this is a city or airport based on fullName
    final bool isAirport = airport['fullName'] != null &&
        airport['fullName'].toString().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            _selectDestination('${airport['city']} (${airport['code']})'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon - location pin for city, airplane for airport
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  isAirport ? Icons.flight : Icons.location_on_outlined,
                  size: 24,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              // Airport/City name and country
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAirport
                          ? (airport['fullName'] ?? airport['city'] ?? '')
                          : (airport['city'] ?? ''),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      airport['country'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Airport code
              Text(
                airport['code'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryFlag(String? flagUrl) {
    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: flagUrl != null && flagUrl.isNotEmpty
            ? Image.network(
                flagUrl,
                width: 32,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFlagPlaceholder(),
              )
            : _buildFlagPlaceholder(),
      ),
    );
  }

  Widget _buildFlagPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Icon(
        Icons.flag_outlined,
        size: 16,
        color: Colors.grey,
      ),
    );
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.8),
      ),
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

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
    final DateTime? departure = _departureDate;

    if (cleanDay.isBefore(cleanToday)) return false;
    if (_selectingDeparture) return true;
    if (departure == null) return false;

    return cleanDay
        .isAfter(DateTime(departure.year, departure.month, departure.day));
  }

  bool _isDateInRange(DateTime day) {
    final DateTime? departure = _departureDate;
    final DateTime? returnDate = _returnDate;
    if (departure == null || returnDate == null) return false;

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

class PassengerPickerBottomSheet extends StatefulWidget {
  final PassengerCount passengers;
  final String cabinClass;
  final Function(PassengerCount, String) onApply;

  const PassengerPickerBottomSheet(
      {super.key,
      required this.passengers,
      required this.cabinClass,
      required this.onApply});

  @override
  State<PassengerPickerBottomSheet> createState() =>
      _PassengerPickerBottomSheetState();
}

class _PassengerPickerBottomSheetState
    extends State<PassengerPickerBottomSheet> {
  late PassengerCount _tempPassengers;
  late String _tempCabinClass;
  final List<String> _cabinClasses = [
    'economy',
    'premiumEconomy',
    'business',
    'firstClass'
  ];

  @override
  void initState() {
    super.initState();
    _tempPassengers = PassengerCount(
        adults: widget.passengers.adults,
        children: widget.passengers.children,
        infants: widget.passengers.infants);
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
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: true,
      bottom: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPassengersSection(context, l10n),
                    const SizedBox(height: 45),
                    _buildCabinClassSection(context, l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close,
                      size: 25, color: Theme.of(context).iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  l10n.passengersAndCabin,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.check,
                      size: 25, color: Theme.of(context).iconTheme.color),
                  onPressed: _applyChanges,
                  padding: EdgeInsets.all(0),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.passengers.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 25),
        _buildPassengerCounter(context, l10n.adult, l10n.adultAgeHint,
            _tempPassengers.adults, _updateAdultCount,
            icon: LucideIcons.user, minValue: 1),
        const SizedBox(height: 23),
        _buildPassengerCounter(context, l10n.child, l10n.childAgeHint,
            _tempPassengers.children, _updateChildCount,
            icon: Icons.child_care_outlined),
        const SizedBox(height: 23),
        _buildPassengerCounter(context, l10n.infant, l10n.infantAgeHint,
            _tempPassengers.infants, _updateInfantCount,
            icon: LucideIcons.baby, maxValue: _tempPassengers.adults),
      ],
    );
  }

  Widget _buildPassengerCounter(BuildContext context, String title,
      String subtitle, int count, Function(int) onCountChanged,
      {required IconData icon, int minValue = 0, int? maxValue}) {
    final canDecrease = count > minValue;
    final canIncrease =
        _getTotalPassengers() < 9 && (maxValue == null || count < maxValue);

    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Icon(icon,
                    size: 25, color: Theme.of(context).iconTheme.color))),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      )),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Row(
          children: [
            _buildCounterButton(context, Icons.remove, canDecrease,
                onTap: canDecrease ? () => onCountChanged(count - 1) : null),
            const SizedBox(width: 10),
            SizedBox(
                width: 20,
                child: Text(count.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ))),
            const SizedBox(width: 10),
            _buildCounterButton(context, Icons.add, canIncrease,
                onTap: canIncrease ? () => onCountChanged(count + 1) : null),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(
      BuildContext context, IconData icon, bool isEnabled,
      {VoidCallback? onTap}) {
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
                width: 2)),
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

  Widget _buildCabinClassSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cabinClass.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 4.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _cabinClasses
              .map((cabin) => _buildCabinClassOption(context, l10n, cabin))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCabinClassOption(
      BuildContext context, AppLocalizations l10n, String cabin) {
    final isSelected = _tempCabinClass == cabin;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempCabinClass = cabin;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).dividerColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? AppColors.borderLight
                  : Theme.of(context).dividerColor,
              width: 1),
        ),
        child: Center(
            child: Text(_localizeCabinClass(l10n, cabin),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 11,
                    ))),
      ),
    );
  }
}

class _PassengerPickerSideSheet extends StatelessWidget {
  final PassengerCount passengers;
  final String cabinClass;
  final Function(PassengerCount, String) onApply;

  const _PassengerPickerSideSheet({
    required this.passengers,
    required this.cabinClass,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final widthFactor = MediaQuery.of(context).size.width > 560 ? 0.55 : 0.92;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              child: PassengerPickerBottomSheet(
                passengers: passengers,
                cabinClass: cabinClass,
                onApply: onApply,
              ),
            ),
          ),
        ],
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
