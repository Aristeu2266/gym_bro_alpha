import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/exercise_widget.dart';
import 'package:gym_bro_alpha/components/my_form_field.dart';
import 'package:gym_bro_alpha/models/exercise_model.dart';
import 'package:gym_bro_alpha/services/exercise_store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late TextEditingController searchController;

  List<ExerciseModel>? exercises;
  List<ExerciseModel>? filteredExercises;

  Map<String, String> filters = {
    for (FilterPages filterPage in FilterPages.values) filterPage.label: 'all'
  };

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    ExerciseStore.localExercises.then((value) {
      setState(() {
        exercises = value.toSet().toList();
        filteredExercises = exercises;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void applySearch(String text) {
    text = text.toLowerCase();

    setState(() {
      filteredExercises = exercises
          ?.where(
            (exercise) =>
                exercise.name.toLowerCase().contains(text) ||
                exercise.category.toLowerCase().contains(text) ||
                exercise.primaryMuscles
                    .map((e) => e.toLowerCase())
                    .contains(text),
          )
          .toList();
    });
  }

  bool filterName(ExerciseModel exercise) {
    final text = searchController.text.toLowerCase();

    return exercise.name.toLowerCase().contains(text) ||
        exercise.category.toLowerCase().contains(text) ||
        exercise.primaryMuscles.map((e) => e.toLowerCase()).contains(text);
  }

  void applyFilter([String? filter, String? selected]) {
    if (filter != null && selected != null) {
      selected = selected.toLowerCase();
      filters[filter] = selected;
    }

    setState(() {
      filteredExercises = exercises?.where((exercise) {
        return (filters[FilterPages.type.label] == 'all' ||
                filters[FilterPages.type.label] == exercise.category) &&
            (filters[FilterPages.equipment.label] == 'all' ||
                filters[FilterPages.equipment.label] == exercise.equipment) &&
            (filters[FilterPages.muscle.label] == 'all' ||
                exercise.primaryMuscles.contains(
                  filters[FilterPages.muscle.label],
                )) &&
            filterName(exercise);
      }).toList();
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
                        controller: searchController,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        leading: const Icon(Icons.search),
                        onChanged: applyFilter,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.favorite),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FilterButton(
                        filter: FilterPages.type,
                        selected: filters[FilterPages.type.label],
                        applyFilter: applyFilter,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterButton(
                        filter: FilterPages.equipment,
                        selected: filters[FilterPages.equipment.label],
                        applyFilter: applyFilter,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterButton(
                        filter: FilterPages.muscle,
                        selected: filters[FilterPages.muscle.label],
                        applyFilter: applyFilter,
                      ),
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
  const FilterButton(
      {required this.filter,
      required this.selected,
      required this.applyFilter,
      super.key});

  final FilterPages filter;
  final String? selected;
  final Function(String, String) applyFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          color: Colors.orange,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: (selected ?? 'all') == 'all'
                ? colorScheme.background
                : colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              PageRoutes.filter,
              arguments: {'filter': filter, 'selected': selected ?? 'all'},
            ).then((value) {
              if (value != null) {
                applyFilter(filter.label, value.toString());
              }
            });
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
        ),
        if ((selected ?? 'all') != 'all')
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              height: 20,
              width: 20,
              child: IconButton(
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  applyFilter(filter.label, 'all');
                },
                icon: Icon(
                  Icons.cancel,
                  color: colorScheme.errorContainer,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
