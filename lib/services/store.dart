import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/exceptions/connection_exception.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/models/routine_model.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class Store {
  static late Database db;

  static Future<List<Map<String, dynamic>>> get localUserRoutines async {
    db = await DB.instance.database;

    return await db.query(
      TableNames.routines,
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
    );
  }

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

  static Future<void> refreshUserRoutines() async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      throw ConnectionException('Connection failed');
    }

    db = await DB.instance.database;

    final userDoc = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final routines = (await userDoc.collection(CollectionNames.routines).get())
        .docs
        .map((doc) => doc.data())
        .toList()
      ..sort((a, b) => a['id'] - b['id']);

    final localRoutinesIds =
        (await localUserRoutines).map((e) => e['id'] as int).toList();

    for (Map<String, dynamic> routine in routines) {
      if (localRoutinesIds.contains(routine['id'])) {
        final localRoutine = (await localUserRoutines)
            .firstWhere((e) => routine['id'] == e['id']);
        if (DateTime.parse(routine['creationdate'])
            .isAfter(DateTime.parse(localRoutine['creationdate']))) {
          _deleteCloudRoutine(routine['id']);
          db.insert(TableNames.routines, routine);
        }
      } else {
        db.insert(TableNames.routines, routine);
      }
    }
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

  static Future<RoutineModel> newRoutine(
      String name, String? description) async {
    db = await DB.instance.database;

    List<Map<String, Object?>> idNSort = (await db.query(
      TableNames.routines,
      columns: ['MAX(id)+1 AS id', 'COUNT(sortorder)+1 as sortorder'],
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
      groupBy: 'uid',
    ));

    RoutineModel routine = RoutineModel(
      id: idNSort.isNotEmpty ? idNSort[0]['id'] as int : 1,
      uid: FirebaseAuth.instance.currentUser?.uid ?? 'null',
      name: name,
      sortOrder: idNSort.isNotEmpty ? idNSort[0]['sortorder'] as int : 1,
      description: description,
      creationDate: DateTime.now(),
    );

    db.insert(
      TableNames.routines,
      routine.toMap(),
    );

    final connectivity = await Connectivity().checkConnectivity();

    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        _routineCloudSet(routine);
      } else {
        _toBeUploaded(
          tableName: TableNames.routines,
          object: routine,
          operation: 'insert',
        );
      }
    }

    return routine;
  }

  static Future<void> _routineCloudSet(RoutineModel routine,
      [SetOptions? setOptions]) async {
    final routineCol = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(CollectionNames.routines)
        .doc('${routine.id}');

    return routineCol.set(
      routine.toMap(),
      setOptions,
    );
  }

  static Future<void> updateRoutine(RoutineModel routine) async {
    db = await DB.instance.database;

    db.update(
      TableNames.routines,
      routine.toMap(),
      where: 'id = ? AND uid = ?',
      whereArgs: [routine.id, routine.uid],
    );

    final connectivity = await Connectivity().checkConnectivity();
    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        _routineCloudUpdate(routine);
      } else {
        _toBeUploaded(
          tableName: TableNames.routines,
          object: routine,
          operation: 'insert',
        );
      }
    }
  }

  static Future<void> _routineCloudUpdate(RoutineModel routine) async {
    return _routineCloudSet(
      routine,
      SetOptions(merge: true),
    );
  }

  static Future<void> deleteRoutine(RoutineModel routine) async {
    db = await DB.instance.database;

    db.delete(
      TableNames.routines,
      where: 'id = ? AND uid = ?',
      whereArgs: [routine.id, routine.uid],
    );

    final connectivity = await Connectivity().checkConnectivity();
    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        _deleteCloudRoutine(routine.id);
      } else {
        _toBeUploaded(
          tableName: TableNames.routines,
          object: routine,
          operation: 'delete',
        );
      }
    }
  }

  static Future<void> _deleteCloudRoutine(int routine) async {
    final routineDoc = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(CollectionNames.routines)
        .doc('$routine');

    return routineDoc.delete();
  }

  static Future<void> _loadUserWorkouts(DocumentReference userDoc) async {
    db = await DB.instance.database;

    final workouts = (await userDoc.collection(CollectionNames.workouts).get())
        .docs
        .map((doc) => doc.data())
        .toList()
      ..sort((a, b) => a['sortorder'] - b['sortorder']);

    for (Map<String, dynamic> workout in workouts) {
      await db.insert(
        TableNames.workouts,
        workout,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<WorkoutModel> newWorkout(String name, int routineId) async {
    db = await DB.instance.database;

    List<Map<String, Object?>> idNSort = await db.query(
      TableNames.workouts,
      columns: ['MAX(id)+1 AS id', 'COUNT(id)+1 as sortorder'],
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
      groupBy: 'uid',
    );

    WorkoutModel workout = WorkoutModel(
      id: idNSort.isNotEmpty ? idNSort[0]['id'] as int : 1,
      uId: FirebaseAuth.instance.currentUser?.uid ?? 'null',
      routineId: routineId,
      isActive: true,
      sortOrder: idNSort.isNotEmpty ? idNSort[0]['sortorder'] as int : 1,
      name: name,
      creation: DateTime.now(),
    );

    db.insert(
      TableNames.workouts,
      workout.toMap(),
    );

    final connectivity = await Connectivity().checkConnectivity();

    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        _workoutCloudSet(workout);
      } else {
        _toBeUploaded(
          tableName: TableNames.workouts,
          object: workout,
          operation: 'insert',
        );
      }
    }

    return workout;
  }

  static Future<void> _workoutCloudSet(WorkoutModel workout,
      [SetOptions? setOptions]) async {
    final workoutDoc = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(CollectionNames.workouts)
        .doc('${workout.id}');

    return workoutDoc.set(
      workout.toMap(),
      setOptions,
    );
  }

  static Future<void> updateWorkout(WorkoutModel workout) async {
    db = await DB.instance.database;

    db.update(
      TableNames.workouts,
      workout.toMap(),
      where: 'id = ? and uid = ? and routineid = ?',
      whereArgs: [workout.id, workout.uId, workout.routineId],
    );

    final connectivity = await Connectivity().checkConnectivity();
    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        _workoutCloudUpdate(workout);
      } else {
        _toBeUploaded(
          tableName: TableNames.workouts,
          object: workout,
          operation: 'insert',
        );
      }
    }
  }

  static Future<void> _workoutCloudUpdate(WorkoutModel workout) async {
    return _workoutCloudSet(
      workout,
      SetOptions(merge: true),
    );
  }

  static Future<int> _toBeUploaded({
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

      bool success = false;
      switch (row['operation']) {
        case 'insert':
          if (dbObject is RoutineModel) {
            _routineCloudSet(dbObject).then((_) => success = true);
          } else if (dbObject is WorkoutModel) {
            _workoutCloudSet(dbObject).then((_) => success = true);
          }
          break;
        case 'delete':
          break;
      }

      if (success) {
        db.delete(
          TableNames.toBeUploaded,
          where: 'primarykey = ?',
          whereArgs: [row['primarykey']],
        );
      }
    }
  }
}
