import 'package:flutter/material.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isGameOver = false; // Fixed: 'fals' to 'false'
  Timer? _gameTimer; // Fixed: Made nullable to allow late initialization or no initialization

  @override
  void initState() {
    super.initState();
    // Initialize _gameTimer here if needed, or it can remain null until assigned
  }

  @override
  void dispose() {
    _gameTimer?.cancel(); // Fixed: 'gameTimer' to '_gameTimer'
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Game Screen'),
    );
  }
}