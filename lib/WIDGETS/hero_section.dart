import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/PAGES/flights.dart';
import 'package:phptravels/PAGES/hotels.dart';
import 'package:phptravels/THEMES/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroBackgroundImage(),
        Transform.translate(
          offset: const Offset(0, -50),
          child: _HeroCardSection(
            selectedIndex: _selectedIndex,
            onCardTap: _handleCardTap,
          ),
        ),
      ],
    );
  }

  void _handleCardTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FlightsSearchPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HotelsSearchPage()),
      );
    }
  }
}

class _HeroBackgroundImage extends StatelessWidget {
  const _HeroBackgroundImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 225,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.elliptical(450, 40),
          bottomRight: Radius.elliptical(450, 40),
        ),
        image: DecorationImage(
          image: NetworkImage(
            'https://assets.wego.com/image/upload/c_fill,fl_lossy,q_auto:low,f_auto,w_768/v1740659145/web/campaigns/autumn-season/hero-image_mobile_1.jpg',
          ),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }
}

class _HeroCardSection extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onCardTap;

  const _HeroCardSection({
    required this.selectedIndex,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _HeroOptionCard(
              icon: LucideIcons.plane,
              title: l10n.flights,
              index: 0,
              isLeftCard: true,
              isSelected: selectedIndex == 0,
              onTap: () => onCardTap(0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _HeroOptionCard(
              icon: LucideIcons.building2,
              title: l10n.hotels,
              index: 1,
              isLeftCard: false,
              isSelected: selectedIndex == 1,
              onTap: () => onCardTap(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final bool isLeftCard;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeroOptionCard({
    required this.icon,
    required this.title,
    required this.index,
    required this.isLeftCard,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 135,
        height: 119,
        decoration: BoxDecoration(
          borderRadius: isLeftCard
              ? const BorderRadius.horizontal(
                  left: Radius.circular(0),
                  right: Radius.circular(10),
                )
              : const BorderRadius.horizontal(
                  left: Radius.circular(10),
                  right: Radius.circular(0),
                ),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}