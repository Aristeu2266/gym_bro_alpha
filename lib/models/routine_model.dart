import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/store.dart';

class RoutineModel extends DBObject with ChangeNotifier {
  final int id;
  final String uid;
  late String name;
  late bool _isActive;
  late int _sortOrder;
  String? description;
  final DateTime creationDate;
  List<WorkoutModel> workouts = [];

  RoutineModel({
    required this.id,
    required this.uid,
    required this.name,
    required bool isActive,
    required int sortOrder,
    this.description,
    required this.creationDate,
  }) {
    _isActive = isActive;
    _sortOrder = sortOrder;
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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'isactive': _isActive ? 1 : 0,
      'sortorder': _sortOrder,
      'description': description,
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
