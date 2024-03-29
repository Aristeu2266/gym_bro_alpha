import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/routine_model.dart';
import 'package:gym_bro_alpha/services/routine_store.dart';

class RoutineListModel with ChangeNotifier {
  List<RoutineModel> routines = [];

  RoutineListModel();

  Future<void> load() async {
    routines = (await RoutineStore.localUserRoutines)
        .map((map) => RoutineModel.mapToModel(map))
        .toList();

    notifyListeners();
  }

  Future<void> refresh() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await RoutineStore.refreshUserRoutines();
    }
    await load();
  }

  Future<void> add(String name, String? description) async {
    routines.add(await RoutineStore.newRoutine(name, description));

    notifyListeners();
  }

  Future<void> delete(int index) async {
    await RoutineStore.deleteRoutine(inactiveRoutines.removeAt(index));
    await load();

    notifyListeners();
  }

  void move(int oldIndex, int newIndex, bool active) {
    final routines = active ? activeRoutines : inactiveRoutines;

    routines.insert(newIndex, routines.removeAt(oldIndex));

    for (int i = 0; i < routines.length; i++) {
      routines[i].sortOrder = i + 1;
    }
    this.routines.sort(
      (a, b) {
        return a.sortOrder - b.sortOrder;
      },
    );
    notifyListeners();
  }

  Future<void> toggleIsActive(RoutineModel routine) async {
    bool isActive =
        await routines.firstWhere((e) => e.id == routine.id).toggleIsActive();
    await _updateSortOrder(!isActive);
    await load();
    notifyListeners();
  }

  Future<void> _updateSortOrder(bool active) async {
    if (active) {
      for (int i = 0; i < activeRoutines.length; i++) {
        activeRoutines[i].sortOrder = i + 1;
      }
    } else {
      for (int i = 0; i < inactiveRoutines.length; i++) {
        inactiveRoutines[i].sortOrder = i + 1;
      }
    }
  }

  List<RoutineModel> get activeRoutines {
    return routines.where((routine) => routine.isActive).toList()
      ..sort(
        (a, b) {
          return a.sortOrder - b.sortOrder;
        },
      );
  }

  List<RoutineModel> get inactiveRoutines {
    return routines.where((routine) => !routine.isActive).toList()
      ..sort(
        (a, b) {
          return a.sortOrder - b.sortOrder;
        },
      );
  }
}
