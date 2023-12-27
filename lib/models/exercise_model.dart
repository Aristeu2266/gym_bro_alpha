class ExerciseModel {
  final int id;
  final String name;
  final List<String> primaryMuscles;
  final bool isDefault;
  final List<String>? secondaryMuscles;
  final String? level;
  final String? videoUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    required this.isDefault,
    this.secondaryMuscles,
    this.level,
    this.videoUrl,
  });
}
