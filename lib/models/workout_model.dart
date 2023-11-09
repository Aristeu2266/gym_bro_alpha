import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/services/store.dart';

class WorkoutModel extends DBObject with ChangeNotifier {
  final int id;
  final String uId;
  bool isActive;
  int sortOrder;
  late String _name;
  final DateTime creation;
  List exercises = [];
  List trainings = [];

  WorkoutModel({
    required this.id,
    required this.uId,
    required this.isActive,
    required this.sortOrder,
    required name,
    required this.creation,
  }) {
    _name = name;
  }

  set name(String s) {
    assert(s.isNotEmpty);
    _name = s;
    Store.updateWorkout(this);
    notifyListeners();
  }

  String get name {
    return _name;
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'uId': uId,
      'isActive': isActive ? 1 : 0,
      'sortOrder': sortOrder,
      'name': _name,
      'creation': creation.toIso8601String(),
    };
  }

  static WorkoutModel mapToModel(Map<String, Object?> map) {
    return WorkoutModel(
      id: map['id'] as int,
      uId: map['uid'] as String,
      isActive: (map['isactive'] as int) == 1 ? true : false,
      sortOrder: map['sortorder'] as int,
      name: map['name'] as String,
      creation: DateTime.parse(map['creation'] as String),
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
