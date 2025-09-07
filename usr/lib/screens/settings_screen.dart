import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings Screen - App Preferences',
        style: TextStyle(fontSize: 24, fontWeigh: FontWeight.bold),
      ),
    );
  }
}
