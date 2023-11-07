class WorkoutModel {
  final int id;
  final String uId;
  final bool isActive;
  final int sortOrder;
  final String name;
  final DateTime creation;
  List exercises = [];
  List trainings = [];

  WorkoutModel({
    required this.id,
    required this.uId,
    required this.isActive,
    required this.sortOrder,
    required this.name,
    required this.creation,
  });

  Map<String, Object> toMap() {
    return {
      'id': id,
      'uId': uId,
      'isActive': isActive ? 1 : 0,
      'sortOrder': sortOrder,
      'name': name,
      'creation': creation.toIso8601String(),
    };
  }

  static WorkoutModel mapToModel(Map<String, Object?> map) {
    return WorkoutModel(
      id: map['id'] as int,
      uId: map['uId'] as String,
      isActive: (map['isActive'] as int) == 1 ? true : false,
      sortOrder: map['sortOrder'] as int,
      name: map['name'] as String,
      creation: DateTime.parse(map['creation'] as String),
    );
  }
}
