import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/routine_model.dart';
import 'package:provider/provider.dart';

class RoutineTile extends StatefulWidget {
  const RoutineTile({super.key});

  @override
  State<RoutineTile> createState() => _RoutineTileState();
}

class _RoutineTileState extends State<RoutineTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineModel>(builder: (context, routine, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text(routine.name),
          ),
        ),
      );
    });
  }
}
