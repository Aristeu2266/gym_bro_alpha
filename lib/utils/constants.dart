
import 'package:flutter/material.dart';

enum ColorSeed {
  baseColor('Grey', Colors.grey),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum ScreenSelected {
  statistics(0, Icon(Icons.bar_chart)),
  start(1, Icon(Icons.play_arrow)),
  add(2, Icon(Icons.add));

  const ScreenSelected(this.value, this.icon);
  final int value;
  final Icon icon;
}