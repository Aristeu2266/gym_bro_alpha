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

  Future<void> addWorkout(String workoutName) async {
    workouts.add(await Store.newWorkout(workoutName));

    notifyListeners();
  }
}
