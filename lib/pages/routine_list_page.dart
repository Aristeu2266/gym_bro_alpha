import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/routine_tile.dart';
import 'package:gym_bro_alpha/models/routine_list_model.dart';
import 'package:provider/provider.dart';

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
  bool _isScrollEnd = false;

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    Provider.of<RoutineListModel>(
      context,
      listen: false,
    ).move(oldIndex, newIndex);
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
      body: RefreshIndicator(
        // TODO: fazer um método para sincronizar os dados com a núvem
        onRefresh: () async {},
        child: NotificationListener<ScrollNotification>(
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
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: _onReorder,
                    itemCount: routineList.routines.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    header: const Text(
                      'Workout routines',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    itemBuilder: (ctx, index) {
                      return ChangeNotifierProvider.value(
                        key: ValueKey(routineList.routines[index]),
                        value: routineList.routines[index],
                        child: const RoutineTile(),
                      );
                    },
                  ),
                  Row(
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
                  ),
                ],
              ),
            ),
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
