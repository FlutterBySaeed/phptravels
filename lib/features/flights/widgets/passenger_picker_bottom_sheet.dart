import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:phptravels/features/flights/models/passenger_count.dart';

String _localizeCabinClass(AppLocalizations l10n, String code) {
  switch (code) {
    case 'economy':
      return l10n.economy;
    case 'premiumEconomy':
      return l10n.premiumEconomy;
    case 'business':
      return l10n.business;
    case 'firstClass':
      return l10n.firstClass;
    default:
      return code;
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
          color: Theme.of(context).cardColor,
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
