import 'package:flutter/material.dart';
import 'package:phptravels/core/widgets/nav_bar.dart';
import 'package:phptravels/features/home/pages/home_page.dart';
import 'package:phptravels/features/account/pages/account_page.dart';
import 'package:phptravels/features/Explore/explore_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const ExplorePage(), // Placeholder for Explore
      const HomeScreen(), // Placeholder for Stories
      const AccountsPage(),
    ];
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        // ← No SafeArea here
        children: [
          Expanded(
            child: _screens[_selectedIndex],
          ),
          SafeArea(
            // ← Keep this SafeArea for nav bar only
            top: false,
            child: NavBar(
              selectedIndex: _selectedIndex,
              onTap: _onNavBarTapped,
            ),
          ),
        ],
      ),
    );
  }
}
