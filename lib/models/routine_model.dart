import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/store.dart';

class RoutineModel extends DBObject with ChangeNotifier {
  final int id;
  final String uid;
  late String name;
  late int _sortOrder;
  String? description;
  final DateTime creationDate;
  List<WorkoutModel> workouts = [];

  RoutineModel({
    required this.id,
    required this.uid,
    required this.name,
    required sortOrder,
    this.description,
    required this.creationDate,
  }) {
    _sortOrder = sortOrder;
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
