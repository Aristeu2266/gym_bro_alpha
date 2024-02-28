import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

enum ScreenSelected {
  statistics(0, Icon(Icons.bar_chart)),
  start(1, Icon(Icons.play_arrow)),
  add(2, Icon(Icons.add));

  const ScreenSelected(this.value, this.icon);
  final int value;
  final Icon icon;
}

enum FilterPages {
  type('Type', CustomIcons.type),
  equipment('Equipment', CustomIcons.equipment),
  muscle('Muscles', CustomIcons.muscles);

  const FilterPages(this.label, this.iconData);
  final String label;
  final IconData iconData;
}

class PageRoutes {
  static const root = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const settings = '/settings';
  static const routine = '/routine';
  static const workout = '/workout';
  static const exercise = '/exercise';
  static const filter = '/filter';
}

class TableNames {
  static const userPrefs = 'user_prefs';
  static const routines = 'routines';
  static const workouts = 'workouts';
  static const exercises = 'exercises';
  static const toBeUploaded = 'to_be_uploaded';
}

class CollectionNames {
  static const users = 'users';
  static const routines = 'routines';
  static const workouts = 'workouts';
  static const exercises = 'exercises';
}
