import 'package:flutter/material.dart';

class DifficultyWidget extends StatelessWidget {
  const DifficultyWidget(this.difficulty, {super.key});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.filled(
          difficulty,
          ColoredSquare(difficulty: difficulty),
        ),
        ...List.filled(
          3 - difficulty,
          const ColoredSquare(difficulty: 0),
        ),
      ],
    );
  }
}

class ColoredSquare extends StatelessWidget {
  const ColoredSquare({
    super.key,
    required this.difficulty,
  });

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.square,
      color: difficulty == 1
          ? Colors.green
          : difficulty == 2
              ? Colors.orange
              : difficulty == 3
                  ? Colors.red
                  : Colors.grey,
      size: 14,
    );
  }
}
