import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/exercise_widget.dart';
import 'package:gym_bro_alpha/components/my_form_field.dart';
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
  List? exercises;

  @override
  void initState() {
    super.initState();
    ExerciseStore.localExercises.then((value) {
      setState(() {
        exercises = value;
        // print(exercises);
      });
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
                    const Expanded(
                      flex: 17,
                      child: MyFormField(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        leading: Icon(Icons.search),
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
                if (exercises != null)
                  Expanded(
                    child: ListView.separated(
                      // physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: exercises!.length,
                      itemBuilder: (context, index) {
                        return ExerciseWidget(exercises![index]);
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
