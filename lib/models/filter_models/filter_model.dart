import 'package:flutter/material.dart';

class FilterModel {
  final String label;
  Widget? _pic;
  final IconData? icon;

  FilterModel(this.label, {Widget? pic, this.icon}) {
    assert(pic != null || icon != null);
    _pic = pic;
  }

  Widget? widget([Color? color]) {
    return _pic ??
        Icon(
          icon,
          color: color,
        );
  }
}
