import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/exercise_widget.dart';
import 'package:gym_bro_alpha/components/my_form_field.dart';
import 'package:gym_bro_alpha/models/exercise_model.dart';
import 'package:gym_bro_alpha/services/exercise_store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';

const params = {
  "type": null,
  "equipment": null,
  "muscles": null,
};

final teste = StreamController<Map<String, dynamic>>();

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<ExerciseModel>? exercises;
  List<ExerciseModel>? filteredExercises;

  @override
  void initState() {
    super.initState();
    ExerciseStore.localExercises.then((value) {
      setState(() {
        exercises = value.toSet().toList();
        filteredExercises = exercises;
        // print(exercises);
      });
    });
  }

  void onChanged(String text) {
    text = text.toLowerCase();

    setState(() {
      filteredExercises = exercises
          ?.where(
            (element) =>
                element.name.toLowerCase().contains(text) ||
                element.category.toLowerCase().contains(text) ||
                element.primaryMuscles
                    .map((e) => e.toLowerCase())
                    .contains(text),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 17,
                      child: MyFormField(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        leading: const Icon(Icons.search),
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        onPressed: () {},
                        // alignment: Alignment.centerLeft,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.favorite),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Expanded(
                      child: FilterButton(FilterPages.type),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: FilterButton(FilterPages.equipment),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: FilterButton(FilterPages.muscle),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (filteredExercises != null)
                  Expanded(
                    child: ListView.separated(
                      // physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredExercises!.length,
                      itemBuilder: (context, index) {
                        return ExerciseWidget(filteredExercises![index]);
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton(this.filter, {super.key});

  final FilterPages filter;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        Navigator.pushNamed(
          context,
          PageRoutes.filter,
          arguments: filter,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filter.iconData,
            size: 25,
          ),
          const SizedBox(width: 4),
          Text(filter.label),
        ],
      ),
    );
  }
}
