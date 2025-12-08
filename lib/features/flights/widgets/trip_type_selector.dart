import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:phptravels/features/flights/models/trip_type.dart';

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
                color: isSelected
                    ? AppColors.lightBlue
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.transparent),
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
