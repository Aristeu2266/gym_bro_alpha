import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/workout_model.dart';
import 'package:gym_bro_alpha/models/workout_list_model.dart';
import 'package:provider/provider.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  WorkoutModel? workout;
  String? workoutName;
  late GlobalKey<FormFieldState>? _formFieldKey;
  late WorkoutListModel workoutList = Provider.of(context, listen: false);

  @override
  void initState() {
    super.initState();
    _formFieldKey = GlobalKey<FormFieldState>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (workout == null) {
          await _createWorkout();
        }
      },
    );
  }

  @override
  void dispose() {
    _formFieldKey!.currentState?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    workout ??= ModalRoute.of(context)?.settings.arguments as WorkoutModel?;
  }

  Future<void> _createWorkout() async {
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Choose a name for this workout:'),
          content: TextFormField(
            key: _formFieldKey,
            decoration: const InputDecoration(
                hintText: 'Leg day; Back and Bi; Push...'),
            autofocus: true,
            onSaved: (name) {
              setState(() {
                workoutName = name;
              });
              workoutList.addWorkout(name!);
            },
            validator: (name) {
              if (name == null || name.isEmpty) {
                return 'Insert a name';
              } else if (name.length > 30) {
                return 'Name too big';
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
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
                if (_formFieldKey!.currentState?.validate() ?? false) {
                  _formFieldKey!.currentState?.save();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      if (workoutName == null) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.cover,
          child: Text(workout != null ? workout!.name : workoutName ?? ' '),
        ),
      ),
    );
  }
}
