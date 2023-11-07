import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/firestore_service.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class Store {
  static final FireStoreService userCol = FireStoreService();
  static final User? user = FirebaseAuth.instance.currentUser;
  static late Database db;

  static Future<List<Map<String, Object?>>> get userWorkouts async {
    db = await DB.instance.database;

    return await db.query(
      TableNames.workouts,
      where: 'uId = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
    );
  }

  static Future<WorkoutModel> newWorkout(String name) async {
    db = await DB.instance.database;

    List<Map<String, Object?>> row = await db.query(
      TableNames.workouts,
      columns: ['MAX(id)+1 AS id', 'COUNT(id)+1 as sortOrder'],
      where: 'uId = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
      groupBy: 'uId',
    );

    WorkoutModel workout = WorkoutModel(
      id: row.isNotEmpty ? row[0]['id'] as int : 1,
      uId: FirebaseAuth.instance.currentUser?.uid ?? 'null',
      isActive: true,
      sortOrder: row.isNotEmpty ? row[0]['sortOrder'] as int : 1,
      name: name,
      creation: DateTime.now(),
    );

    db.insert(
      TableNames.workouts,
      workout.toMap(),
    );

    return workout;
  }
}
