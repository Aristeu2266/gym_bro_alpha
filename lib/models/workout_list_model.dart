import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';

class WorkoutListModel with ChangeNotifier {
  List<WorkoutModel> workouts = [];

  WorkoutListModel();

  void addWorkout(String workoutName) {
    workouts.add(WorkoutModel(
        id: 'id',
        userId: 'userId',
        isActive: true,
        order: 1,
        name: workoutName,
        creation: DateTime.now()));
    notifyListeners();
  }
}
