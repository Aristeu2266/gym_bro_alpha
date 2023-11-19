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

    final routines = (await db.query(
      TableNames.routines,
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
    ))
        .toList()
      ..sort(
        (a, b) => (a['sortorder'] as int) - (b['sortorder'] as int),
      );

    final workouts = (await db.query(
      TableNames.workouts,
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
    ))
        .toList()
      ..sort(
        (a, b) => (a['sortorder'] as int) - (b['sortorder'] as int),
      );

    final List<Map<String, dynamic>> clone = [];

    for (Map<String, dynamic> routine in routines) {
      clone.add({
        ...routine,
        'workouts': workouts
            .where((e) => e['routineid'] == routine['id'])
            .map((e) => WorkoutModel.mapToModel(e))
            .toList(),
      });
    }

    return clone;
  }

  static Future<List<Map<String, dynamic>>> localUserWorkouts(
      int routineId) async {
    db = await DB.instance.database;

    final workouts = (await db.query(
      TableNames.workouts,
      where: 'uid = ? AND routineid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null', routineId],
    ))
        .toList()
      ..sort(
        (a, b) => (a['sortorder'] as int) - (b['sortorder'] as int),
      );

    return workouts;
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
        .toList();

    final localRoutinesList = await localUserRoutines;
    final localRoutinesIds =
        localRoutinesList.map((e) => e['id'] as int).toList();

    for (Map<String, dynamic> routine in routines) {
      if (localRoutinesIds.contains(routine['id'])) {
        final localRoutine =
            localRoutinesList.firstWhere((e) => routine['id'] == e['id']);
        if (DateTime.parse(routine['creationdate'])
            .isAtSameMomentAs(DateTime.parse(localRoutine['creationdate']))) {
          await db.update(
            TableNames.routines,
            routine,
            where: 'id = ? AND uid = ?',
            whereArgs: [routine['id'], routine['uid']],
          );
        } else if (DateTime.parse(routine['creationdate'])
            .isAfter(DateTime.parse(localRoutine['creationdate']))) {
          await db.delete(
            TableNames.routines,
            where: 'id = ? AND uid = ?',
            whereArgs: [routine['id'], routine['uid']],
          );
          await db.delete(
            TableNames.workouts,
            where: 'uid = ? AND routineid = ?',
            whereArgs: [routine['uid'], routine['routineid']],
          );
          await db.insert(TableNames.routines, routine);
          await refreshUserWorkouts(routine['id']);
        }
      } else {
        db.insert(TableNames.routines, routine);
      }
    }
  }

  static Future<void> refreshUserWorkouts(int routineId) async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      throw ConnectionException('Connection failed');
    }

    db = await DB.instance.database;

    final userDoc = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final workouts = (await userDoc
            .collection(CollectionNames.workouts)
            .where('routineid', isEqualTo: routineId)
            .get())
        .docs
        .map((doc) => doc.data())
        .toList();

    final localWorkoutsList = await localUserWorkouts(routineId);
    final localWorkoutsIds =
        localWorkoutsList.map((e) => e['id'] as int).toList();

    for (Map<String, dynamic> workout in workouts) {
      if (localWorkoutsIds.contains(workout['id'])) {
        final localWorkout =
            localWorkoutsList.firstWhere((e) => workout['id'] == e['id']);
        if (DateTime.parse(workout['creationdate'])
            .isAtSameMomentAs(DateTime.parse(localWorkout['creationdate']))) {
          db.update(
            TableNames.workouts,
            workout,
            where: 'id = ? AND uid = ? AND routineid = ?',
            whereArgs: [workout['id'], workout['uid'], workout['routineid']],
          );
        } else if (DateTime.parse(workout['creationdate'])
            .isAfter(DateTime.parse(localWorkout['creationdate']))) {
          // TODO: apagar também todos os dados relacionados a esse treino apagado
          await db.delete(
            TableNames.workouts,
            where: 'id = ? AND uid = ? AND routineid = ?',
            whereArgs: [workout['id'], workout['uid'], workout['routineid']],
          );
          await db.insert(TableNames.workouts, workout);
        }
      } else {
        db.insert(TableNames.workouts, workout);
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

    List<Map<String, Object?>> id = (await db.query(
      TableNames.routines,
      columns: ['MAX(id)+1 AS id'],
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
      groupBy: 'uid',
    ));

    RoutineModel routine = RoutineModel(
      id: id.isNotEmpty ? id[0]['id'] as int : 1,
      uid: FirebaseAuth.instance.currentUser?.uid ?? 'null',
      name: name,
      isActive: true,
      sortOrder: (await maxRoutineSortOrder(true)) + 1,
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

  static Future<int> maxRoutineSortOrder(bool active) async {
    db = await DB.instance.database;

    final maxSortOrder = ((await db.query(
          TableNames.routines,
          columns: ['COUNT(id) AS sortorder'],
          where: 'uid = ? AND isactive = ?',
          whereArgs: [
            FirebaseAuth.instance.currentUser?.uid ?? 'null',
            active ? 1 : 0,
          ],
        ))[0]['sortorder'] ??
        1) as int;

    return maxSortOrder;
  }

  static Future<WorkoutModel> newWorkout(String name, int routineId) async {
    db = await DB.instance.database;

    List<Map<String, Object?>> id = await db.query(
      TableNames.workouts,
      columns: ['MAX(id)+1 AS id'],
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
      groupBy: 'uid',
    );

    WorkoutModel workout = WorkoutModel(
      id: id.isNotEmpty ? id[0]['id'] as int : 1,
      uId: FirebaseAuth.instance.currentUser?.uid ?? 'null',
      routineId: routineId,
      sortOrder: (await maxWorkoutSortOrder(routineId)) + 1,
      name: name,
      creationDate: DateTime.now(),
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

  static Future<int> maxWorkoutSortOrder(int routineId) async {
    db = await DB.instance.database;

    final maxSortOrder = ((await db.query(
          TableNames.workouts,
          columns: ['COUNT(id) AS sortorder'],
          where: 'uid = ? AND routineid = ?',
          whereArgs: [
            FirebaseAuth.instance.currentUser?.uid ?? 'null',
            routineId,
          ],
        ))[0]['sortorder'] ??
        1) as int;

    return maxSortOrder;
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
            await _routineCloudSet(dbObject).then((_) => success = true);
          } else if (dbObject is WorkoutModel) {
            await _workoutCloudSet(dbObject).then((_) => success = true);
          }
          break;
        case 'delete':
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
