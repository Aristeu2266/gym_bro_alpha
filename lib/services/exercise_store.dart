import 'package:gym_bro_alpha/models/exercise_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class ExerciseStore {
  static late Database db;

  static Future<List<ExerciseModel>> get localExercises async {
    db = await DB.instance.database;

    return (await db.query(TableNames.exercises))
        .map((e) => ExerciseModel.mapToModel(e))
        .toList();
  }
}
