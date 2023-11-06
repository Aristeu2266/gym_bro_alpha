import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/services/firestore.dart';

class Store {
  final FireStoreService userCol = FireStoreService('users');
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> createWorkout(String name) async {
    if (user?.isAnonymous ?? true) {
      return;
    }

    final userDoc = userCol.collection.doc(user?.uid);
    final workoutCol = userDoc.collection('workouts');
    final workoutDoc = workoutCol.doc();

    return workoutDoc.set({}
        //WorkoutModel(id: workoutDoc.id, userId: user!.uid, isActive: true, order: workoutCol.count().get(), name: name, creation: ).toMap(),
        );
  }
}
