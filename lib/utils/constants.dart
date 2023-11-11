import 'package:flutter/material.dart';

enum ScreenSelected {
  statistics(0, Icon(Icons.bar_chart)),
  start(1, Icon(Icons.play_arrow)),
  add(2, Icon(Icons.add));

  const ScreenSelected(this.value, this.icon);
  final int value;
  final Icon icon;
}

class PageRoutes {
  static const root = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const resetPassword = '/resetPassword';
  static const home = '/home';
  static const settings = '/settings';
  static const workout = '/workout';
}

class TableNames {
  static const userPrefs = 'user_prefs';
  static const routines = 'routines';
  static const workouts = 'workouts';
  static const toBeUploaded = 'to_be_uploaded';
}

class CollectionNames {
  static const users = 'users';
  static const routines = 'routines';
  static const workouts = 'workouts';
}
