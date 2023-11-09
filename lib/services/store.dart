import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/models/db_object.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class Store {
  static late Database db;

  static Future<List<Map<String, Object?>>> get userWorkouts async {
    db = await DB.instance.database;

    return await db.query(
      TableNames.workouts,
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

    await _loadUserWorkouts(userDoc);
  }

  static Future<void> _loadUserWorkouts(DocumentReference userDoc) async {
    db = await DB.instance.database;

    final workouts = (await userDoc.collection(CollectionNames.workouts).get())
        .docs
        .map((doc) => doc.data())
        .toList();

    for (Map<String, dynamic> workout in workouts) {
      await db.insert(TableNames.workouts, workout);
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

  static Future<WorkoutModel> newWorkout(String name) async {
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

  static Future<void> _workoutCloudSet(WorkoutModel workout) async {
    final workoutCol = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(CollectionNames.workouts);
    final workoutDoc = workoutCol.doc('${workout.id}');

    return workoutDoc.set(
      workout.toMap(),
    );
  }

  static Future<void> updateWorkout(WorkoutModel workout) async {
    db = await DB.instance.database;

    db.update(
      TableNames.workouts,
      workout.toMap(),
      where: 'id = ? and uid = ?',
      whereArgs: [workout.id, workout.uId],
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
    return _workoutCloudSet(workout);
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

      if (row['origin'] == 'workouts') {
        dbObject = WorkoutModel.mapToModel(
          (await db.query(
            row['origin'] as String,
            where: 'id = ? AND uid = ?',
            whereArgs: [row['id'], row['uid']],
          ))[0],
        );
      } else {
        // TODO: need to sendo info to cloud and delete from local.
        // But, there is only workout to work with so far.

        // dbObject = TrainingModel.mapToModel(
        //   (await db.query(
        //     row['origin'] as String,
        //     where: 'id = ? AND uid = ? AND workoutid = ?',
        //     whereArgs: [row['id'], row['uid'], row['extra']],
        //   ))[0],
        // );
      }

      bool success = false;
      switch (row['operation']) {
        case 'insert':
          if (dbObject is WorkoutModel) {
            _workoutCloudSet(dbObject).then((_) {
              success = true;
            });
          }
          break;
        case 'update':
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
