import 'dart:async';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isGameOver = false;
  bool isGameStarted = false;
  bool isShooting = false;

  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      isGameStarted = true;
      isGameOver = false;
      _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Game logic here
      });
    });
  }

  void _endGame() {
    setState(() {
      isGameStarted = false;
      isGameOver = true;
      _gameTimer?.cancel();
    });
  }

  void _shoot() {
    setState(() {
      isShooting = true;
      if (!isShooting && isGameStarted && !isGameOver) {
        // Some shooting logic
      }
      isShooting = false;
    });
  }

  void _updateGame() {
    if (!isGameStarted || isGameOver) return;
    // More game update logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Game Status: ${isGameOver ? "Game Over" : "Playing"}'),
            ElevatedButton(
              onPressed: isGameStarted ? _endGame : _startGame,
              child: Text(isGameStarted ? 'End Game' : 'Start Game'),
            ),
            if (isGameOver)
              const Text('Game Over!'),
            if (!isGameStarted && !isGameOver)
              const Text('Press Start to play'),
          ],
        ),
      ),
    );
  }
}
