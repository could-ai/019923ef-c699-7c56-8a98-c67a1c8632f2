import 'package:flutter/material.dart';
import 'dart:math'; // Import math for random numbers

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
  // We will use a Ticker or Timer for the game loop in a real implementation.
  // For this example, we'll simulate updates within setState calls.

  @override
  void initState() {
    super.initState();
    // Initialize enemies when the game screen is first built
    _initializeEnemies();
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
      _initializeEnemies(); // Re-initialize enemies for a new game
      isShooting = false; // Reset shooting state
      playerBulletY = 1.0; // Reset bullet position
      print('Game started!');
    });
    // In a real game, you would start your game loop timer here.
  }

  void _endGame() {
    setState(() {
      isGameOver = true;
      isGameStarted = false;
      print('Game Over!');
    });
    // In a real game, you would stop your game loop timer here.
  }

  void _movePlayer(double deltaX) {
    setState(() {
      playerX += deltaX;
      // Clamp player position to screen bounds
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
      // In a real game, you would handle bullet movement and collision detection here.
      // For simplicity, we'll just reset it after a short delay.
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isShooting = false;
          playerBulletY = 1.0; // Reset bullet position below screen
        });
      });
    }
  }

  void _updateGame() {
    if (!isGameStarted || isGameOver) return;

    setState(() {
      // Update enemy positions
      for (var enemy in enemies) {
        if (enemy['alive']) {
          enemy['y'] += enemySpeed / 60; // Move enemies down (assuming 60 FPS)
          // Check if enemy goes below screen
          if (enemy['y'] > 1.1) {
            enemy['alive'] = false; // Mark as not alive
            // Optionally, you could end the game or reduce lives here
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

      // Collision detection (simplified)
      for (var enemy in enemies) {
        if (enemy['alive'] && isShooting) {
          // Check if bullet hits enemy (basic bounding box collision)
          if ((playerBulletY - 0.1).abs() < (enemy['y'] - playerBulletY).abs() && // Bullet Y is close to enemy Y
              (playerX - 0.05).abs() < (enemy['x'] - playerX).abs() && // Bullet X is close to enemy X
              (enemy['y'] - 0.1).abs() < (playerBulletY - enemy['y']).abs() && // Enemy Y is close to bullet Y
              (enemy['x'] - 0.05).abs() < (playerBulletY - enemy['x']).abs() // Enemy X is close to bullet X
              ) {
            // This collision logic is very basic and likely needs refinement
            // A more robust collision check would involve comparing the centers and sizes of the objects.
            // For now, let's assume a hit if the bullet is near the enemy.
            
            // Simplified collision check:
            double bulletCenterX = playerX; // Assuming bullet is centered with player
            double bulletCenterY = playerBulletY;
            double enemyCenterX = enemy['x'];
            double enemyCenterY = enemy['y'];

            // Calculate distance between centers
            double distance = sqrt(pow(bulletCenterX - enemyCenterX, 2) + pow(bulletCenterY - enemyCenterY, 2));

            // If distance is less than sum of half sizes, it's a collision
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
      }

      // Check if all enemies are gone or if any enemy reached the bottom
      bool allEnemiesDefeated = enemies.every((enemy) => !enemy['alive']);
      if (allEnemiesDefeated) {
        _endGame(); // Or proceed to next level
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use WidgetsBinding to schedule the game loop after the first frame is built.
    // This ensures that setState is called on a mounted widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isGameStarted && !isGameOver) {
        _updateGame();
        // Schedule the next update. In a real game, use a Timer or Ticker.
        Future.delayed(const Duration(milliseconds: 16), _updateGame);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('打飞机小游戏'),
        backgroundColor: Colors.pinkAccent,
      ),
      backgroundColor: Colors.black, // Set background to black
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Adjust sensitivity as needed
          _movePlayer(details.delta.dx / context.size!.width * 0.5);
        },
        onTap: _shoot, // Shoot on tap
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background (already set in Scaffold)

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

            // Player (represented by a simple container for now)
            // You would replace this with your player ship image
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

            // Start Game Button (only visible before game starts)
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
