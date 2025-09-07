import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game variables would go here
  int score = 0;
  bool isGameOver = false;
  bool isGameStarted = false; // Track if the game has started

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打飞机小游戏'),
        backgroundColor: Colors.pinkAccent,
      ),
      backgroundColor: Colors.black, // Set background to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // White text for better contrast
            ),
            const SizedBox(height: 20),
            if (isGameOver)
              Column(
                children: [
                  const Text(
                    'Game Over!',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startGame,
                    child: const Text('Play Again'),
                  )
                ],
              )
            else if (!isGameStarted)
              ElevatedButton(
                onPressed: _startGame, // Start the game
                child: const Text('Start Game'),
              )
            else
              // This is where the actual game elements (like airplanes, bullets, player) would be rendered.
              // For now, it's a placeholder.
              const Text('Game in progress...', style: TextStyle(color: Colors.white)), // Placeholder for active game
          ],
        ),
      ),
    );
  }

  void _startGame() {
    setState(() {
      score = 0;
      isGameOver = false;
      isGameStarted = true; // Set game as started
      // Initialize game logic here
      print('Game started!');
    });
  }

  // Add other game logic methods here, e.g., _movePlane, _shoot, _checkCollision, etc.
}
