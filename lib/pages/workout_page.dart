import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/exceptions/connection_exception.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/components/add_button.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/utils.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late WorkoutModel workout;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _workoutNameController;
  late FocusNode _titleFocus;
  late FocusNode _descriptionFocus;
  final int _titleMaxLength = 30;
  bool _isEditing = false;
  bool _isScrollEnd = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _workoutNameController = TextEditingController();
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _workoutNameController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    workout = ModalRoute.of(context)?.settings.arguments as WorkoutModel;
    _titleController.text = workout.name;
  }

  void addWorkout() {
    Navigator.pushNamed(context, PageRoutes.addExercise);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    // TODO: reorder exercises
    // routine.reorderWorkout(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _isEditing = false;
          if (_titleController.text.isEmpty) {
            _titleController.text = workout.name;
          }
        });
      },
      child: Scaffold(
        appBar: _appBar(),
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                bool A = scrollNotification.metrics.atEdge;
                bool B = scrollNotification.metrics.pixels == 0;
                bool E = scrollNotification.metrics.maxScrollExtent == 0.0;
                // some piece of boolean monstrosity only cause I had fun doing it lol
                setState(() {
                  if (E || (A && !B)) {
                    _isScrollEnd = true;
                  } else {
                    _isScrollEnd = false;
                  }
                });
              },
            );
            return true;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              try {
                // TODO: refresh workout
                // await routine.refresh();
                setState(() {});
              } on ConnectionException catch (e) {
                if (mounted) {
                  Utils.showSnackbar(context, e.message);
                }
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Exercises',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          ReorderableListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            onReorder: _onReorder,
                            itemCount: workout.exercises.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                key: ValueKey(workout.exercises[index]),
                                borderRadius: BorderRadius.circular(12),
                                child: Dismissible(
                                  key: ValueKey(workout.exercises[index]),
                                  direction: DismissDirection.startToEnd,
                                  background: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.only(left: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.only(right: 12),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                    ),
                                    alignment: Alignment.centerRight,
                                    child: const Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      return showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Are you sure?'),
                                          content: Text(
                                              'Delete "${workout.exercises[index].name}" from this workout?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: const Text('No'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .errorContainer,
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onErrorContainer,
                                              ),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Future.value(true);
                                    }
                                  },
                                  onDismissed: (direction) {
                                    setState(() {
                                      // TODO: delete exercise
                                      // routine.deleteWorkout(index);
                                    });
                                  },
                                  child: ExerciseTile(
                                      exercise: workout.exercises[index]),
                                ),
                              );
                            },
                          ),
                          AddButton(
                            text: '+ Add Exercise',
                            addCallback: addWorkout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: !_isScrollEnd
            ? FloatingActionButton(
                onPressed: addWorkout,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      centerTitle: true,
      title: _isEditing
          ? TextField(
              textAlign: TextAlign.center,
              maxLines: 1,
              maxLength: _titleMaxLength,
              style: const TextStyle(
                fontSize: 21,
                fontFamily: 'Roboto-Regular',
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 4, right: 3),
              ),
              controller: _titleController,
              focusNode: _titleFocus,
            )
          : FittedBox(
              fit: BoxFit.cover,
              child: Text(
                workout.name,
                style: const TextStyle(
                  fontSize: 21,
                  fontFamily: 'Roboto-Regular',
                ),
              ),
            ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
            if (_isEditing) {
              _titleFocus.requestFocus();
            } else {
              if (_titleController.text.isEmpty) {
                _titleController.text = workout.name;
              } else if (_titleController.text != workout.name) {
                workout.name = _titleController.text;
              }
            }
          },
          icon: _isEditing
              ? const Icon(Icons.save_outlined)
              : const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }
}

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    super.key,
    required this.exercise,
  });

  // TODO: exercise model
  final WorkoutModel exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        shape: const ContinuousRectangleBorder(),
        child: InkWell(
          onTap: () {},
          child: ListTile(
            title: Text(exercise.name),
          ),
        ),
      ),
    );
  }
}
