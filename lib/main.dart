import 'package:flutter/material.dart';
import 'package:phptravels/SCREENS/home_screen.dart';

void main() {
  runApp(const PHPTRAVELS());
}

class PHPTRAVELS extends StatelessWidget {
  const PHPTRAVELS({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PHPTRAVELS",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: "inter"
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}