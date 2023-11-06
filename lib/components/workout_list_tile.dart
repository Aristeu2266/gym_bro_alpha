import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';

class WorkoutListTile extends StatefulWidget {
  const WorkoutListTile(this.workout, {super.key});

  final WorkoutModel workout;

  @override
  State<WorkoutListTile> createState() => _WorkoutListTileState();
}

class _WorkoutListTileState extends State<WorkoutListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(widget.workout.name),
      ),
    );
  }
}
