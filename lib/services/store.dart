import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/models/routine_model.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/services/routine_store.dart';
import 'package:gym_bro_alpha/services/workout_store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class Store {
  static late Database db;

  static Future<String> get latestUId async {
    db = await DB.instance.database;

    final mostRecent = await db.query(
      TableNames.userPrefs,
      columns: ['MAX(lastlogin) AS lastlogin'],
    );

    final row = await db.query(TableNames.userPrefs,
        columns: ['uid'],
        where: 'lastlogin = ?',
        whereArgs: [
          (mostRecent.isNotEmpty
              ? mostRecent[0]['lastlogin'] ?? 'null'
              : 'null') as String
        ]);

    return row.isNotEmpty ? (row[0]['uid'] ?? 'null') as String : 'null';
  }

  static Future<String> get latestLogin async {
    db = await DB.instance.database;

    final mostRecent = await db.query(
      TableNames.userPrefs,
      columns: ['MAX(lastlogin) AS lastlogin'],
    );

    return mostRecent.isNotEmpty
        ? (mostRecent[0]['lastlogin'] ?? 'null') as String
        : 'null';
  }

  static Future<bool> get firstTimeUser async {
    db = await DB.instance.database;

    List user = await db.query(
      TableNames.userPrefs,
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid],
    );

    return user.isEmpty;
  }

  static Future<void> loadUserData() async {
    db = await DB.instance.database;

    final userDoc = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid);

    await _loadUserRoutines(userDoc);
    await _loadUserWorkouts(userDoc);
  }

  static Future<void> _loadUserRoutines(DocumentReference userDoc) async {
    db = await DB.instance.database;

    final routines = (await userDoc.collection(CollectionNames.routines).get())
        .docs
        .map((doc) => doc.data())
        .toList()
      ..sort((a, b) => a['sortorder'] - b['sortorder']);

    for (Map<String, dynamic> routine in routines) {
      await db.insert(
        TableNames.routines,
        routine,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<void> _loadUserWorkouts(DocumentReference userDoc) async {
    db = await DB.instance.database;

    final workouts = (await userDoc.collection(CollectionNames.workouts).get())
        .docs
        .map((doc) => doc.data())
        .toList();

    for (Map<String, dynamic> workout in workouts) {
      await db.insert(
        TableNames.workouts,
        workout,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<void> loadExerciseData() async {
    db = await DB.instance.database;

    final groups = (await FirebaseFirestore.instance
            .collection(CollectionNames.exercises)
            .get())
        .docs
        .map((doc) => doc.data())
        .toList();

    final String lastLogin = await latestLogin;

    final List<String> exerciseSchema = (await db.rawQuery(
      'PRAGMA table_info(${TableNames.exercises})',
    ))
        .map(
          (e) => e['name'] as String,
        )
        .toList();

    for (Map<String, dynamic> group in groups) {
      if (lastLogin == 'null' ||
          DateTime.parse(group['lastUpdate'])
              .isAfter(DateTime.parse(lastLogin))) {
        for (Map<String, dynamic> exercise in group['exercises']) {
          db.insert(
            TableNames.exercises,
            _cloudExerciseToDB(exercise, exerciseSchema),
          );
        }
      }
    }
  }

  static Map<String, dynamic> _cloudExerciseToDB(
    Map<String, dynamic> exercise,
    List<String> exerciseSchema,
  ) {
    for (String element in exerciseSchema) {
      if (exercise[element] is List) {
        exercise[element] = jsonEncode(exercise[element]);
      }
    }

    return exercise;
  }

  static Future<int> updateSignInDate(String uid) async {
    db = await DB.instance.database;

    return db.update(
      TableNames.userPrefs,
      {
        'lastlogin': DateTime.now().toIso8601String(),
      },
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  static Future<int> toBeUploaded({
    required String tableName,
    required DBObject object,
    required String operation,
  }) async {
    db = await DB.instance.database;

    Map<String, Object?> data = {
      'origin': tableName,
      'operation': operation,
    }..addAll(object.primaryKeys());

    return db.insert(
      TableNames.toBeUploaded,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> uploadMissing() async {
    db = await DB.instance.database;

    List<Map<String, Object?>> toBeUploaded = await db.query(
      TableNames.toBeUploaded,
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid],
    );

    for (Map<String, Object?> row in toBeUploaded) {
      late DBObject dbObject;

      bool success = false;
      switch (row['operation']) {
        case 'insert':
          switch (row['origin']) {
            case TableNames.routines:
              dbObject = RoutineModel.mapToModel(
                (await db.query(
                  TableNames.routines,
                  where: 'id = ? AND uid = ?',
                  whereArgs: [row['id'], row['uid']],
                ))[0],
              );
              break;

            case TableNames.workouts:
              dbObject = WorkoutModel.mapToModel(
                (await db.query(
                  TableNames.workouts,
                  where: 'id = ? AND uid = ? AND routineid = ?',
                  whereArgs: [row['id'], row['uid'], row['extra']],
                ))[0],
              );
              break;
          }

          if (dbObject is RoutineModel) {
            await RoutineStore.routineCloudSet(dbObject)
                .then((_) => success = true);
          } else if (dbObject is WorkoutModel) {
            await WorkoutStore.workoutCloudSet(dbObject)
                .then((_) => success = true);
          }
          break;

        case 'delete':
          if (row['origin'] == TableNames.routines) {
            await RoutineStore.routineCloudDelete(row['id'] as int)
                .then((_) => success = true);
          } else if (row['origin'] == TableNames.workouts) {
            await WorkoutStore.workoutCloudDelete(row['id'] as int)
                .then((_) => success = true);
          }
          break;
      }

      if (success) {
        db.delete(
          TableNames.toBeUploaded,
          where:
              'origin = ? AND operation = ? AND id = ? AND uid = ? AND extra = ?',
          whereArgs: row.values.toList(),
        );
      }
    }
  }
}
