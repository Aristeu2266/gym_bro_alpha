class UserRoutine {
  final String id;
  final String userid;
  final bool isActive;
  final int order;
  final String name;
  List exercises = [];
  List trainings = [];

  UserRoutine({
    required this.id,
    required this.userid,
    required this.isActive,
    required this.order,
    required this.name,
  });
}
