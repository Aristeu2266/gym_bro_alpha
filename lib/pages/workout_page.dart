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
  late GlobalKey<FormFieldState>? _formFieldKey;
  late WorkoutListModel workoutList = Provider.of(context, listen: false);
  TextEditingController? _titleController;
  late FocusNode _titleFocus;
  late int _titleWidth;
  final int _titleMaxLength = 30;
  bool _isEditingTitle = false;
  // TODO: delete
  Color oto = Colors.red;

  @override
  void initState() {
    super.initState();
    _formFieldKey = GlobalKey<FormFieldState>();
    _titleController = TextEditingController();
    _titleFocus = FocusNode();
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
    _titleController!.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    workout ??= ModalRoute.of(context)?.settings.arguments as WorkoutModel?;
    _titleController!.text = workout != null ? workout!.name : ' ';
    _updateTitleWidth();
  }

  void _updateTitleWidth() {
    _titleWidth = (_titleController!.text.isNotEmpty
                ? (_titleController!.text.length + 1) * 15
                : 1) <
            106
        ? 106
        : (_titleController!.text.length + 1) * 15;
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
            onSaved: (name) async {
              // workout = await workoutList.add(name!);
              if (workout != null && mounted) {
                Navigator.pop(context);
              }
              setState(() {});
            },
            validator: (name) {
              if (name == null || name.isEmpty) {
                return 'Insert a name';
              } else if (name.length > _titleMaxLength) {
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
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      if (workout == null) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      centerTitle: true,
      title: _isEditingTitle
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              width: double.parse('$_titleWidth'),
              alignment: Alignment.center,
              child: TextField(
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
                  contentPadding: EdgeInsets.only(bottom: 4, left: 3),
                ),
                controller: _titleController,
                focusNode: _titleFocus,
                onChanged: (value) {
                  setState(() {
                    oto = oto == Colors.red ? Colors.orange : Colors.red;
                    _updateTitleWidth();
                  });
                },
              ),
            )
          : FittedBox(
              fit: BoxFit.cover,
              child: Text(
                workout?.name ?? ' ',
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
              _isEditingTitle = !_isEditingTitle;
              if (!_isEditingTitle) {
                if (_titleController!.text.isNotEmpty) {
                  workout!.name = _titleController!.text;
                } else {
                  _titleController!.text = workout!.name;
                }
              } else {
                _titleFocus.requestFocus();
              }
            });
          },
          icon: _isEditingTitle
              ? const Icon(Icons.save_outlined)
              : const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        color: oto,
      ),
    );
  }
}
