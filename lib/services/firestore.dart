import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';

class FireStoreService {
  late final CollectionReference collection;

  FireStoreService(String path) {
    collection = FirebaseFirestore.instance.collection(path);
  }

  Future<void> workoutToCloud(String name) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final workoutCol = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts');
      final workoutDoc = workoutCol.doc();
      final snapshot = await workoutCol.count().get();

      return workoutDoc.set(
        WorkoutModel(
          id: workoutDoc.id,
          userId: user.uid,
          isActive: true,
          order: snapshot.count,
          name: name,
          creation: DateTime.now(),
        ).toMap(),
      );
    }

    return Future.value();
  }
}
