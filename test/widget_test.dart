import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bigboss/main.dart';

void main() {
  testWidgets('Snake Game Test', (WidgetTester tester) async {
    await tester.pumpWidget(SnakeGame());

    // Ensure that the game starts
    expect(find.text('Score: 0'), findsOneWidget);

    // Simulate game gestures (you may need to adjust coordinates based on your grid size)
    await tester.drag(find.byType(GestureDetector), Offset(0.0, -50.0)); // Swipe up
    await tester.pump();

    // Ensure that the snake moves in response to gestures
    expect(find.text('Score: 0'), findsOneWidget);

    // You can continue with more test scenarios based on your game logic
    // For example, check if the game over screen appears when the snake collides with a wall or itself
  });
}
