import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center( // Fixed: 'cons' to 'const'
      child: Text('Home Screen'),
    );
  }
}