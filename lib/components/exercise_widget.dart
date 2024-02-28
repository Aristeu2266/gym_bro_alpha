import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/exercise_model.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseWidget(this.exercise, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercise.name),
    );
  }
}
