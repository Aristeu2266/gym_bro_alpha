import 'dart:convert';

class ExerciseModel {
  final int id;
  final String name;
  final bool system;
  final String category;
  final List<String> primaryMuscles;
  final List<String>? secondaryMuscles;
  final String? namePt;
  final String? level;
  final String? videoUrl;
  final String? equipment;
  final List<String>? possibleNames;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.system,
    required this.category,
    required this.primaryMuscles,
    this.secondaryMuscles,
    this.namePt,
    this.level,
    this.videoUrl,
    this.equipment,
    this.possibleNames,
  });

  static ExerciseModel mapToModel(Map<String, Object?> map) {
    return ExerciseModel(
      id: map['id'] as int,
      name: map['name'] as String,
      system: (map['system'] as int) == 1 ? true : false,
      category: map['category'] as String,
      primaryMuscles:
          List<String>.from(jsonDecode(map['primarymuscles'] as String)),
      secondaryMuscles: map['secondarymuscles'] != null
          ? List<String>.from(jsonDecode(map['secondarymuscles'] as String))
          : null,
      namePt: map['namePt'] as String?,
      level: map['level'] as String?,
      videoUrl: map['videourl'] as String?,
      equipment: map['equipment'] as String?,
      possibleNames: map['possiblenames'] != null
          ? List<String>.from(jsonDecode(map['possiblenames'] as String))
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseModel &&
        other.runtimeType == runtimeType &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
