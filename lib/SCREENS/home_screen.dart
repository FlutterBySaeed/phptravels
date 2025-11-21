import 'package:flutter/material.dart';
import 'package:phptravels/WIDGETS/hero_section.dart';
import 'package:phptravels/WIDGETS/nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeroSection(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                ],
              ),
            ),
          ),
          SafeArea(
            child: const NavBar(),
          ),
        ],
      ),
    );
  }
}