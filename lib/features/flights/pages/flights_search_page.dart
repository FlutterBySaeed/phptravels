import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/core/services/airport_service.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:phptravels/core/services/search_history_model.dart';
import 'package:phptravels/core/services/search_history_service.dart';
import 'package:phptravels/core/widgets/recent_searches_section.dart';
import 'package:phptravels/features/flights/pages/flights_results_page.dart';
import 'package:phptravels/features/flights/pages/multi_city_results_page.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/search_provider.dart';
import 'package:phptravels/features/flights/models/trip_type.dart';
import 'package:phptravels/features/flights/models/passenger_count.dart';
import 'package:phptravels/features/flights/models/multi_city_segment.dart';
import 'package:phptravels/features/flights/widgets/trip_type_selector.dart';
import 'package:phptravels/features/flights/widgets/custom_date_picker.dart';
import 'package:phptravels/features/flights/widgets/destination_search_page.dart';
import 'package:phptravels/features/flights/widgets/passenger_picker_bottom_sheet.dart';
import 'package:phptravels/features/account/pages/payment_methods_page.dart';

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

    // Initialize with provider values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SearchProvider>(context, listen: false);
      if (searchProvider.destination.isNotEmpty) {
        _oneWayToController.text = searchProvider.destination;
        _roundTripToController.text = searchProvider.destination;
        if (_multiCitySegments.isNotEmpty) {
          _multiCitySegments[0].toController.text = searchProvider.destination;
          _multiCitySegments[0].to = searchProvider.destination;
        }
      }
    });

    // Add listeners to sync changes to provider
    _oneWayToController.addListener(() {
      if (_tripType == TripType.oneWay) {
        _updateProviderDestination(_oneWayToController.text);
      }
    });

    _roundTripToController.addListener(() {
      if (_tripType == TripType.roundTrip) {
        _updateProviderDestination(_roundTripToController.text);
      }
    });

    // Note: Multi-city listener is trickier as segments are dynamic,
    // but we can handle it in _updateMultiCitySegment
  }

  void _updateProviderDestination(String destination) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (searchProvider.destination != destination) {
      searchProvider.setDestination(destination);
      // Sync other controllers
      if (_oneWayToController.text != destination) {
        _oneWayToController.text = destination;
      }
      if (_roundTripToController.text != destination) {
        _roundTripToController.text = destination;
      }

      // Sync first multi-city segment if it exists
      if (_multiCitySegments.isNotEmpty) {
        if (_multiCitySegments[0].toController.text != destination) {
          _multiCitySegments[0].toController.text = destination;
          _multiCitySegments[0].to = destination;
        }
      }
    }
  }

  Future<void> _saveSearchToHistory() async {
    final tripTypeString = _tripType.toString().split('.').last;

    List<Map<String, dynamic>>? segments;
    if (_tripType == TripType.multiCity) {
      segments = _multiCitySegments
          .map((s) => {
                'from': s.from,
                'to': s.to,
                'date': s.date?.toIso8601String(),
              })
          .toList();
    }

    final search = FlightSearchHistory(
      id: const Uuid().v4(),
      from: _tripType == TripType.oneWay
          ? _oneWayFromController.text
          : (_tripType == TripType.roundTrip
              ? _roundTripFromController.text
              : _multiCitySegments.first.from),
      to: _tripType == TripType.oneWay
          ? _oneWayToController.text
          : (_tripType == TripType.roundTrip
              ? _roundTripToController.text
              : _multiCitySegments.last.to),
      departureDate: _departureDate ?? DateTime.now(),
      returnDate: _returnDate,
      passengers: _passengers.total,
      cabinClass: _cabinClass,
      tripType: tripTypeString,
      createdAt: DateTime.now(),
      segments: segments,
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

  void _navigateToResults(BuildContext context) {
    // For multi-city, navigate to dedicated multi-city results page
    if (_tripType == TripType.multiCity) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiCityResultsPage(
            segments: _multiCitySegments,
            passengers: _passengers.total,
          ),
        ),
      );
      return;
    }

    // For one-way and round-trip, use existing results page
    String from = '';
    String to = '';
    DateTime departureDate = _departureDate ?? DateTime.now();

    switch (_tripType) {
      case TripType.oneWay:
        from = _oneWayFromController.text;
        to = _oneWayToController.text;
        break;
      case TripType.roundTrip:
        from = _roundTripFromController.text;
        to = _roundTripToController.text;
        break;
      case TripType.multiCity:
        // Already handled above
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightsResultsPage(
          from: from,
          to: to,
          departureDate: departureDate,
          passengers: _passengers.total,
        ),
      ),
    );
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

        // Sync with provider if it's the first segment
        if (index == 0 && _tripType == TripType.multiCity) {
          _updateProviderDestination(newSegment.to);
        }
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
          if (segment.from.isEmpty ||
              segment.to.isEmpty ||
              segment.date == null) {
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
                    _navigateToResults(context);
                  }
                },
              ),
              const SizedBox(height: 20),
              RecentSearchesSection(
                key: ValueKey(_recentSearchesVersion),
                onSearchSelected: (search) {
                  _populateFormFromHistory(search);
                  // Automatically navigate to results page
                  Future.microtask(() => _navigateToResults(context));
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
      } else if (search.tripType == 'multiCity' && search.segments != null) {
        _tripType = TripType.multiCity;
        _multiCitySegments.clear();
        for (var s in search.segments!) {
          _multiCitySegments.add(MultiCitySegment(
            from: s['from'],
            to: s['to'],
            date: DateTime.parse(s['date']),
          ));
        }
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

    return SizedBox(
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
    showModalBottomSheet(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DestinationSearchPage(
            onDestinationSelected: (destination, city, country) {
              this.controller.text = destination;
              onFieldUpdated();
              Navigator.pop(context);
            },
          ),
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
    final fromHasError = widget.validateFields && widget.segment.from.isEmpty;
    final dateHasError = widget.validateFields && widget.segment.date == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
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
              hasError: fromHasError,
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
    String display = controller.text.isNotEmpty ? controller.text : '...';

    // Extract code if present (e.g. "Dubai (DXB)" -> "DXB")
    if (controller.text.isNotEmpty) {
      final RegExp regExp = RegExp(r'\(([^)]+)\)$');
      final match = regExp.firstMatch(controller.text);
      if (match != null) {
        display = match.group(1) ?? display;
      }
    }

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
    showModalBottomSheet(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DestinationSearchPage(
            onDestinationSelected: (destination, city, country) {
              onDestinationSelected(destination);
              onFieldUpdated();
              Navigator.pop(context);
            },
          ),
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

// class PaymentPickerBottomSheet extends StatefulWidget {
//   const PaymentPickerBottomSheet({super.key});

//   @override
//   State<PaymentPickerBottomSheet> createState() =>
//       _PaymentPickerBottomSheetState();
// }

// class _PaymentPickerBottomSheetState extends State<PaymentPickerBottomSheet> {
//   final TextEditingController _searchController = TextEditingController();
//   bool _showAll = false;

//   final List<PaymentMethod> _allPaymentMethods = [
//     PaymentMethod(
//         id: 'mastercard',
//         name: 'MasterCard Credit',
//         icon: Icons.credit_card,
//         isSelected: true),
//     PaymentMethod(
//         id: 'visa',
//         name: 'Visa Credit',
//         icon: Icons.credit_card,
//         isSelected: true),
//     PaymentMethod(
//         id: 'easypaisa',
//         name: 'Easypaisa',
//         icon: Icons.smartphone,
//         isSelected: true),
//     PaymentMethod(
//         id: 'payfast', name: 'PayFast', icon: Icons.payment, isSelected: true),
//     PaymentMethod(
//         id: 'amex',
//         name: 'American Express',
//         icon: Icons.credit_card,
//         isSelected: false),
//     PaymentMethod(
//         id: 'Bank',
//         name: 'Bank Transfer',
//         icon: Icons.payment,
//         isSelected: false),
//     PaymentMethod(
//         id: 'Diners',
//         name: 'Diners Club',
//         icon: Icons.payment,
//         isSelected: false),
//     PaymentMethod(
//         id: 'mastercs',
//         name: 'MasterCard Cirrus',
//         icon: Icons.account_balance_wallet,
//         isSelected: false),
//     PaymentMethod(
//         id: 'MasterDebit',
//         name: 'MasterCard Debit',
//         icon: Icons.account_balance_wallet,
//         isSelected: false),
//     PaymentMethod(
//         id: 'paypal', name: 'PayPal', icon: Icons.paypal, isSelected: false),
//     PaymentMethod(
//         id: 'VisaBeb',
//         name: 'Visa Debit',
//         icon: Icons.payment,
//         isSelected: false),
//     PaymentMethod(
//         id: 'cash',
//         name: 'Cash Payment',
//         icon: Icons.account_balance_wallet,
//         isSelected: false),
//     PaymentMethod(
//         id: 'WesternUnion',
//         name: 'Western Union',
//         icon: Icons.account_balance_wallet,
//         isSelected: false),
//     PaymentMethod(
//         id: 'Bitcoin',
//         name: 'Bitcoin',
//         icon: Icons.account_balance_wallet,
//         isSelected: false),
//     PaymentMethod(
//         id: 'CardInstallments',
//         name: 'Card Installments',
//         icon: Icons.account_balance_wallet,
//         isSelected: false),
//   ];

//   late List<PaymentMethod> _filteredMethods;
//   static const int _initialDisplayCount = 5;

//   @override
//   void initState() {
//     super.initState();
//     _filteredMethods = _allPaymentMethods;
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _filterMethods(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredMethods = _allPaymentMethods;
//         _showAll = false;
//       } else {
//         _filteredMethods = _allPaymentMethods
//             .where((method) =>
//                 method.name.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   void _togglePaymentMethod(String id) {
//     setState(() {
//       final method = _allPaymentMethods.firstWhere((m) => m.id == id);
//       method.isSelected = !method.isSelected;
//     });
//   }

//   void _toggleShowMore() {
//     setState(() {
//       _showAll = !_showAll;
//     });
//   }

//   void _applyChanges() {
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context);
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildHeader(context, l10n),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).padding.bottom),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSearchBar(context, l10n),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//                     child: Text(
//                       l10n.paymentMethodsInfo,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             height: 1.4,
//                           ),
//                     ),
//                   ),
//                   _buildPaymentMethodsList(context, l10n),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentMethodsList(BuildContext context, AppLocalizations l10n) {
//     final itemsToShow = _showAll
//         ? _filteredMethods.length
//         : _initialDisplayCount.clamp(0, _filteredMethods.length);
//     final visibleMethods = _filteredMethods.take(itemsToShow).toList();
//     final hasMoreItems = _filteredMethods.length > _initialDisplayCount;

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: visibleMethods.length + (hasMoreItems ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index == visibleMethods.length) {
//           return _buildShowMoreButton(context, l10n);
//         }
//         return _buildPaymentMethodItem(context, visibleMethods[index]);
//       },
//     );
//   }

//   Widget _buildShowMoreButton(BuildContext context, AppLocalizations l10n) {
//     return GestureDetector(
//       onTap: _toggleShowMore,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Center(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _showAll ? l10n.showLess : l10n.showMore,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       decoration: TextDecoration.underline,
//                     ),
//               ),
//               const SizedBox(width: 6),
//               Icon(
//                 _showAll ? Icons.expand_less : Icons.expand_more,
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//                 size: 20,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
//       decoration: BoxDecoration(
//         border: Border(
//             bottom:
//                 BorderSide(color: Theme.of(context).dividerColor, width: 1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(
//             width: 40,
//             child: IconButton(
//               icon: Icon(Icons.arrow_back,
//                   size: 20,
//                   color: Theme.of(context).textTheme.bodyMedium?.color),
//               onPressed: () => Navigator.pop(context),
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//             ),
//           ),
//           Text(
//             l10n.paymentMethods,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.w700,
//                 ),
//           ),
//           SizedBox(
//             width: 40,
//             child: IconButton(
//               icon: Icon(Icons.check,
//                   size: 20,
//                   color: Theme.of(context).textTheme.bodyMedium?.color),
//               onPressed: _applyChanges,
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Container(
//         height: 45,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Theme.of(context).dividerColor, width: 1),
//         ),
//         child: Row(
//           children: [
//             const SizedBox(width: 12),
//             Icon(Icons.search, size: 18, color: Theme.of(context).hintColor),
//             const SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _searchController,
//                 textAlignVertical: TextAlignVertical.top,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w500,
//                     ),
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   enabledBorder: InputBorder.none,
//                   focusedBorder: InputBorder.none,
//                   hintText: l10n.searchPaymentType,
//                   alignLabelWithHint: false,
//                   hintStyle: Theme.of(context).textTheme.bodySmall,
//                   contentPadding: EdgeInsets.zero,
//                   isDense: true,
//                 ),
//                 onChanged: _filterMethods,
//               ),
//             ),
//             if (_searchController.text.isNotEmpty)
//               GestureDetector(
//                 onTap: () {
//                   _searchController.clear();
//                   _filterMethods('');
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: Icon(Icons.close,
//                       size: 16, color: Theme.of(context).hintColor),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentMethodItem(BuildContext context, PaymentMethod method) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _togglePaymentMethod(method.id),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           child: Row(
//             children: [
//               Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: method.isSelected
//                       ? AppColors.primaryBlue
//                       : Colors.transparent,
//                   border: Border.all(
//                     color: method.isSelected
//                         ? AppColors.primaryBlue
//                         : Theme.of(context).dividerColor,
//                     width: 1.5,
//                   ),
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//                 child: method.isSelected
//                     ? const Icon(Icons.check, size: 16, color: AppColors.white)
//                     : null,
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Text(
//                   method.name,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.w500,
//                       ),
//                 ),
//               ),
//               Icon(method.icon,
//                   size: 20,
//                   color: Theme.of(context).textTheme.bodyMedium?.color),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1, thickness: 0.8, color: Theme.of(context).dividerColor);
  }
}

class _SwapButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SwapButton({required this.onTap});

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
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
        child: RotationTransition(
          turns: _animation,
          child: Icon(
            LucideIcons.arrowUpDown,
            size: 16,
            color: Theme.of(context).iconTheme.color,
          ),
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
