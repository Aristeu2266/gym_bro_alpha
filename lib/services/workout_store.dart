import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/exceptions/connection_exception.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/services/store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutStore {
  static late Database db;

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
        workoutCloudSet(workout);
      } else {
        Store.toBeUploaded(
          tableName: TableNames.workouts,
          object: workout,
          operation: 'insert',
        );
      }
    }

    return workout;
  }

  static Future<void> workoutCloudSet(WorkoutModel workout,
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
        workoutCloudUpdate(workout);
      } else {
        Store.toBeUploaded(
          tableName: TableNames.workouts,
          object: workout,
          operation: 'insert',
        );
      }
    }
  }

  static Future<void> workoutCloudUpdate(WorkoutModel workout) async {
    return workoutCloudSet(
      workout,
      SetOptions(merge: true),
    );
  }

  static Future<void> deleteWorkout(WorkoutModel workout) async {
    db = await DB.instance.database;

    db.delete(
      TableNames.workouts,
      where: 'id = ? AND uid = ?',
      whereArgs: [workout.id, workout.uId],
    );

    final connectivity = await Connectivity().checkConnectivity();
    if (FirebaseAuth.instance.currentUser != null) {
      if (connectivity != ConnectivityResult.none) {
        workoutCloudDelete(workout.id);
      } else {
        Store.toBeUploaded(
          tableName: TableNames.workouts,
          object: workout,
          operation: 'delete',
        );
      }
    }
  }

  static Future<void> workoutCloudDelete(int workout) async {
    final workoutDoc = FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(CollectionNames.workouts)
        .doc('$workout');

    return workoutDoc.delete();
  }

  static Future<void> dropRoutine(int routineId) async {
    db = await DB.instance.database;

    final workouts = await db.query(
      TableNames.workouts,
      where: 'uid = ? AND routineid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null', routineId],
    );

    for (Map<String, Object?> workout in workouts) {
      deleteWorkout(WorkoutModel.mapToModel(workout));
    }
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
}
