import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/user_routine.dart';

class UserRoutineList with ChangeNotifier{
  final String _token;
  final String _userId;
  final List<UserRoutine> _routines;

  UserRoutineList([
    this._token = '',
    this._userId = '',
    this._routines = const [],
  ]);
}
