import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/services/store.dart';

class WorkoutModel extends DBObject with ChangeNotifier {
  final int id;
  final String uId;
  final int routineId;
  late int _sortOrder;
  late String _name;
  final DateTime creationDate;
  List exercises = [];
  List trainings = [];

  WorkoutModel({
    required this.id,
    required this.uId,
    required this.routineId,
    required sortOrder,
    required name,
    required this.creationDate,
  }) {
    _name = name;
    _sortOrder = sortOrder;
  }

  String get name {
    return _name;
  }

  set name(String s) {
    assert(s.isNotEmpty);
    _name = s;
    Store.updateWorkout(this);
    notifyListeners();
  }

  int get sortOrder {
    return _sortOrder;
  }

  set sortOrder(int newOrder) {
    assert(newOrder > 0);
    _sortOrder = newOrder;
    Store.updateWorkout(this);
    notifyListeners();
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'uid': uId,
      'routineid': routineId,
      'sortorder': _sortOrder,
      'name': _name,
      'creationdate': creationDate.toIso8601String(),
    };
  }

  static WorkoutModel mapToModel(Map<String, Object?> map) {
    return WorkoutModel(
      id: map['id'] as int,
      uId: map['uid'] as String,
      routineId: map['routineid'] as int,
      sortOrder: map['sortorder'] as int,
      name: map['name'] as String,
      creationDate: DateTime.parse(map['creationdate'] as String),
    );
  }

  @override
  Map<String, Object?> primaryKeys() {
    return {
      'id': id,
      'uid': uId,
      'extra': routineId,
    };
  }
}
