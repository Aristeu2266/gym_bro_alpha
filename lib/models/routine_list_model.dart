import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/routine_model.dart';
import 'package:gym_bro_alpha/services/store.dart';

class RoutineListModel with ChangeNotifier {
  List<RoutineModel> routines = [];

  RoutineListModel();

  Future<void> load() async {
    routines = (await Store.userRoutines)
        .map(
          (map) => RoutineModel.mapToModel(map),
        )
        .toList();
  }

  Future<void> add(String name, String? description) async {
    routines.add(await Store.newRoutine(name, description));

    notifyListeners();
  }

  void move(int oldIndex, int newIndex) {
    routines.insert(newIndex, routines.removeAt(oldIndex));

    for (int i = 0; i < routines.length; i++) {
      routines[i].sortOrder = i + 1;
    }
  }
}
