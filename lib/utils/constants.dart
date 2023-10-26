
import 'package:flutter/material.dart';

enum ScreenSelected {
  statistics(0, Icon(Icons.bar_chart)),
  start(1, Icon(Icons.play_arrow)),
  add(2, Icon(Icons.add));

  const ScreenSelected(this.value, this.icon);
  final int value;
  final Icon icon;
}