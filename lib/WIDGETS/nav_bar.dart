import 'package:flutter/material.dart';

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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
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
          _buildNavItem("Home", Icons.home, 0),
          _buildNavItem("Explore", Icons.explore, 1),
          _buildNavItem("Stories", Icons.article, 2),
          _buildNavItem("Account", Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        onTap(index); 
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getOutlinedIcon(icon),
            color: isSelected ? Colors.blue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey,
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