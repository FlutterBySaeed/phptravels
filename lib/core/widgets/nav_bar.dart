import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 1,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, l10n.home, Icons.home, 0),
          _buildNavItem(context, l10n.explore, Icons.explore, 1),
          _buildNavItem(context, l10n.stories, Icons.article, 2),
          _buildNavItem(context, l10n.account, Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String label, IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getOutlinedIcon(icon),
            color: isSelected
                ? AppColors.primaryBlue
                : Theme.of(context).textTheme.bodySmall?.color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? AppColors.primaryBlue
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getOutlinedIcon(IconData icon) {
    if (icon == Icons.home) return Icons.home_outlined;
    if (icon == Icons.explore) return Icons.explore_outlined;
    if (icon == Icons.article) return Icons.article_outlined;
    if (icon == Icons.person) return Icons.person_outlined;
    return icon;
  }
}
