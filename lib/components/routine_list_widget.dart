import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/routine_tile.dart';
import 'package:gym_bro_alpha/models/routine_list_model.dart';
import 'package:gym_bro_alpha/utils/utils.dart';
import 'package:provider/provider.dart';

class RoutineListWidget extends StatelessWidget {
  const RoutineListWidget({required this.active, super.key});

  final bool active;

  void _onReorder(RoutineListModel routineList, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    routineList.move(oldIndex, newIndex, active);
  }

  @override
  Widget build(BuildContext context) {
    final routineListModel = Provider.of<RoutineListModel>(context);
    final routineList = active
        ? routineListModel.activeRoutines
        : routineListModel.inactiveRoutines;
    return ReorderableListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) =>
          _onReorder(routineListModel, oldIndex, newIndex),
      itemCount: routineList.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ClipRRect(
          key: ValueKey(routineList[index].id),
          borderRadius: BorderRadius.circular(12),
          child: Dismissible(
            key: ValueKey(routineList[index].id),
            direction: active
                ? DismissDirection.startToEnd
                : DismissDirection.horizontal,
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: Icon(
                active ? Icons.remove_circle : Icons.delete,
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
            confirmDismiss: active
                ? null
                : (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      return showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Are you sure?'),
                          content: Text(
                              'Delete permanently your "${routineList[index].name}" routine and its data?'),
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
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                foregroundColor: Theme.of(context)
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
              if (active) {
                routineListModel.toggleIsActive(routineList[index]);
                Utils.showSnackbar(
                  context,
                  'Your routine has been inactivated.',
                  SnackBarAction(
                    label: 'UNDO',
                    onPressed: () =>
                        routineListModel.toggleIsActive(routineList[index]),
                    textColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              } else {
                if (direction == DismissDirection.endToStart) {
                  routineListModel.toggleIsActive(routineList[index]);
                  Utils.showSnackbar(
                    context,
                    'Your routine has been activated.',
                    SnackBarAction(
                      label: 'UNDO',
                      onPressed: () =>
                          routineListModel.toggleIsActive(routineList[index]),
                      textColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  );
                } else {
                  routineListModel.delete(index);
                }
              }
            },
            child: ChangeNotifierProvider.value(
              key: ValueKey(routineList[index]),
              value: routineList[index],
              child: const RoutineTile(),
            ),
          ),
        );
      },
    );
  }
}
