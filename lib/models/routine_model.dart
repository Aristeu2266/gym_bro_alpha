import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/store.dart';

class RoutineModel extends DBObject with ChangeNotifier {
  final int id;
  final String uid;
  late String _name;
  late bool _isActive;
  late int _sortOrder;
  String? _description;
  final DateTime creationDate;
  List<WorkoutModel> workouts = [];

  RoutineModel({
    required this.id,
    required this.uid,
    required name,
    required bool isActive,
    required int sortOrder,
    String? description,
    required this.creationDate,
    this.workouts = const [],
  }) {
    _name = name;
    _isActive = isActive;
    _sortOrder = sortOrder;
    _description = description;
  }

  Future<void> update({String? name, String? description}) async {
    _name = name ?? _name;
    _description = description;
    Store.updateRoutine(this);
    notifyListeners();
  }

  String get name {
    return _name;
  }

  set name(String newName) {
    _name = newName;
    Store.updateRoutine(this);
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
    _sortOrder = (await Store.maxRoutineSortOrder(_isActive)) + 1;
    Store.updateRoutine(this);
    notifyListeners();
    return _isActive;
  }

  int get sortOrder {
    return _sortOrder;
  }

  set sortOrder(int newOrder) {
    assert(newOrder > 0);
    _sortOrder = newOrder;
    Store.updateRoutine(this);
    notifyListeners();
  }

  Future<void> addWorkout(String workoutName) async {
    workouts.add(await Store.newWorkout(workoutName, id));
    notifyListeners();
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'uid': uid,
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
      uid: map['uid'] as String,
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
      'uid': uid,
      'extra': 0,
    };
  }
}
