import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/workout_list_tile.dart';
import 'package:gym_bro_alpha/models/workout_list_model.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:provider/provider.dart';

class WorkoutListPage extends StatelessWidget {
  const WorkoutListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutList = Provider.of<WorkoutListModel>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {},
              itemCount: workoutList.workouts.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              header: const Text(
                'Workouts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              itemBuilder: (ctx, index) {
                return ChangeNotifierProvider.value(
                  key: ValueKey(workoutList.workouts[index]),
                  value: workoutList.workouts[index],
                  child: WorkoutListTile(
                    workoutList.workouts[index],
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, PageRoutes.workout);
                    },
                    child: Text(
                      '+ Add Workout',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
