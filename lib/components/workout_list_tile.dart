import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:provider/provider.dart';

class WorkoutListTile extends StatefulWidget {
  const WorkoutListTile(this.workout, {super.key});

  final WorkoutModel workout;

  @override
  State<WorkoutListTile> createState() => _WorkoutListTileState();
}

class _WorkoutListTileState extends State<WorkoutListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutModel>(
      builder: (context, workout, child) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.workout,
              arguments: widget.workout);
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text(widget.workout.name),
          ),
        ),
      ),
    );
  }
}
