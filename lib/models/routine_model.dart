import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/routine_store.dart';
import 'package:gym_bro_alpha/services/workout_store.dart';

class RoutineModel extends DBObject with ChangeNotifier {
  final int id;
  final String uId;
  late String _name;
  late bool _isActive;
  late int _sortOrder;
  String? _description;
  final DateTime creationDate;
  late List<WorkoutModel> workouts;

  RoutineModel({
    required this.id,
    required this.uId,
    required name,
    required bool isActive,
    required int sortOrder,
    String? description,
    required this.creationDate,
    List<WorkoutModel>? workouts,
  }) {
    _name = name;
    _isActive = isActive;
    _sortOrder = sortOrder;
    _description = description;
    this.workouts = workouts ?? [];
  }

  Future<void> update({String? name, String? description}) async {
    if (name != _name || description != _description) {
      _name = name ?? _name;
      _description = description ?? _description;
      RoutineStore.updateRoutine(this);
      notifyListeners();
    }
  }

  String get name {
    return _name;
  }

  set name(String newName) {
    _name = newName;
    RoutineStore.updateRoutine(this);
    notifyListeners();
  }

  String? get description {
    return _description;
  }

  bool get isActive {
    return _isActive;
  }

  Future<bool> toggleIsActive() async {
    _isActive = !_isActive;
    _sortOrder = (await RoutineStore.maxRoutineSortOrder(_isActive)) + 1;
    RoutineStore.updateRoutine(this);
    notifyListeners();
    return _isActive;
  }

  int get sortOrder {
    return _sortOrder;
  }

  set sortOrder(int newOrder) {
    assert(newOrder > 0);
    _sortOrder = newOrder;
    RoutineStore.updateRoutine(this);
    notifyListeners();
  }

  Future<void> addWorkout(String workoutName) async {
    workouts.add(await WorkoutStore.newWorkout(workoutName, id));
    notifyListeners();
  }

  Future<void> deleteWorkout(int index) async {
    await WorkoutStore.deleteWorkout(workouts.removeAt(index));
    await load();
    notifyListeners();
  }

  void reorderWorkout(int oldIndex, int newIndex) {
    workouts.insert(newIndex, workouts.removeAt(oldIndex));

    for (int i = 0; i < workouts.length; i++) {
      workouts[i].sortOrder = i + 1;
    }
    workouts.sort((a, b) => a.sortOrder - b.sortOrder);

    notifyListeners();
  }

  Future<void> load() async {
    workouts = (await WorkoutStore.localUserWorkouts(id))
        .map((map) => WorkoutModel.mapToModel(map))
        .toList();

    notifyListeners();
  }

  Future<void> refresh() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await WorkoutStore.refreshUserWorkouts(id);
    }
    await load();
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'uid': uId,
      'name': _name,
      'isactive': _isActive ? 1 : 0,
      'sortorder': _sortOrder,
      'description': _description,
      'creationdate': creationDate.toIso8601String(),
    };
  }

  static RoutineModel mapToModel(Map<String, Object?> map) {
    return RoutineModel(
      id: map['id'] as int,
      uId: map['uid'] as String,
      name: map['name'] as String,
      isActive: (map['isactive'] as int) == 1 ? true : false,
      sortOrder: map['sortorder'] as int,
      description: map['description'] as String?,
      creationDate: DateTime.parse(map['creationdate'] as String),
      workouts: (map['workouts'] ?? []) as List<WorkoutModel>,
    );
  }

  @override
  Map<String, Object?> primaryKeys() {
    return {
      'id': id,
      'uid': uId,
      'extra': 0,
    };
  }
}
