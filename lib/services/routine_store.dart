import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/exceptions/connection_exception.dart';
import 'package:gym_bro_alpha/models/routine_model.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/services/store.dart';
import 'package:gym_bro_alpha/services/workout_store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class RoutineStore {
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
          await WorkoutStore.refreshUserWorkouts(routine['id']);
        }
      } else {
        db.insert(TableNames.routines, routine);
      }
    }
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
      uId: FirebaseAuth.instance.currentUser?.uid ?? 'null',
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
        routineCloudSet(routine);
      } else {
        Store.toBeUploaded(
          tableName: TableNames.routines,
          object: routine,
          operation: 'insert',
        );
      }
    }

    return routine;
  }

  static Future<void> routineCloudSet(RoutineModel routine,
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
      whereArgs: [routine.id, routine.uId],
    );

    final connectivity = await Connectivity().checkConnectivity();
    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        routineCloudUpdate(routine);
      } else {
        Store.toBeUploaded(
          tableName: TableNames.routines,
          object: routine,
          operation: 'insert',
        );
      }
    }
  }

  static Future<void> routineCloudUpdate(RoutineModel routine) async {
    return routineCloudSet(
      routine,
      SetOptions(merge: true),
    );
  }

  static Future<void> deleteRoutine(RoutineModel routine) async {
    db = await DB.instance.database;

    db.delete(
      TableNames.routines,
      where: 'id = ? AND uid = ?',
      whereArgs: [routine.id, routine.uId],
    );

    WorkoutStore.dropRoutine(routine.id);

    final connectivity = await Connectivity().checkConnectivity();
    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        routineCloudDelete(routine.id);
      } else {
        Store.toBeUploaded(
          tableName: TableNames.routines,
          object: routine,
          operation: 'delete',
        );
      }
    }
  }

  static Future<void> routineCloudDelete(int routine) async {
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
}
