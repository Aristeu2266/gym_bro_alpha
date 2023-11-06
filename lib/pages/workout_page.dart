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
  final GlobalKey<FormFieldState> _formFieldKey = GlobalKey<FormFieldState>();
  late WorkoutListModel workoutList = Provider.of(context, listen: false);

  @override
  void initState() {
    super.initState();

    if (workout == null) {
      Future.delayed(Duration.zero, () => _createWorkout());
    }
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
                //workout = WorkoutModel(id: id, userid: userid, isActive: isActive, order: order, name: name)
              });
              workoutList.addWorkout(name!);
            },
            validator: (name) => name?.isEmpty ?? true ? 'Insert a name' : null,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formFieldKey.currentState?.validate() ?? false) {
                  _formFieldKey.currentState?.save();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Cancel'),
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    workout ??= ModalRoute.of(context)?.settings.arguments as WorkoutModel?;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(workout != null ? workout!.name : workoutName ?? ''),
      ),
    );
  }
}
