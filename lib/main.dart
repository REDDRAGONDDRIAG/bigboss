import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGameScreen(),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final List<int> snake = [74, 75, 76]; // Snake initial positions
  int food = Random().nextInt(195); // Initial food position
  bool gameOver = false;
  Direction direction = Direction.right;
  int speed = 300; // Initial speed (milliseconds)
  int score = 0;
  DifficultyLevel difficulty = DifficultyLevel.easy;

  bool isGameStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
        leading: Icon(Icons.gamepad), // Add gamepad icon to the app bar
        actions: [
          if (!isGameStarted)
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                startGame();
              },
            ),
        ],
      ),
      body: isGameStarted
          ? RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.data is RawKeyEventDataWeb) {
              final RawKeyEventDataWeb keyData =
              event.data as RawKeyEventDataWeb;

              switch (keyData.code) {
                case 'ArrowUp':
                  if (direction != Direction.down) {
                    direction = Direction.up;
                  }
                  break;
                case 'ArrowDown':
                  if (direction != Direction.up) {
                    direction = Direction.down;
                  }
                  break;
                case 'ArrowLeft':
                  if (direction != Direction.right) {
                    direction = Direction.left;
                  }
                  break;
                case 'ArrowRight':
                  if (direction != Direction.left) {
                    direction = Direction.right;
                  }
                  break;
              }
            }
          }
        },
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Game board
              Expanded(
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 195,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 15,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (snake.contains(index)) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: Color.fromARGB(255, 113, 22, 6),
                            ),
                          ),
                        ),
                      );
                    } else if (index == food) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: Color.fromARGB(255, 3, 78, 21),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: Colors.grey[200],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Movement buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (direction != Direction.down) {
                        direction = Direction.up;
                      }
                    },
                    child: Icon(Icons.arrow_upward),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (direction != Direction.up) {
                        direction = Direction.down;
                      }
                    },
                    child: Icon(Icons.arrow_downward),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (direction != Direction.right) {
                        direction = Direction.left;
                      }
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (direction != Direction.left) {
                        direction = Direction.right;
                      }
                    },
                    child: Icon(Icons.arrow_forward),
                  ),
                ],
              ),

              if (gameOver)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Game Over! Your Score: $score',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          restartGame();
                        },
                        child: Text('Restart Game'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          sendScore(score);
                        },
                        child: Text('Send Score'),
                      ),
                    ],
                  ),
                ),
              Text(
                'Score: $score',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Snake Game!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Select Difficulty Level',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButton<DifficultyLevel>(
              value: difficulty,
              onChanged: (DifficultyLevel? newValue) {
                setState(() {
                  difficulty = newValue!;
                });
              },
              items: DifficultyLevel.values
                  .map((DifficultyLevel level) {
                return DropdownMenuItem<DifficultyLevel>(
                  value: level,
                  child: Text(level.toString().split('.').last),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                startGame();
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }

  void startGame() {
    // Initialize the snake in a valid position based on the grid size
    final int middle = 112;
    setState(() {
      snake.clear();
      snake.addAll([middle, middle - 1, middle - 2]);
      isGameStarted = true;
    });

    // Set the initial food position
    generateFood();

    const duration = Duration(milliseconds: 300);
    Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
      updateSnake();
      if (checkCollision()) {
        timer.cancel();
        endGame();
      }
    });
  }


  void updateSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          if (snake.first < 15) {
            endGame(); // Game over when the snake hits the top wall
          } else {
            snake.insert(0, snake.first - 15);
          }
          break;
        case Direction.down:
          if (snake.first >= 180) {
            endGame(); // Game over when the snake hits the bottom wall
          } else {
            snake.insert(0, snake.first + 15);
          }
          break;
        case Direction.left:
          if (snake.first % 15 == 0) {
            endGame(); // Game over when the snake hits the left wall
          } else {
            snake.insert(0, snake.first - 1);
          }
          break;
        case Direction.right:
          if ((snake.first + 1) % 15 == 0) {
            endGame(); // Game over when the snake hits the right wall
          } else {
            snake.insert(0, snake.first + 1);
          }
          break;
      }

      if (checkCollision()) {
        endGame(); // Game over when the snake hits itself
      }

      if (snake.first == food) {
        generateFood();
        increaseScore();
      } else {
        snake.removeLast();
      }
    });
  }

  void generateFood() {
    food = Random().nextInt(195);
    while (snake.contains(food) || food == snake.first) {
      food = Random().nextInt(195);
    }
  }


  bool checkCollision() {
    if (snake.first < 0 ||
        snake.first >= 195 ||
        snake.skip(1).contains(snake.first)) {
      return true;
    }
    return false;
  }

  void endGame() {
    setState(() {
      gameOver = true;
    });
  }

  void restartGame() {
    setState(() {
      snake.clear();
      snake.addAll([74, 75, 76]);
      food = Random().nextInt(195);
      gameOver = false;
      score = 0;
      isGameStarted = false;
    });
  }

  void sendScore(int score) {
    // Implement sending the score to your server or other desired functionality
    print('Score sent: $score');
  }

  void increaseScore() {
    setState(() {
      score++;
    });
  }

  @override
  void initState() {
    super.initState();
  }
}

enum Direction { up, down, left, right }

enum DifficultyLevel { easy, medium, hard }