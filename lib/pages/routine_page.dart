import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/expand_button.dart';
import 'package:gym_bro_alpha/models/routine_model.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/pages/add_button.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  late RoutineModel routine;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _workoutNameController;
  late FocusNode _titleFocus;
  late FocusNode _descriptionFocus;
  final int _titleMaxLength = 30;
  bool _isEditing = false;
  bool _isDirty = false;
  bool _isScrollEnd = false;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
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
    routine = ModalRoute.of(context)?.settings.arguments as RoutineModel;
    _titleController.text = routine.name;
    _descriptionController.text = routine.description ?? '';
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
                routine.name,
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
              if (!_isDirty) {
                _isEditing = !_isEditing;
                _showDescription = true;
              }

              if (!_isEditing && !_isDirty) {
                // Saving
                if (_titleController.text.isNotEmpty) {
                  if (_titleController.text != routine.name) {
                    routine.name = _titleController.text;
                  }
                } else {
                  _titleController.text = routine.name;
                }
                FocusManager.instance.primaryFocus?.unfocus();
              }
              if (_isDirty) {
                setState(() {
                  _isDirty = !_isDirty;
                  _isEditing = false;
                });
                routine.update(
                  name: _titleController.text,
                  description: _descriptionController.text,
                );
                FocusManager.instance.primaryFocus?.unfocus();
              } else {
                // Entering edit mode
                _titleFocus.requestFocus();
              }
            });
          },
          icon: _isEditing || _isDirty
              ? const Icon(Icons.save_outlined)
              : const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }

  void addWorkout() {
    showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Add workout'),
          content: SizedBox(
            width: 0,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _workoutNameController,
                    decoration: const InputDecoration(
                      label: Text('Name'),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'Workout A; Legs; Push...',
                    ),
                    autofocus: true,
                    maxLength: _titleMaxLength,
                    validator: (name) {
                      if (name == null || name.isEmpty) {
                        return 'Insert a name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  routine.addWorkout(_workoutNameController.text).then(
                        (_) => Navigator.pop(context),
                      );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        _workoutNameController.text = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _isEditing = false;
        });
        _titleController.text = routine.name;
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
              // TODO: refresh da rotina
              // try {
              //   await routineList.refresh();
              // } on ConnectionException catch (e) {
              //   if (mounted) {
              //     Utils.showSnackbar(context, e.message);
              //   }
              // }
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
                          if ((routine.description?.isNotEmpty ?? false) ||
                              _isEditing)
                            descriptionCard(),
                          const SizedBox(height: 12),
                          Text(
                            'Workouts',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          ReorderableListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            onReorder: (oldIndex,
                                newIndex) {}, // TODO: => _onReorder(routineListModel, oldIndex, newIndex),
                            itemCount: routine.workouts.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return WorkoutTile(
                                key: ValueKey(routine.workouts[index].id),
                                workout: routine.workouts[index],
                              );
                            },
                          ),
                          AddButton(
                            text: '+ Add Workout',
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

  GestureDetector descriptionCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
          _descriptionFocus.requestFocus();
        });
      },
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpandButton(
                      text: Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      initialValue:
                          _descriptionController.text.isEmpty && _isEditing,
                      callback: () {
                        setState(() {
                          _showDescription = !_showDescription;
                        });
                      },
                    ),
                    if (_showDescription)
                      TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocus,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: !_isEditing ? '' : null,
                          hintText: 'Description...',
                        ),
                        minLines: null,
                        maxLines: null,
                        onTap: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        onChanged: (_) {
                          _isDirty = true;
                        },
                        maxLength: 256,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutTile extends StatelessWidget {
  const WorkoutTile({
    super.key,
    required this.workout,
  });

  final WorkoutModel workout;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Dismissible(
        key: ValueKey(workout.id),
        direction: DismissDirection.startToEnd,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
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
          margin: const EdgeInsets.symmetric(vertical: 4),
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
          if (direction == DismissDirection.startToEnd) {
            return showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: Text(
                    'Delete permanently your "${workout.name}" routine and its data?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
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
          // TODO: apagar treino
          // routineListModel.delete(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Card(
            margin: EdgeInsets.zero,
            shape: const ContinuousRectangleBorder(),
            child: InkWell(
              onTap: () {},
              child: ListTile(
                title: Text(workout.name),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
