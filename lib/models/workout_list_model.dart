import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/store.dart';

class WorkoutListModel with ChangeNotifier {
  List<WorkoutModel> workouts = [];

  WorkoutListModel();

  Future<void> load() async {
    workouts = (await Store.userWorkouts)
        .map(
          (map) => WorkoutModel.mapToModel(map),
        )
        .toList();
  }

  Future<WorkoutModel> addWorkout(String workoutName) async {
    final WorkoutModel workout = await Store.newWorkout(workoutName);
    workouts.add(workout);

    notifyListeners();
    return workout;
  }
}
