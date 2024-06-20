import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/exercise_widget.dart';
import 'package:gym_bro_alpha/components/my_form_field.dart';
import 'package:gym_bro_alpha/models/exercise_model.dart';
import 'package:gym_bro_alpha/services/exercise_store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';

class AddExercisesPage extends StatefulWidget {
  const AddExercisesPage({super.key});

  @override
  State<AddExercisesPage> createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  bool _isScrollEnd = true;
  int itemsToLoad = 10;
  int loaded = 1;

  List<ExerciseModel>? exercises;
  List<ExerciseModel>? filteredExercises;

  Map<String, String> filters = {
    for (FilterPages filterPage in FilterPages.values) filterPage.label: 'all',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()
      ..addListener(
        () {
          if (_scrollController.position.maxScrollExtent -
                  _scrollController.position.pixels <
              100) {
            setState(() {
              loaded += 1;
            });
          }
        },
      );

    ExerciseStore.localExercises.then((value) {
      setState(() {
        exercises = value.toSet().toList();
        filteredExercises = exercises;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
    final text = _searchController.text.toLowerCase();

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

  int itemCount() {
    return (loaded * itemsToLoad) > (filteredExercises?.length ?? 0)
        ? (filteredExercises?.length ?? 0)
        : loaded * itemsToLoad;
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
                        controller: _searchController,
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
                  NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          bool A = scrollNotification.metrics.atEdge;
                          bool B = scrollNotification.metrics.pixels == 0;
                          // some piece of boolean monstrosity only cause I had fun doing it lol
                          setState(() {
                            if (A && B) {
                              _isScrollEnd = true;
                            } else {
                              _isScrollEnd = false;
                            }
                          });
                        },
                      );
                      return true;
                    },
                    child: Expanded(
                      child: ListView.separated(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: itemCount(), //filteredExercises!.length,
                        itemBuilder: (context, index) {
                          return ExerciseWidget(filteredExercises![index]);
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !_isScrollEnd
          ? FloatingActionButton(
              onPressed: () async {
                await _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                );
                await Future.delayed(const Duration(milliseconds: 500));
                setState(() {
                  _isScrollEnd = true;
                });
              },
              shape: const CircleBorder(),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: (selected ?? 'all') == 'all'
                ? colorScheme.surface
                : colorScheme.primaryContainer,
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
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                filter.label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
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
                  color: Colors.redAccent[100],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
