import 'package:flutter/material.dart';
import 'dart:math'; // Import math for random numbers
import 'dart:async'; // Import async for Timer

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game variables
  int score = 0;
  bool isGameOver = false;
  bool isGameStarted = false;

  // Player variables
  double playerX = 0.5; // Initial player position (center)
  double playerBulletY = 1.0; // Initial bullet position (below screen)
  bool isShooting = false;

  // Enemy variables
  List<Map<String, dynamic>> enemies = [];
  final int numberOfEnemies = 5;
  final double enemySize = 50.0;
  final double enemySpeed = 2.0;

  // Game loop timer
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _initializeEnemies();
  }

  @override
  void dispose() {
    _gameTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _initializeEnemies() {
    enemies.clear();
    final random = Random();
    for (int i = 0; i < numberOfEnemies; i++) {
      enemies.add({
        'x': random.nextDouble(), // Random horizontal position
        'y': -random.nextDouble() * 5, // Start from above the screen
        'alive': true,
      });
    }
  }

  void _startGame() {
    setState(() {
      score = 0;
      isGameOver = false;
      isGameStarted = true;
      _initializeEnemies();
      isShooting = false;
      playerBulletY = 1.0;
      print('Game started!');
    });
    _startTimer();
  }

  void _endGame() {
    setState(() {
      isGameOver = true;
      isGameStarted = false;
      print('Game Over!');
    });
    _gameTimer?.cancel();
  }

  void _startTimer() {
    _gameTimer?.cancel(); // Cancel any existing timer
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _movePlayer(double deltaX) {
    setState(() {
      playerX += deltaX;
      if (playerX < 0.05) playerX = 0.05;
      if (playerX > 0.95) playerX = 0.95;
    });
  }

  void _shoot() {
    if (!isShooting && isGameStarted && !isGameOver) {
      setState(() {
        isShooting = true;
        playerBulletY = 0.8; // Start bullet from player's position
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        // Only reset if the game is still running and the player is still shooting
        if (mounted && isShooting) {
          setState(() {
            isShooting = false;
            playerBulletY = 1.0; // Reset bullet position below screen
          });
        }
      });
    }
  }

  void _updateGame() {
    if (!isGameStarted || isGameOver) return;

    setState(() {
      // Update enemy positions
      for (var enemy in enemies) {
        if (enemy['alive']) {
          enemy['y'] += enemySpeed / 60;
          if (enemy['y'] > 1.1) {
            enemy['alive'] = false;
            // Consider ending the game or losing a life if an enemy reaches the bottom
            // For now, we just remove it.
          }
        }
      }

      // Update bullet position
      if (isShooting) {
        playerBulletY -= 0.05; // Move bullet up
        if (playerBulletY < 0) {
          isShooting = false;
          playerBulletY = 1.0;
        }
      }

      // Collision detection
      for (var enemy in enemies) {
        if (enemy['alive'] && isShooting) {
          double bulletCenterX = playerX; // Assuming bullet is centered with player
          double bulletCenterY = playerBulletY;
          double enemyCenterX = enemy['x'];
          double enemyCenterY = enemy['y'];

          // Calculate distance between centers
          double distance = sqrt(pow(bulletCenterX - enemyCenterX, 2) + pow(bulletCenterY - enemyCenterY, 2));

          // Collision if distance is less than sum of half sizes
          if (distance < (0.05 + 0.05)) { // 0.05 is half of player bullet width/height, 0.05 is half of enemy size
            enemy['alive'] = false;
            score++;
            isShooting = false; // Bullet disappears after hit
            playerBulletY = 1.0; // Reset bullet position
            print('Hit! Score: $score');
            break; // Only one hit per bullet
          }
        }
      }

      // Check if all enemies are gone
      bool allEnemiesDefeated = enemies.every((enemy) => !enemy['alive']);
      if (allEnemiesDefeated) {
        _endGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打飞机小游戏'),
        backgroundColor: Colors.pinkAccent,
      ),
      backgroundColor: Colors.red, // Set background to red
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _movePlayer(details.delta.dx / context.size!.width * 0.5);
        },
        onTap: _shoot, // Shoot on tap
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Enemies
            ...enemies.where((enemy) => enemy['alive']).map((enemy) {
              return Positioned(
                left: enemy['x'] * context.size!.width,
                top: enemy['y'] * context.size!.height,
                child: Image.asset(
                  'assets/enemy_plane.png', // Make sure you have this asset
                  width: enemySize,
                  height: enemySize,
                ),
              );
            }).toList(),

            // Player Bullet
            if (isShooting)
              Positioned(
                left: playerX * context.size!.width - 10, // Adjust for bullet width
                top: playerBulletY * context.size!.height,
                child: Image.asset(
                  'assets/bullet.png', // Make sure you have this asset
                  width: 20,
                  height: 30,
                ),
              ),

            // Player
            Positioned(
              left: playerX * context.size!.width - 30, // Adjust for player width
              top: 0.85 * context.size!.height, // Fixed position at the bottom
              child: Image.asset(
                'assets/player_plane.png', // Make sure you have this asset
                width: 60,
                height: 60,
              ),
            ),

            // Game Over Overlay
            if (isGameOver)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                ),
              ),

            // Start Game Button
            if (!isGameStarted && !isGameOver)
              Positioned.fill(
                child: Center(
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Start Game'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
