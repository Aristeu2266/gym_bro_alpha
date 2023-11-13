import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/routine_list_widget.dart';
import 'package:gym_bro_alpha/exceptions/connection_exception.dart';
import 'package:gym_bro_alpha/models/routine_list_model.dart';
import 'package:gym_bro_alpha/utils/utils.dart';
import 'package:provider/provider.dart';

import '../components/expand_button.dart';

class RoutineListPage extends StatefulWidget {
  const RoutineListPage({super.key});

  @override
  State<RoutineListPage> createState() => _RoutineListPageState();
}

class _RoutineListPageState extends State<RoutineListPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameMaxLength = 50;
  late bool _isScrollEnd;

  late bool _showActive;
  late bool _showInactive;

  @override
  void initState() {
    super.initState();
    _isScrollEnd = false;
    _showActive = true;
    _showInactive = false;
  }

  void addRoutine() {
    showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Create workout routine'),
          content: SizedBox(
            width: 0,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      label: Text('Name'),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'November workout; Workout for...',
                    ),
                    autofocus: true,
                    maxLength: _nameMaxLength,
                    validator: (name) {
                      if (name == null || name.isEmpty) {
                        return 'Insert a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      label: Text('Details'),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'Comments (optional)',
                    ),
                    minLines: 2,
                    maxLines: 3,
                    maxLength: 256,
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
                  Provider.of<RoutineListModel>(context, listen: false)
                      .add(_nameController.text, _descriptionController.text)
                      .then(
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
      _nameController.text = '';
      _descriptionController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineList = Provider.of<RoutineListModel>(context);

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          setState(() {
            if (scrollNotification.metrics.atEdge &&
                scrollNotification.metrics.pixels != 0) {
              _isScrollEnd = true;
            } else {
              _isScrollEnd = false;
            }
          });
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await routineList.refresh();
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
                        // Active routines list
                        ExpandButton(
                          text: Text(
                            'Workout routines',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          callback: () {
                            setState(() {
                              _showActive = !_showActive;
                            });
                          },
                          initialValue: true,
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: _showActive
                              ? routineList.activeRoutines.length * 65
                              : 0,
                          child: const RoutineListWidget(active: true),
                        ),
                        AddRoutineButton(addRoutine: addRoutine),
                        if (routineList.inactiveRoutines.isNotEmpty)
                          ExpandButton(
                            text: const Text(
                              'Inactive Routines',
                              style: TextStyle(fontSize: 18),
                            ),
                            callback: () {
                              setState(() {
                                _showInactive = !_showInactive;
                              });
                            },
                            initialValue: false,
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: _showInactive
                              ? routineList.inactiveRoutines.length * 65
                              : 0,
                          child: const RoutineListWidget(active: false),
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
              onPressed: addRoutine,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AddRoutineButton extends StatelessWidget {
  const AddRoutineButton({
    required this.addRoutine,
    super.key,
  });

  final void Function() addRoutine;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => addRoutine(),
            child: Text(
              '+ Add Routine',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
