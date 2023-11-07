import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class Store {
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

  static Future<String> get latestUId async {
    db = await DB.instance.database;

    final mostRecent = await db.query(
      TableNames.userPrefs,
      columns: ['MAX(lastLogin) AS lastLogin'],
    );

    final row = await db.query(TableNames.userPrefs,
        columns: ['uId'],
        where: 'lastLogin = ?',
        whereArgs: [
          (mostRecent.isNotEmpty
              ? mostRecent[0]['lastLogin'] ?? 'null'
              : 'null') as String
        ]);

    return row.isNotEmpty ? (row[0]['uid'] ?? 'null') as String : 'null';
  }

  static Future<int> updateSignInDate(String uid) async {
    db = await DB.instance.database;

    return db.update(
      TableNames.userPrefs,
      {
        'lastLogin': DateTime.now().toIso8601String(),
      },
      where: 'uId = ?',
      whereArgs: [uid],
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

    final connectivity = await Connectivity().checkConnectivity();
    if (user != null) {
      if (connectivity != ConnectivityResult.none) {
        _workoutToCloud(workout);
      } else {}
    }

    return workout;
  }

  static Future<void> _workoutToCloud(WorkoutModel workout) async {
    final workoutCol = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('workouts');
    final workoutDoc = workoutCol.doc('${workout.id}');

    return workoutDoc.set(
      workout.toMap(),
    );
  }
}
