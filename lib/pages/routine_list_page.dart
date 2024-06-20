import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/routine_list_widget.dart';
import 'package:gym_bro_alpha/exceptions/connection_exception.dart';
import 'package:gym_bro_alpha/models/routine_list_model.dart';
import 'package:gym_bro_alpha/utils/utils.dart';
import 'package:provider/provider.dart';

import '../components/expand_button.dart';
import '../components/add_button.dart';

class RoutineListPage extends StatefulWidget {
  const RoutineListPage({super.key});

  @override
  State<RoutineListPage> createState() => _RoutineListPageState();
}

class _RoutineListPageState extends State<RoutineListPage> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _nameMaxLength = 50;
  bool _isScrollEnd = false;
  bool _showActive = true;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
              await routineList.refresh();
            } on ConnectionException catch (e) {
              if (!context.mounted) return;
              Utils.showSnackbar(context, e.message);
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          callback: () {
                            setState(() {
                              _showActive = !_showActive;
                            });
                          },
                          initialValue: true,
                        ),
                        if (_showActive) const RoutineListWidget(active: true),
                        AddButton(
                          text: '+ Add Routine',
                          addCallback: addRoutine,
                        ),

                        // Inactive routine list
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
                        if (_showInactive)
                          const RoutineListWidget(active: false),
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
