class WorkoutModel {
  final String id;
  final String userId;
  final bool isActive;
  final int order;
  final String name;
  final DateTime creation;
  List exercises = [];
  List trainings = [];

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.isActive,
    required this.order,
    required this.name,
    required this.creation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'isActive': isActive,
      'order': order,
      'name': name,
      'creation': creation,
    };
  }
}
