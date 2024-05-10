import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/difficulty_widget.dart';
import 'package:gym_bro_alpha/components/favorite_button.dart';
import 'package:gym_bro_alpha/models/exercise_model.dart';
import 'package:gym_bro_alpha/utils/constants.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseWidget(this.exercise, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      onTap: () {
        Navigator.pushNamed(
          context,
          PageRoutes.exercise,
          arguments: exercise,
        );
      },
      leading: Image.asset(
          'assets/images/muscles/${exercise.primaryMuscles[0].replaceFirst(' b', 'B')}.png'),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DifficultyWidget(
            exercise.level == 'beginner'
                ? 1
                : exercise.level == 'intermediate'
                    ? 2
                    : 3,
          ),
          Text(exercise.name),
        ],
      ),
      subtitle: Text(
        exercise.primaryMuscles.reduce(
          (value, element) => '$value/$element',
        ),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: Checkbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
          SizedBox(
            height: 32,
            width: 32,
            child: FavoriteButton(
              iconSize: 32,
              iconDisabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
              valueChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
